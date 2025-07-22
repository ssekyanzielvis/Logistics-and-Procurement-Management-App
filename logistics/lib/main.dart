// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:logistics/providers/settings_provider.dart';
import 'package:logistics/providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const ProviderScope(child: LogisticsApp()));
}

class LogisticsApp extends ConsumerWidget {
  const LogisticsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final appTheme = ref.watch(appThemeProvider);

    return MaterialApp(
      title: 'Logistics Management',
      theme: appTheme,
      themeMode: settings.themeMode,
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
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);

    if (authService.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
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
  }
}
