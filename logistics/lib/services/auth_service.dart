import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        await signInDirect(email, password);
      }

      if (role == null) {
        final fallbackRole = await getUserRole(
          _supabase.auth.currentUser?.id ?? (await _getUserIdFromEmail(email))!,
        );
        return fallbackRole ?? 'user';
      }

      return role;
    } on Exception catch (e) {
      if (e.toString().contains('FunctionException') &&
          e.toString().contains('404')) {
        return await signInDirect(email, password);
      }
      throw Exception('Authentication error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

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
      return userRole ?? 'user';
    } catch (e) {
      throw Exception('Authentication error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

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
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'role': role,
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
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      return response;
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
    final role = await getUserRole(currentUser!.id);
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
}
