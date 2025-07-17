import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fuel_card_models.dart';

class FuelCardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fuel Card Management
  Future<List<FuelCard>> getFuelCards({String? status}) async {
    var query = _supabase.from('fuel_cards').select();
    
    if (status != null) {
      query = query.eq('status', status);
    }
    
    final response = await query.order('created_at', ascending: false);
    return (response as List).map((json) => FuelCard.fromJson(json)).toList();
  }

  Future<FuelCard> createFuelCard({
    required String cardNumber,
    required String cardType,
    required double spendingLimit,
    required List<String> fuelTypeRestrictions,
  }) async {
    final response = await _supabase.from('fuel_cards').insert({
      'card_number': cardNumber,
      'card_type': cardType,
      'spending_limit': spendingLimit,
      'fuel_type_restrictions': fuelTypeRestrictions,
      'current_balance': spendingLimit,
    }).select().single();

    return FuelCard.fromJson(response);
  }

  Future<void> updateFuelCardStatus(String cardId, String status) async {
    await _supabase.from('fuel_cards').update({
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', cardId);
  }

  // Driver Assignments
  Future<List<FuelCardAssignment>> getDriverAssignments(String driverId) async {
    final response = await _supabase
        .from('fuel_card_assignments')
        .select('*, fuel_cards(*)')
        .eq('driver_id', driverId)
        .order('assigned_at', ascending: false);

    return (response as List).map((json) => FuelCardAssignment.fromJson(json)).toList();
  }

  Future<FuelCardAssignment> assignFuelCard({
    required String fuelCardId,
    required String driverId,
    String? routeId,
    String? vehicleId,
    double? expectedConsumption,
    String? pickupLocation,
    DateTime? expiresAt,
  }) async {
    // Generate pickup code
    final pickupCode = _generatePickupCode();

    final response = await _supabase.from('fuel_card_assignments').insert({
      'fuel_card_id': fuelCardId,
      'driver_id': driverId,
      'route_id': routeId,
      'vehicle_id': vehicleId,
      'expected_consumption': expectedConsumption,
      'pickup_location': pickupLocation,
      'pickup_code': pickupCode,
      'expires_at': expiresAt?.toIso8601String(),
    }).select('*, fuel_cards(*)').single();

    // Update fuel card status
    await updateFuelCardStatus(fuelCardId, 'assigned');

    return FuelCardAssignment.fromJson(response);
  }

  Future<void> updateAssignmentStatus(String assignmentId, String status) async {
    await _supabase.from('fuel_card_assignments').update({
      'status': status,
    }).eq('id', assignmentId);
  }

  // Fuel Transactions
  Future<List<FuelTransaction>> getFuelTransactions({
    String? fuelCardId,
    String? assignmentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _supabase.from('fuel_transactions').select();

    if (fuelCardId != null) query = query.eq('fuel_card_id', fuelCardId);
    if (assignmentId != null) query = query.eq('assignment_id', assignmentId);
    if (startDate != null) query = query.gte('transaction_date', startDate.toIso8601String());
    if (endDate != null) query = query.lte('transaction_date', endDate.toIso8601String());

    final response = await query.order('transaction_date', ascending: false);
    return (response as List).map((json) => FuelTransaction.fromJson(json)).toList();
  }

  Future<FuelTransaction> recordFuelTransaction({
    required String fuelCardId,
    String? assignmentId,
    required double amount,
    required String fuelType,
    double? liters,
    String? stationName,
    String? stationLocation,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _supabase.from('fuel_transactions').insert({
      'fuel_card_id': fuelCardId,
      'assignment_id': assignmentId,
      'amount': amount,
      'fuel_type': fuelType,
      'liters': liters,
      'station_name': stationName,
      'station_location': stationLocation,
      'latitude': latitude,
      'longitude': longitude,
    }).select().single();

    // Update fuel card balance
    await _updateFuelCardBalance(fuelCardId, amount);

    return FuelTransaction.fromJson(response);
  }

  // Fuel Card Lockers
  Future<List<FuelCardLocker>> getFuelCardLockers() async {
    final response = await _supabase
        .from('fuel_card_lockers')
        .select()
        .eq('status', 'active')
        .order('location_name');

    return (response as List).map((json) => FuelCardLocker.fromJson(json)).toList();
  }

  // Route & Consumption Calculation
  Future<double> calculateExpectedFuelConsumption({
    required double distance,
    required String vehicleType,
    double? loadWeight,
  }) async {
    // This is a simplified calculation - you can make it more sophisticated
    double baseConsumption = _getBaseConsumption(vehicleType);
    double loadFactor = loadWeight != null ? (loadWeight / 1000) * 0.1 : 0;
    
    return distance * (baseConsumption + loadFactor);
  }

  // Helper methods
  String _generatePickupCode() {
    return (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
  }

  double _getBaseConsumption(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'truck':
        return 0.35; // 35L per 100km
      case 'van':
        return 0.12; // 12L per 100km
      case 'car':
        return 0.08; // 8L per 100km
      default:
        return 0.15; // Default consumption
    }
  }

  Future<void> _updateFuelCardBalance(String cardId, double amount) async {
    final card = await _supabase
        .from('fuel_cards')
        .select('current_balance')
        .eq('id', cardId)
        .single();

    final currentBalance = card['current_balance'] as double;
    final newBalance = currentBalance - amount;

    await _supabase.from('fuel_cards').update({
      'current_balance': newBalance,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', cardId);
  }
}
