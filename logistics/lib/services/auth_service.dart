import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/supabase_error_handler.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = false;
  String? _role;

  bool get isLoading => _isLoading;
  User? get currentUser => _supabase.auth.currentUser;
  String? get role => _role;
  bool get isAuthenticated => currentUser != null;

  Future<void> initialize() async {
    _setLoading(true);
    try {
      if (currentUser != null) {
        _role = await getUserRole(currentUser!.id);
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<String?> signIn(String email, String password) async {
    try {
      _setLoading(true);
      
      // Use standard Supabase auth
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Authentication failed: Invalid credentials');
      }

      // Try to get user role from JWT claims first (safer)
      _role = getUserRoleFromJWT(response.user!) ?? 'user';
      
      return _role;
    } catch (e) {
      // Use the error handler to get user-friendly messages
      throw Exception(SupabaseErrorHandler.getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Get user role from JWT claims without querying the database
  String? getUserRoleFromJWT(User user) {
    try {
      // Check user metadata first
      final userRole = user.userMetadata?['role'] as String?;
      if (userRole != null) return userRole;
      
      // Check app metadata
      final appRole = user.appMetadata['role'] as String?;
      if (appRole != null) return appRole;
      
      // Fallback: check email patterns for admin access
      final email = user.email?.toLowerCase() ?? '';
      if (email == 'abdulssekyanzi@gmail.com' || 
          email.contains('admin@') ||
          email.endsWith('@admin.com')) {
        return 'admin';
      }
      
      return 'user';
    } catch (e) {
      debugPrint('Error getting role from JWT: $e');
      return 'user';
    }
  }



  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _role = null;
    notifyListeners();
  }

  Future<AuthResponse> signUp(
    String email,
    String password, {
    String? fullName,
    String? phone,
    String? role = 'user',
    String? profileImage,
  }) async {
    _setLoading(true);
    try {
      // Sign up with Supabase auth - bypass email confirmation for development
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null, // Bypass email confirmation
        data: {
          'full_name': fullName,
          'phone': phone,
          'role': role,
          'profile_image': profileImage,
        },
      );

      if (response.user != null) {
        _role = role ?? 'user';
        
        // Handle user profile creation/update using upsert
        try {
          await _supabase.from('users').upsert(
            {
              'id': response.user!.id,
              'email': email,
              'full_name': fullName,
              'phone': phone,
              'role': role ?? 'user',
              'profile_image': profileImage,
              'updated_at': DateTime.now().toIso8601String(),
            },
            onConflict: 'id',
          );
          debugPrint('User profile created/updated successfully');
        } catch (profileError) {
          debugPrint('Note: User profile creation error: $profileError');
          // Try alternative approach if upsert fails
          try {
            bool userExists = false;
            try {
              // Try to get existing user
              await _supabase
                  .from('users')
                  .select()
                  .eq('id', response.user!.id)
                  .single();
              userExists = true;
            } catch (e) {
              userExists = false;
            }
            
            if (userExists) {
              // Update existing user
              await _supabase
                  .from('users')
                  .update({
                    'email': email,
                    'full_name': fullName,
                    'phone': phone,
                    'role': role ?? 'user',
                    'profile_image': profileImage,
                    'updated_at': DateTime.now().toIso8601String(),
                  })
                  .eq('id', response.user!.id);
            } else {
              // Insert new user
              await _supabase.from('users').insert({
                'id': response.user!.id,
                'email': email,
                'full_name': fullName,
                'phone': phone,
                'role': role ?? 'user',
                'profile_image': profileImage,
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              });
            }
          } catch (fallbackError) {
            debugPrint('Fallback profile creation also failed: $fallbackError');
          }
        }
      }

      return response;
    } catch (e) {
      // Use the error handler to get user-friendly messages
      throw Exception(SupabaseErrorHandler.getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> updateUserRole(String userId, String role) async {
    await _supabase.from('users').update({'role': role}).eq('id', userId);
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response =
          await _supabase.from('users').select().eq('id', userId).maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  Future<String?> getUserRole(String userId) async {
    try {
      final response =
          await _supabase
              .from('users')
              .select('role')
              .eq('id', userId)
              .maybeSingle();
      return response?['role'] as String?;
    } catch (e) {
      debugPrint('Error getting user role: $e');
      return null;
    }
  }

  Future<bool> isCurrentUserAdmin() async {
    if (currentUser == null) return false;
    
    // Use JWT-based role checking to avoid database issues
    final role = getUserRoleFromJWT(currentUser!);
    return role == 'admin' || role == 'other_admin';
  }

  /// Safe admin check using only JWT claims (no database queries)
  bool isCurrentUserAdminSafe() {
    if (currentUser == null) return false;
    final role = getUserRoleFromJWT(currentUser!);
    return role == 'admin' || role == 'other_admin';
  }

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (currentUser == null) return null;
    return await getUserProfile(currentUser!.id);
  }

  Future<void> updateCurrentUserProfile({
    String? fullName,
    String? phone,
    String? profileImage,
  }) async {
    if (currentUser == null) throw Exception('No user logged in');
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (profileImage != null) updates['profile_image'] = profileImage;

      await _supabase.from('users').update(updates).eq('id', currentUser!.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  void listenToAuthChanges() {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session?.user.id != currentUser?.id) {
        initialize();
      }
    });
  }

  /// Check if current user's email is confirmed
  bool get isEmailConfirmed {
    final user = currentUser;
    if (user == null) return false;
    return user.emailConfirmedAt != null;
  }
}
