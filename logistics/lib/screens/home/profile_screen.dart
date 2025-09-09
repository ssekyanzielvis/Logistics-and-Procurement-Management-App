import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  // Controllers
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _roleController;

  // State variables
  File? _profileImage;
  String? _profileImageUrl;
  bool _isLoading = true;
  bool _isSaving = false;

  // Constants
  static const String _defaultRole = 'No role';
  static const String _profileImagesBucket = 'profile-images';
  static const int _signedUrlExpirySeconds = 3600;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadProfileData();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _initializeControllers() {
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _roleController = TextEditingController(text: _defaultRole);
  }

  void _disposeControllers() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
  }

  Future<void> _loadProfileData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        _showErrorSnackBar('User not authenticated');
        return;
      }

      final userData = await _fetchUserData(userId);
      if (userData != null && mounted) {
        _populateFormFields(userData);
        await _loadProfileImage(userData['avatar_url']);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to load profile: ${_getErrorMessage(e)}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  Future<Map<String, dynamic>?> _fetchUserData(String userId) async {
    final response =
        await _supabase
            .from('users')
            .select('full_name, email, phone, role, avatar_url')
            .eq('id', userId)
            .maybeSingle();

    return response;
  }

  void _populateFormFields(Map<String, dynamic> userData) {
    _fullNameController.text = userData['full_name']?.toString() ?? '';
    _emailController.text = userData['email']?.toString() ?? '';
    _phoneController.text = userData['phone']?.toString() ?? '';
    _roleController.text = userData['role']?.toString() ?? _defaultRole;
  }

  Future<void> _loadProfileImage(String? avatarUrl) async {
    if (avatarUrl == null || avatarUrl.isEmpty) return;

    try {
      final signedUrl = await _supabase.storage
          .from(_profileImagesBucket)
          .createSignedUrl(avatarUrl, _signedUrlExpirySeconds);

      if (mounted) {
        setState(() => _profileImageUrl = signedUrl);
      }
    } catch (e) {
      debugPrint('Failed to load profile image: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _profileImage = File(pickedFile.path);
          _profileImageUrl = null; // Clear existing URL
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: ${_getErrorMessage(e)}');
    }
  }

  Future<String?> _uploadProfileImage() async {
    if (_profileImage == null) return null;

    final userId = _getCurrentUserId();
    if (userId == null) return null;

    final fileExtension = _profileImage!.path.split('.').last.toLowerCase();
    final fileName = 'avatar_$userId.$fileExtension';

    try {
      // Remove existing file if it exists
      try {
        await _supabase.storage.from(_profileImagesBucket).remove([fileName]);
      } catch (e) {
        // Ignore if file doesn't exist
        debugPrint('Previous avatar file not found: $e');
      }

      // Upload new file
      await _supabase.storage
          .from(_profileImagesBucket)
          .upload(fileName, _profileImage!);

      return fileName;
    } catch (e) {
      _showErrorSnackBar('Failed to upload image: ${_getErrorMessage(e)}');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;

    setState(() => _isSaving = true);

    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        _showErrorSnackBar('User not authenticated');
        return;
      }

      // Upload image if selected
      String? avatarFileName;
      if (_profileImage != null) {
        avatarFileName = await _uploadProfileImage();
        if (avatarFileName == null) {
          // Upload failed, don't proceed with profile update
          return;
        }
      }

      // Prepare update data
      final updates = <String, dynamic>{
        'full_name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': _roleController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (avatarFileName != null) {
        updates['avatar_url'] = avatarFileName;
      }

      // Update user data
      await _supabase.from('users').update(updates).eq('id', userId);

      if (mounted) {
        _showSuccessSnackBar('Profile updated successfully!');
        // Reload data to reflect changes
        await _loadProfileData();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to save profile: ${_getErrorMessage(e)}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getErrorMessage(dynamic error) {
    if (error is PostgrestException) {
      return error.message;
    }
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), elevation: 0),
      body:
          _isLoading
              ? const _LoadingWidget()
              : _ProfileForm(
                formKey: _formKey,
                fullNameController: _fullNameController,
                emailController: _emailController,
                phoneController: _phoneController,
                roleController: _roleController,
                profileImage: _profileImage,
                profileImageUrl: _profileImageUrl,
                isSaving: _isSaving,
                onPickImage: _pickImage,
                onSaveProfile: _saveProfile,
              ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading profile...'),
        ],
      ),
    );
  }
}

class _ProfileForm extends StatelessWidget {
  const _ProfileForm({
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.roleController,
    required this.profileImage,
    required this.profileImageUrl,
    required this.isSaving,
    required this.onPickImage,
    required this.onSaveProfile,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController roleController;
  final File? profileImage;
  final String? profileImageUrl;
  final bool isSaving;
  final VoidCallback onPickImage;
  final VoidCallback onSaveProfile;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileImagePicker(
              profileImage: profileImage,
              profileImageUrl: profileImageUrl,
              onPickImage: onPickImage,
            ),
            const SizedBox(height: 32),
            _CustomTextFormField(
              controller: fullNameController,
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _CustomTextFormField(
              controller: emailController,
              labelText: 'Email',
              hintText: 'e.g. user@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _CustomTextFormField(
              controller: phoneController,
              labelText: 'Phone',
              hintText: 'Enter your phone number',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  if (value.trim().length < 10) {
                    return 'Please enter a valid phone number';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _CustomTextFormField(
              controller: roleController,
              labelText: 'Role',
              hintText: 'Enter your role',
              prefixIcon: Icons.work_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your role';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            _SaveButton(isSaving: isSaving, onPressed: onSaveProfile),
          ],
        ),
      ),
    );
  }
}

class _ProfileImagePicker extends StatelessWidget {
  const _ProfileImagePicker({
    required this.profileImage,
    required this.profileImageUrl,
    required this.onPickImage,
  });

  final File? profileImage;
  final String? profileImageUrl;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[300],
            backgroundImage: _getImageProvider(),
            child:
                _getImageProvider() == null
                    ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                    : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: IconButton(
                onPressed: onPickImage,
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _getImageProvider() {
    if (profileImage != null) {
      return FileImage(profileImage!);
    } else if (profileImageUrl != null) {
      return NetworkImage(profileImageUrl!);
    }
    return null;
  }
}

class _CustomTextFormField extends StatelessWidget {
  const _CustomTextFormField({
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isSaving, required this.onPressed});

  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isSaving ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child:
          isSaving
              ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : const Text(
                'Save Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
    );
  }
}
