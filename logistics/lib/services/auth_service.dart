import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = false;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Loading state
  bool get isLoading => _isLoading;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Sign in with email and password using edge function
  Future<String?> signIn(String email, String password) async {
    try {
      _setLoading(true);
      final response = await _supabase.functions.invoke(
        'custom_login',
        body: {'email': email, 'password': password},
      );

      if (response.data['error'] != null) {
        throw Exception(response.data['error']);
      }

      final session = response.data['session'];
      final role = response.data['role'] as String?;

      if (session != null && session['access_token'] != null) {
        await _supabase.auth.setSession(session['access_token']);
      } else if (role != null) {
        // Fallback to direct sign-in if session is missing but role is available
        await signInDirect(email, password);
      }

      if (role == null) {
        final fallbackRole = await getUserRole(
          _supabase.auth.currentUser?.id ?? (await _getUserIdFromEmail(email))!,
        );
        return fallbackRole ?? 'user'; // Default to 'user' if no role found
      }

      return role;
    } on Exception catch (e) {
      if (e.toString().contains('FunctionException') &&
          e.toString().contains('404')) {
        // Fallback to direct sign-in if custom_login is not found
        return await signInDirect(email, password);
      }
      throw Exception('Authentication error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Alternative sign in method using direct Supabase auth
  Future<String?> signInDirect(String email, String password) async {
    try {
      _setLoading(true);
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Authentication failed: No user found');
      }

      final userRole = await getUserRole(response.user!.id);
      return userRole ?? 'user'; // Default to 'user' if no role found
    } catch (e) {
      throw Exception('Authentication error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to get user ID from email (for fallback)
  Future<String?> _getUserIdFromEmail(String email) async {
    try {
      final response =
          await _supabase
              .from('auth.users')
              .select('id')
              .eq('email', email)
              .maybeSingle();
      return response?['id'] as String?;
    } catch (e) {
      debugPrint('Error getting user ID: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    notifyListeners();
  }

  // Sign up with email and password
  Future<AuthResponse> signUp(
    String email,
    String password, {
    String? fullName,
    String? phone,
    String? role,
    String? profileImage,
  }) async {
    _setLoading(true);
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'role': role ?? 'user',
          'profile_image': profileImage,
        },
      );

      if (response.user != null) {
        await _supabase.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'phone': phone,
          'role': role ?? 'user',
          'profile_image': profileImage,
        });
      }

      return response;
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // Update user role (admin function)
  Future<void> updateUserRole(String userId, String role) async {
    await _supabase.from('users').update({'role': role}).eq('id', userId);
    notifyListeners();
  }

  // Get user profile
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

  // Get user role
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

  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    if (currentUser == null) return false;
    final role = await getUserRole(currentUser!.id);
    return role == 'admin' || role == 'other_admin';
  }

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (currentUser == null) return null;
    return await getUserProfile(currentUser!.id);
  }

  // Update current user profile
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

  // Listen to auth state changes
  void listenToAuthChanges() {
    _supabase.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }
}
