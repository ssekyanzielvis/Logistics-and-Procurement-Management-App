import 'package:flutter/material.dart';
import 'package:logistics/screens/admin/admin_dashboard.dart';
import 'package:logistics/screens/auth/login_screen.dart';
import 'package:logistics/screens/client/client_dashboard.dart';
import 'package:logistics/screens/driver/driver_dashboard.dart';
import 'package:logistics/services/auth_service.dart';
import 'package:logistics/services/location_service.dart';
import 'package:logistics/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
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
          return const LoginScreen();
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
            return const LoginScreen();
        }
      },
    );
  }
}
