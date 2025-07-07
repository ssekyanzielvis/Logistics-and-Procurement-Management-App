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
        // Create admin user if not exists
        await _createOrGetAdminUser();
        return true;
      }

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

  Future<void> _createOrGetAdminUser() async {
    try {
      // Check if admin user exists
      final existingAdmin =
          await _supabase
              .from('users')
              .select()
              .eq('email', AppConstants.adminId)
              .maybeSingle();

      if (existingAdmin == null) {
        // Create admin user
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
    }
  }

  Future<bool> signUp(
    String email,
    String password,
    String fullName,
    String phone,
    String role,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create user profile
        final userData = {
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'phone': phone,
          'role': role,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        };

        await _supabase.from('users').insert(userData);
        _currentUser = UserModel.fromJson(userData);
        return true;
      }
      return false;
    } catch (e) {
      print('Sign up error: $e');
      return false;
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
