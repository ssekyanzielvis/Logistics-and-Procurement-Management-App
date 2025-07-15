import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminAuth {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tokenKey = 'admin_auth_token';

  // Register a new admin
  static Future<bool> registerAdmin({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String? profileImageUrl,
  }) async {
    try {
      // 1. Sign up the user with Supabase Auth
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'profile_image': profileImageUrl ?? '', // Handle null
          'role': 'admin',
        },
      );

      if (res.user == null) {
        debugPrint(
          'Registration failed: No user created in auth.users for email: $email',
        );
        throw Exception('User creation failed: No user returned from signUp');
      }

      // 2. Verify user exists in auth.users
      final userCheck =
          await _supabase
              .from('auth.users')
              .select('id')
              .eq('id', res.user!.id)
              .maybeSingle();
      if (userCheck == null) {
        debugPrint('User ${res.user!.id} not found in auth.users after signUp');
        throw Exception('User not found in auth.users after signUp');
      }

      // 3. Insert admin details into the 'admins' table
      final adminData = {
        'id': res.user!.id,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'profile_image': profileImageUrl ?? '', // Handle null
        'role': 'admin',
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      };

      try {
        await _supabase.from('admins').insert(adminData);
        debugPrint(
          'Successfully inserted admin data for user: ${res.user!.id}',
        );
      } catch (e) {
        debugPrint('Error saving admin data to admins table: $e');
        // Rollback user creation
        try {
          await _supabase.auth.admin.deleteUser(res.user!.id);
          debugPrint('Rolled back user creation for ID: ${res.user!.id}');
        } catch (rollbackError) {
          debugPrint('Error during user deletion rollback: $rollbackError');
        }
        throw Exception('Failed to save admin data: $e');
      }

      return true;
    } on AuthRetryableFetchException catch (e) {
      debugPrint('Retryable error during admin registration: ${e.message}');
      throw Exception('Server error, please try again later: ${e.message}');
    } on PostgrestException catch (e) {
      debugPrint(
        'Postgrest error during admin registration: ${e.message}, details: ${e.details}',
      );
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      debugPrint('General error during admin registration: $e');
      throw Exception('Registration failed: $e');
    }
  }

  // Login admin
  static Future<bool> loginAdmin({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) {
        debugPrint('Login failed: No user returned for email: $email');
        return false;
      }

      // Verify the user has admin role
      try {
        final userData =
            await _supabase
                .from('admins')
                .select()
                .eq('id', res.user!.id)
                .single();

        if (userData['role'] != 'admin') {
          await _supabase.auth.signOut();
          debugPrint(
            'Login AscendingFileAccessException: User ${res.user!.id} is not an admin',
          );
          return false;
        }
      } catch (e) {
        debugPrint('Error verifying admin role: $e');
        await _supabase.auth.signOut();
        return false;
      }

      await _saveToken(res.session!.accessToken);
      debugPrint('Admin login successful for user: ${res.user!.id}');
      return true;
    } catch (e) {
      debugPrint('Error during admin login: $e');
      return false;
    }
  }

  // Save token to shared preferences
  static Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      debugPrint('Token saved successfully');
    } catch (e) {
      debugPrint('Error saving token: $e');
      throw Exception('Failed to save token: $e');
    }
  }

  // Get stored token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      debugPrint('Retrieved token: ${token != null ? 'Found' : 'Not found'}');
      return token;
    } catch (e) {
      debugPrint('Error retrieving token: $e');
      return null;
    }
  }

  // Check if admin is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        debugPrint('No active session found');
        return false;
      }

      // Verify the session is still valid
      try {
        final userData =
            await _supabase
                .from('admins')
                .select()
                .eq('id', session.user.id)
                .single();

        final isAdmin = userData['role'] == 'admin';
        debugPrint('Admin status check: ${isAdmin ? 'Admin' : 'Not admin'}');
        return isAdmin;
      } catch (e) {
        debugPrint('Error verifying admin session: $e');
        return false;
      }
    } catch (e) {
      debugPrint('Error checking admin login status: $e');
      return false;
    }
  }

  // Get current admin ID
  static String? getAdminId() {
    final userId = _supabase.auth.currentUser?.id;
    debugPrint('Current admin ID: ${userId ?? 'None'}');
    return userId;
  }

  // Get current admin data
  static Future<Map<String, dynamic>?> getAdminData() async {
    try {
      final userId = getAdminId();
      if (userId == null) {
        debugPrint('No admin ID found for fetching admin data');
        return null;
      }

      final response =
          await _supabase.from('admins').select().eq('id', userId).single();

      debugPrint('Admin data retrieved for user: $userId');
      return response;
    } catch (e) {
      debugPrint('Error getting admin data: $e');
      return null;
    }
  }

  // Logout admin
  static Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      debugPrint('Admin logged out successfully');
    } catch (e) {
      debugPrint('Error during logout: $e');
      throw Exception('Logout failed: $e');
    }
  }
}
