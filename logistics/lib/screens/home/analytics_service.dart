import '../../models/fuel_card_models.dart';

class FuelAnalytics {
  final double totalSpent;
  final double totalQuantity;
  final double averagePricePerUnit;
  final int transactionCount;
  final Map<TransactionType, double> spendingByType;
  final Map<String, double> spendingByStation;
  final Map<String, double> quantityByFuelCard;

  const FuelAnalytics({
    required this.totalSpent,
    required this.totalQuantity,
    required this.averagePricePerUnit,
    required this.transactionCount,
    required this.spendingByType,
    required this.spendingByStation,
    required this.quantityByFuelCard,
  });
}

class MonthlyAnalytics {
  final int month;
  final int year;
  final double totalSpent;
  final double totalQuantity;
  final int transactionCount;
  final double averagePerTransaction;

  const MonthlyAnalytics({
    required this.month,
    required this.year,
    required this.totalSpent,
    required this.totalQuantity,
    required this.transactionCount,
    required this.averagePerTransaction,
  });
}

class AnalyticsService {
  /// Calculate comprehensive fuel analytics from transactions
  static FuelAnalytics calculateAnalytics(List<FuelTransaction> transactions) {
    if (transactions.isEmpty) {
      return const FuelAnalytics(
        totalSpent: 0,
        totalQuantity: 0,
        averagePricePerUnit: 0,
        transactionCount: 0,
        spendingByType: {},
        spendingByStation: {},
        quantityByFuelCard: {},
      );
    }

    double totalSpent = 0;
    double totalQuantity = 0;
    final Map<TransactionType, double> spendingByType = {};
    final Map<String, double> spendingByStation = {};
    final Map<String, double> quantityByFuelCard = {};

    for (final transaction in transactions) {
      totalSpent += transaction.amount;
      totalQuantity += transaction.quantity;

      // Group by transaction type
      spendingByType[transaction.type] = 
          ((spendingByType[transaction.type] ?? 0) + transaction.amount).toDouble();

      // Group by station
      spendingByStation[transaction.station] = 
          ((spendingByStation[transaction.station] ?? 0) + transaction.amount).toDouble();

      // Group by fuel card
      quantityByFuelCard[transaction.fuelCardId] = 
          ((quantityByFuelCard[transaction.fuelCardId] ?? 0) + transaction.quantity).toDouble();
    }

    final averagePricePerUnit = totalQuantity > 0 ? totalSpent / totalQuantity : 0;

    return FuelAnalytics(
      totalSpent: totalSpent,
      totalQuantity: totalQuantity,
      averagePricePerUnit: averagePricePerUnit,
      transactionCount: transactions.length,
      spendingByType: spendingByType,
      spendingByStation: spendingByStation,
      quantityByFuelCard: quantityByFuelCard,
    );
  }
  /// Calculate analytics for fuel transactions only (excluding other types)
  static FuelAnalytics calculateFuelOnlyAnalytics(List<FuelTransaction> transactions) {
    final fuelTransactions = transactions
        .where((transaction) => transaction.type == TransactionType.fuel)
        .toList();
    return calculateAnalytics(fuelTransactions);
  }

  /// Calculate analytics by transaction type
  static Map<TransactionType, FuelAnalytics> calculateAnalyticsByType(
      List<FuelTransaction> transactions) {
    final Map<TransactionType, FuelAnalytics> analyticsByType = {};

    for (final type in TransactionType.values) {
      final typeTransactions = transactions
          .where((transaction) => transaction.type == type)
          .toList();
      analyticsByType[type] = calculateAnalytics(typeTransactions);
    }

    return analyticsByType;
  }

