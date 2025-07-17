import 'package:flutter/material.dart';
import 'package:logistics/screens/admin/admin_dashboard.dart';
import 'package:logistics/screens/admin/admin_login_page.dart';
import 'package:logistics/screens/admin/other_admin_login_page.dart';
import 'package:logistics/screens/admin/admin_register_page.dart'; // Add this import
import 'package:logistics/screens/admin/other_admin_register_page.dart';
import 'package:logistics/screens/auth/register_screen.dart';
import 'package:logistics/screens/client/client_dashboard.dart';
import 'package:logistics/screens/driver/driver_dashboard.dart';
import 'package:logistics/screens/home/client_login_page.dart';
import 'package:logistics/screens/home/home_page.dart';
import 'package:logistics/screens/home/fuel_card_routes.dart';
import 'package:logistics/services/auth_service.dart';
import 'package:logistics/services/location_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: ".env");

  // Initialize Supabase with environment variables
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const LogisticsApp());
}

class LogisticsApp extends StatelessWidget {
  const LogisticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
      ],
      child: MaterialApp(
        title: 'Logistics Management',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
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
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (authService.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authService.currentUser == null) {
          return const HomePage();
        }

        // Route based on user role
        switch (authService.currentUser!.role) {
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
