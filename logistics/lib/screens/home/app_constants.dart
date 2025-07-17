class AppConstants {
  // App Information
  static const String appName = 'Fuel Card Management';
  static const String appVersion = '1.0.0';
  
  // Fuel Types
  static const List<String> fuelTypes = [
    'diesel',
    'petrol',
    'gasoline',
    'electric',
    'hybrid',
    'lng',
    'cng',
  ];
  
  // Card Types
  static const List<String> cardTypes = [
    'fleet',
    'individual',
    'temporary',
    'emergency',
  ];
  
  // Status Types
  static const List<String> cardStatuses = [
    'active',
    'inactive',
    'suspended',
    'expired',
    'lost',
    'stolen',
  ];
  
  static const List<String> assignmentStatuses = [
    'active',
    'pending',
    'completed',
    'cancelled',
    'expired',
  ];
  
  static const List<String> lockerStatuses = [
    'active',
    'maintenance',
    'offline',
    'full',
  ];
  
  static const List<String> slotStatuses = [
    'available',
    'occupied',
    'reserved',
    'maintenance',
    'out_of_order',
  ];
  
  // Validation Constants
  static const int minCardNumberLength = 16;
  static const int maxCardNumberLength = 19;
  static const int cvvLength = 3;
  static const int pinLength = 4;
  
  // Business Rules
  static const double defaultSpendingLimit = 1000.0;
  static const double maxDailyLimit = 500.0;
  static const int maxTransactionsPerDay = 10;
  static const Duration cardExpiryPeriod = Duration(days: 365 * 2); // 2 years
  static const Duration assignmentTimeout = Duration(hours: 24);
  static const Duration pickupCodeExpiry = Duration(hours: 12);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Network
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  
  // Storage Keys
  static const String userPrefsKey = 'user_preferences';
  static const String authTokenKey = 'auth_token';
  static const String lastSyncKey = 'last_sync';
  
  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String dateTimeFormat = 'MMM dd, yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
  
  // Currency
  static const String currencySymbol = '\$';
  static const String currencyCode = 'USD';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