  /// Calculate monthly analytics
  static List<MonthlyAnalytics> calculateMonthlyAnalytics(
      List<FuelTransaction> transactions) {
    final Map<String, List<FuelTransaction>> monthlyGrouped = {};

    // Group transactions by month-year
    for (final transaction in transactions) {
      final date = transaction.transactionDate;
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      monthlyGrouped[key] ??= [];
      monthlyGrouped[key]!.add(transaction);
    }

    // Calculate analytics for each month
    final List<MonthlyAnalytics> monthlyAnalytics = [];
    for (final entry in monthlyGrouped.entries) {
      final keyParts = entry.key.split('-');
      final year = int.parse(keyParts[0]);
      final month = int.parse(keyParts[1]);
      final transactions = entry.value;

      final totalSpent = transactions.fold<double>(
          0, (sum, transaction) => sum + transaction.amount);
      final totalQuantity = transactions.fold<double>(
          0, (sum, transaction) => sum + transaction.quantity);
      final transactionCount = transactions.length;
      final averagePerTransaction = transactionCount > 0 ? totalSpent / transactionCount : 0;

      monthlyAnalytics.add(MonthlyAnalytics(
        month: month,
        year: year,
        totalSpent: totalSpent,
        totalQuantity: totalQuantity,
        transactionCount: transactionCount,
        averagePerTransaction: averagePerTransaction,
      ));
    }

    // Sort by year-month
    monthlyAnalytics.sort((a, b) {
      final aDate = DateTime(a.year, a.month);
      final bDate = DateTime(b.year, b.month);
      return aDate.compareTo(bDate);
    });

    return monthlyAnalytics;
  }

  /// Get top spending stations
  static List<MapEntry<String, double>> getTopStations(
      List<FuelTransaction> transactions, {int limit = 5}) {
    final Map<String, double> stationSpending = {};

    for (final transaction in transactions) {
      stationSpending[transaction.station] = 
          (stationSpending[transaction.station] ?? 0) + transaction.amount;
    }

    final sortedStations = stationSpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedStations.take(limit).toList();
  }

  /// Get fuel card usage statistics
  static Map<String, double> getFuelCardUsage(List<FuelTransaction> transactions) {
    final Map<String, double> cardUsage = {};

    for (final transaction in transactions) {
      cardUsage[transaction.fuelCardId] = 
          (cardUsage[transaction.fuelCardId] ?? 0) + transaction.amount;
    }

    return cardUsage;
  }

  /// Calculate efficiency metrics
  static Map<String, double> calculateEfficiencyMetrics(
      List<FuelTransaction> transactions) {
    if (transactions.isEmpty) return {};

    final fuelTransactions = transactions
        .where((t) => t.type == TransactionType.fuel)
        .toList();

    if (fuelTransactions.isEmpty) return {};

    final totalAmount = fuelTransactions.fold<double>(
        0, (sum, t) => sum + t.amount);
    final totalQuantity = fuelTransactions.fold<double>(
        0, (sum, t) => sum + t.quantity);
    
    return {
      'averagePricePerUnit': totalQuantity > 0 ? totalAmount / totalQuantity : 0,
      'totalSpent': totalAmount,
      'totalQuantity': totalQuantity,
      'transactionCount': fuelTransactions.length.toDouble(),
      'averageTransactionAmount': fuelTransactions.isNotEmpty 
          ? totalAmount / fuelTransactions.length 
          : 0,
    };
  }

  /// Filter transactions by date range
  static List<FuelTransaction> filterByDateRange(
      List<FuelTransaction> transactions,
      DateTime startDate,
      DateTime endDate) {
    return transactions.where((transaction) {
      final date = transaction.transactionDate;
      return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Filter transactions by fuel card
  static List<FuelTransaction> filterByFuelCard(
      List<FuelTransaction> transactions,
      String fuelCardId) {
    return transactions
        .where((transaction) => transaction.fuelCardId == fuelCardId)
        .toList();
  }

  /// Filter transactions by station
  static List<FuelTransaction> filterByStation(
      List<FuelTransaction> transactions,
      String station) {
    return transactions
        .where((transaction) => transaction.station == station)
        .toList();
  }

  /// Get spending trends over time
  static List<MapEntry<DateTime, double>> getSpendingTrends(
      List<FuelTransaction> transactions,
      {Duration groupBy = const Duration(days: 30)}) {
    if (transactions.isEmpty) return [];

    // Sort transactions by date
    final sortedTransactions = List<FuelTransaction>.from(transactions)
      ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

    final Map<DateTime, double> trends = {};
    final startDate = sortedTransactions.first.transactionDate;
    final endDate = sortedTransactions.last.transactionDate;

    // Create time buckets
    DateTime currentDate = DateTime(startDate.year, startDate.month, startDate.day);
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final periodEnd = currentDate.add(groupBy);
      final periodTransactions = transactions.where((t) =>
          t.transactionDate.isAfter(currentDate.subtract(const Duration(seconds: 1))) &&
          t.transactionDate.isBefore(periodEnd)).toList();

      final totalSpending = periodTransactions.fold<double>(
          0, (sum, t) => sum + t.amount);

      trends[currentDate] = totalSpending;
      currentDate = periodEnd;
    }

    return trends.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }
}