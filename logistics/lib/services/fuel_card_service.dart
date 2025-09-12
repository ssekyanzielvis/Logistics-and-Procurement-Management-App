import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fuel_card_models.dart';

class FuelCardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fuel Card Management
  Future<FuelCard?> getFuelCard(String cardId) async {
    try {
      final response =
          await _supabase.from('fuel_cards').select().eq('id', cardId).single();
      return FuelCard.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch fuel card: ${e.toString()}');
    }
  }

  Future<List<FuelCard>> getAllCards({FuelCardStatus? status}) async {
    try {
      var query = _supabase.from('fuel_cards').select();

      if (status != null) {
        query = query.eq('status', status.name);
      }

      final response = await query.order('created_at', ascending: false);
      return (response as List).map((json) => FuelCard.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch fuel cards: ${e.toString()}');
    }
  }

  Future<FuelCard> addCard({
    required String cardNumber,
    required CardType cardType,
    required double spendingLimit,
    required List<String> fuelTypeRestrictions,
  }) async {
    try {
      final response =
          await _supabase
              .from('fuel_cards')
              .insert({
                'card_number': cardNumber,
                'card_type': cardType.name,
                'spending_limit': spendingLimit,
                'fuel_type_restrictions': fuelTypeRestrictions,
                'current_balance': spendingLimit,
                'status': FuelCardStatus.active.name,
              })
              .select()
              .single();

      return FuelCard.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add fuel card: ${e.toString()}');
    }
  }

  Future<void> updateCard(FuelCard card) async {
    try {
      await _supabase
          .from('fuel_cards')
          .update({
            'card_number': card.cardNumber,
            'card_type': card.cardType.name,
            'spending_limit': card.spendingLimit,
            'fuel_type_restrictions': card.fuelTypeRestrictions,
            'current_balance': card.currentBalance,
            'status': card.status.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', card.id);
    } catch (e) {
      throw Exception('Failed to update fuel card: ${e.toString()}');
    }
  }

  Future<void> deleteCard(String cardId) async {
    try {
      await _supabase.from('fuel_cards').delete().eq('id', cardId);
    } catch (e) {
      throw Exception('Failed to delete fuel card: ${e.toString()}');
    }
  }

  // Fuel Transactions
  Future<List<FuelTransaction>> getAllTransactions({
    String? fuelCardId,
    String? driverId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase.from('fuel_transactions').select();

      if (fuelCardId != null) query = query.eq('fuel_card_id', fuelCardId);
      if (driverId != null) query = query.eq('driver_id', driverId);
      if (startDate != null) {
        query = query.gte('transaction_date', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('transaction_date', endDate.toIso8601String());
      }

      final response = await query.order('transaction_date', ascending: false);
      return (response as List)
          .map((json) => FuelTransaction.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions: ${e.toString()}');
    }
  }

  Future<FuelTransaction> addTransaction({
    required String fuelCardId,
    required String? driverId,
    required String? vehicleId,
    required TransactionType type,
    required double amount,
    required double quantity,
    required double pricePerUnit,
    required String station,
    required String location,
    String? authorizationCode,
    String? receiptNumber,
  }) async {
    try {
      final response =
          await _supabase
              .from('fuel_transactions')
              .insert({
                'fuel_card_id': fuelCardId,
                'driver_id': driverId,
                'vehicle_id': vehicleId,
                'type': type.name,
                'amount': amount,
                'quantity': quantity,
                'price_per_unit': pricePerUnit,
                'station': station,
                'location': location,
                'transaction_date': DateTime.now().toIso8601String(),
                'authorization_code': authorizationCode,
                'receipt_number': receiptNumber,
              })
              .select()
              .single();

      await _updateFuelCardBalance(fuelCardId, amount);

      return FuelTransaction.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add transaction: ${e.toString()}');
    }
  }

  Future<void> updateTransaction(FuelTransaction transaction) async {
    try {
      final oldTransaction =
          await _supabase
              .from('fuel_transactions')
              .select('amount, fuel_card_id')
              .eq('id', transaction.id)
              .single();

      await _supabase
          .from('fuel_transactions')
          .update({
            'fuel_card_id': transaction.fuelCardId,
            'driver_id': transaction.driverId,
            'vehicle_id': transaction.vehicleId,
            'type': transaction.type.name,
            'amount': transaction.amount,
            'quantity': transaction.quantity,
            'price_per_unit': transaction.pricePerUnit,
            'station': transaction.station,
            'location': transaction.location,
            'transaction_date': transaction.transactionDate.toIso8601String(),
            'authorization_code': transaction.authorizationCode,
            'receipt_number': transaction.receiptNumber,
          })
          .eq('id', transaction.id);

      if (oldTransaction['amount'] != transaction.amount) {
        final balanceAdjustment =
            (oldTransaction['amount'] as num).toDouble() - transaction.amount;
        await _updateFuelCardBalance(
          oldTransaction['fuel_card_id'] as String,
          -balanceAdjustment,
        );
      }
    } catch (e) {
      throw Exception('Failed to update transaction: ${e.toString()}');
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      final transaction =
          await _supabase
              .from('fuel_transactions')
              .select('amount, fuel_card_id')
              .eq('id', transactionId)
              .single();

      await _supabase
          .from('fuel_transactions')
          .delete()
          .eq('id', transactionId);

      await _updateFuelCardBalance(
        transaction['fuel_card_id'] as String,
        -(transaction['amount'] as num).toDouble(),
      );
    } catch (e) {
      throw Exception('Failed to delete transaction: ${e.toString()}');
    }
  }

  // Driver Assignments
  Future<List<FuelCardAssignment>> getAllAssignments({String? driverId}) async {
    try {
      // Check for null or empty driverId
      if (driverId != null && driverId.isEmpty) {
        // Return empty list instead of making an invalid query
        return [];
      }
      
      var query = _supabase
          .from('fuel_card_assignments')
          .select('*, fuel_cards(*)');

      if (driverId != null && driverId.isNotEmpty) {
        query = query.eq('driver_id', driverId);
      }

      final response = await query.order('assigned_date', ascending: false);
      return (response as List)
          .map((json) => FuelCardAssignment.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch assignments: ${e.toString()}');
    }
  }

  Future<FuelCardAssignment> assignCard({
    required String fuelCardId,
    required String driverId,
    required String assignedBy,
    String? vehicleId,
    String? notes,
  }) async {
    try {
      final response =
          await _supabase
              .from('fuel_card_assignments')
              .insert({
                'fuel_card_id': fuelCardId,
                'driver_id': driverId,
                'vehicle_id': vehicleId,
                'assigned_by': assignedBy,
                'assigned_date': DateTime.now().toIso8601String(),
                'notes': notes,
              })
              .select('*, fuel_cards(*)')
              .single();

      await updateFuelCardStatus(fuelCardId, FuelCardStatus.active);

      return FuelCardAssignment.fromJson(response);
    } catch (e) {
      throw Exception('Failed to assign card: ${e.toString()}');
    }
  }

  Future<void> updateAssignment(FuelCardAssignment assignment) async {
    try {
      await _supabase
          .from('fuel_card_assignments')
          .update({
            'fuel_card_id': assignment.fuelCardId,
            'driver_id': assignment.driverId,
            'vehicle_id': assignment.vehicleId,
            'assigned_by': assignment.assignedBy,
            'assigned_date': assignment.assignedDate.toIso8601String(),
            'unassigned_date': assignment.unassignedDate?.toIso8601String(),
            'notes': assignment.notes,
          })
          .eq('id', assignment.id);
    } catch (e) {
      throw Exception('Failed to update assignment: ${e.toString()}');
    }
  }

  Future<void> unassignCard(String assignmentId) async {
    try {
      final assignment =
          await _supabase
              .from('fuel_card_assignments')
              .select('fuel_card_id')
              .eq('id', assignmentId)
              .single();

      await _supabase
          .from('fuel_card_assignments')
          .update({'unassigned_date': DateTime.now().toIso8601String()})
          .eq('id', assignmentId);

      if (assignment['fuel_card_id'] != null) {
        await updateFuelCardStatus(
          assignment['fuel_card_id'] as String,
          FuelCardStatus.inactive,
        );
      }
    } catch (e) {
      throw Exception('Failed to unassign card: ${e.toString()}');
    }
  }

  // Fuel Card Lockers
  Future<List<FuelCardLocker>> getAllLockers() async {
    try {
      final response = await _supabase
          .from('fuel_card_lockers')
          .select()
          .order('name');

      return (response as List)
          .map((json) => FuelCardLocker.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch lockers: ${e.toString()}');
    }
  }

  Future<void> addLocker(FuelCardLocker locker) async {
    try {
      await _supabase.from('fuel_card_lockers').insert({
        'name': locker.name,
        'location': locker.location,
        'capacity': locker.capacity,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to add locker: ${e.toString()}');
    }
  }

  Future<void> updateLocker(FuelCardLocker locker) async {
    try {
      await _supabase
          .from('fuel_card_lockers')
          .update({
            'name': locker.name,
            'location': locker.location,
            'capacity': locker.capacity,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', locker.id);
    } catch (e) {
      throw Exception('Failed to update locker: ${e.toString()}');
    }
  }

  Future<void> deleteLocker(String lockerId) async {
    try {
      await _supabase.from('fuel_card_lockers').delete().eq('id', lockerId);
    } catch (e) {
      throw Exception('Failed to delete locker: ${e.toString()}');
    }
  }

  Future<void> addFuelCardToLocker(String lockerId, String fuelCardId) async {
    try {
      await _supabase.rpc(
        'add_fuel_card_to_locker',
        params: {'locker_id': lockerId, 'fuel_card_id': fuelCardId},
      );
    } catch (e) {
      throw Exception('Failed to add card to locker: ${e.toString()}');
    }
  }

  Future<void> removeFuelCardFromLocker(
    String lockerId,
    String fuelCardId,
  ) async {
    try {
      await _supabase.rpc(
        'remove_fuel_card_from_locker',
        params: {'locker_id': lockerId, 'fuel_card_id': fuelCardId},
      );
    } catch (e) {
      throw Exception('Failed to remove card from locker: ${e.toString()}');
    }
  }

  // Helper methods
  Future<void> _updateFuelCardBalance(String cardId, double amount) async {
    try {
      final card =
          await _supabase
              .from('fuel_cards')
              .select('current_balance')
              .eq('id', cardId)
              .single();

      final currentBalance = (card['current_balance'] as num).toDouble();
      final newBalance = currentBalance - amount;

      await _supabase
          .from('fuel_cards')
          .update({
            'current_balance': newBalance,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', cardId);
    } catch (e) {
      throw Exception('Failed to update card balance: ${e.toString()}');
    }
  }

  Future<void> updateFuelCardStatus(
    String cardId,
    FuelCardStatus status,
  ) async {
    try {
      await _supabase
          .from('fuel_cards')
          .update({
            'status': status.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', cardId);
    } catch (e) {
      throw Exception('Failed to update card status: ${e.toString()}');
    }
  }
}
