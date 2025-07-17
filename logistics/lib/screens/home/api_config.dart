class ApiConfig {
  static const String baseUrl = 'https://api.yourapp.com/v1';
  static const String fuelCardEndpoint = '/fuel-cards';
  static const String transactionsEndpoint = '/fuel-transactions';
  static const String assignmentsEndpoint = '/fuel-card-assignments';
  static const String lockersEndpoint = '/fuel-card-lockers';
  
  // API Keys and Authentication
  static const String apiKey = 'your-api-key-here';
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Fuel Card Limits
  static const double maxSpendingLimit = 10000.0;
  static const double minSpendingLimit = 50.0;
  
  // Transaction Limits
  static const double maxTransactionAmount = 500.0;
  static const int maxTransactionsPerDay = 10;
  
  // Locker Configuration
  static const int maxSlotsPerLocker = 50;
  static const Duration pickupCodeExpiry = Duration(hours: 24);
}
