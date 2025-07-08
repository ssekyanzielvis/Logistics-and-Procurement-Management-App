import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logistics/models/user.dart';
import 'package:logistics/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  AuthService() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _loadUserProfile(session.user.id);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      final response =
          await _supabase.from('users').select().eq('id', userId).single();

      _currentUser = UserModel.fromJson(response);
      notifyListeners();
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check for hard-coded admin credentials
      if (email == AppConstants.adminId &&
          password == AppConstants.adminPassword) {
        await _handleAdminAuthentication();
        return true;
      }

      // Regular user login
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!.id);
        return true;
      }
      return false;
    } catch (e) {
      print('Sign in error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _handleAdminAuthentication() async {
    try {
      // First check if admin exists in auth table
      try {
        await _supabase.auth.signInWithPassword(
          email: AppConstants.adminId,
          password: AppConstants.adminPassword,
        );
      } catch (authError) {
        // If auth fails, create admin user in auth system
        await _supabase.auth.signUp(
          email: AppConstants.adminId,
          password: AppConstants.adminPassword,
        );
      }

      // Then ensure admin profile exists
      await _createOrGetAdminUser();
    } catch (e) {
      print('Admin authentication error: $e');
      rethrow;
    }
  }

  Future<void> _createOrGetAdminUser() async {
    try {
      final existingAdmin =
          await _supabase
              .from('users')
              .select()
              .eq('email', AppConstants.adminId)
              .maybeSingle();

      if (existingAdmin == null) {
        final adminData = {
          'id': 'admin-${DateTime.now().millisecondsSinceEpoch}',
          'email': AppConstants.adminId,
          'full_name': 'System Administrator',
          'phone': '+1234567890',
          'role': AppConstants.adminRole,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        };

        await _supabase.from('users').insert(adminData);
        _currentUser = UserModel.fromJson(adminData);
      } else {
        _currentUser = UserModel.fromJson(existingAdmin);
      }
      notifyListeners();
    } catch (e) {
      print('Error creating admin user: $e');
      rethrow;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    File? profileImage,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Create auth user
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('User creation failed');
      }

      String? profileImageUrl;

      // Upload profile image to Supabase Storage if provided
      if (profileImage != null) {
        final fileName =
            '${authResponse.user!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await _supabase.storage
            .from('profile_images')
            .upload(fileName, profileImage);

        // Get the public URL of the uploaded image
        profileImageUrl = _supabase.storage
            .from('profile_images')
            .getPublicUrl(fileName);
      }

      // Create user profile
      final userData = {
        'id': authResponse.user!.id,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'role': role,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'profile_image': profileImageUrl, // Include profile image URL
      };

      await _supabase.from('users').insert(userData);
      _currentUser = UserModel.fromJson(userData);
      return true;
    } catch (e) {
      print('Sign up error: $e');
      throw Exception('Sign up error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('Sign out error: $e');
    }
  }
}
