// lib/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistics/services/auth_service.dart';

final authServiceProvider = ChangeNotifierProvider<AuthService>((ref) {
  final authService = AuthService();
  authService.initialize();
  authService.listenToAuthChanges();
  return authService;
});
