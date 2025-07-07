import 'dart:ui';

class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // Hard-coded Admin Credentials
  static const String adminId = '00000001';
  static const String adminPassword = '12345678';

  // App Colors
  static const primaryColor = Color(0xFF2196F3);
  static const secondaryColor = Color(0xFF4CAF50);
  static const errorColor = Color(0xFFF44336);
  static const warningColor = Color(0xFFFF9800);

  // User Roles
  static const String adminRole = 'admin';
  static const String clientRole = 'client';
  static const String driverRole = 'driver';

  // Consignment Status
  static const String statusPending = 'pending';
  static const String statusAssigned = 'assigned';
  static const String statusPickedUp = 'picked_up';
  static const String statusInTransit = 'in_transit';
  static const String statusDelivered = 'delivered';
  static const String statusCancelled = 'cancelled';
}
