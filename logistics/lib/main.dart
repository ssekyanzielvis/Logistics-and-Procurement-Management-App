// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistics/utils/db_migrations.dart';
import 'package:logistics/screens/admin/admin_dashboard.dart';
import 'package:logistics/screens/admin/admin_login_page.dart';
import 'package:logistics/screens/admin/other_admin_login_page.dart';
import 'package:logistics/screens/admin/admin_register_page.dart';
import 'package:logistics/screens/admin/other_admin_register_page.dart';
import 'package:logistics/screens/auth/register_screen.dart';
import 'package:logistics/screens/client/client_dashboard.dart';
import 'package:logistics/screens/driver/driver_dashboard.dart';
import 'package:logistics/screens/home/client_login_page.dart';
import 'package:logistics/screens/home/home_page.dart';
import 'package:logistics/screens/home/fuel_card_routes.dart';
import 'package:logistics/providers/auth_provider.dart';
import 'package:logistics/providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    debugPrint("Loaded .env file successfully");
  } catch (e) {
    debugPrint("Error loading .env file: $e");
    // Fall back to hardcoded values if .env file cannot be loaded
  }
  
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'https://awjryaofcfuhyofqfixo.supabase.co';
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF3anJ5YW9mY2Z1aHlvZnFmaXhvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc0MzA5MjYsImV4cCI6MjA3MzAwNjkyNn0.3ccRaiv7odT4xL6jI0f5dV9BrMnZw8LUeofJZ0ZOo5c';
  
  debugPrint("Initializing Supabase with URL: $supabaseUrl");
  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    debugPrint("Supabase initialized successfully");
    
    // Run database migrations to fix schema issues
    final migrations = DatabaseMigrations(Supabase.instance.client);
    await migrations.runMigrations().catchError((e) {
      debugPrint("Migration error (non-fatal): $e");
    });
  } catch (e) {
    debugPrint("Error initializing Supabase: $e");
    // Continue with the app, errors will be handled in specific screens
  }

  runApp(const ProviderScope(child: LogisticsApp()));
}

class LogisticsApp extends ConsumerWidget {
  const LogisticsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final appTheme = ref.watch(appThemeProvider);

        return MaterialApp(
          title: 'Logistics Management',
          theme: appTheme,
          themeMode: ThemeMode.light, // Use explicit theme mode to prevent system theme issues
          home: const AuthWrapper(),
          routes: {
            '/login': (context) => const LoginPage(),
            '/client-or-driver-register': (context) => const RegisterScreen(),
            '/admin-login': (context) => const AdminLoginPage(),
            '/other-admin-login': (context) => const OtherAdminLoginPage(),
            '/admin-register': (context) => const AdminRegisterPage(),
            '/other-admin-register': (context) => const OtherAdminRegisterPage(),
            ...FuelCardRoutes.getRoutes(),
          },
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final authService = ref.watch(authServiceProvider);

        if (authService.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!authService.isAuthenticated) {
          return const HomePage();
        }

        switch (authService.role) {
          case 'admin':
            return const AdminDashboard();
          case 'client':
            return const ClientDashboard();
          case 'driver':
            return const DriverDashboard();
          default:
            return const HomePage();
        }
      },
    );
  }
}
