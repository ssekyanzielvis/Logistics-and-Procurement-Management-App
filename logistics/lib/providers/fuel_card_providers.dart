import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fuel_card_models.dart';
import '../services/fuel_card_service.dart';

// State notifiers for managing data
class FuelCardsNotifier extends StateNotifier<List<FuelCard>> {
  FuelCardsNotifier() : super([]);

  Future<void> load() async {
    final cards = await FuelCardService().getAllCards();
    state = cards;
  }

  Future<void> add(FuelCard card) async {
    await FuelCardService().addCard(
      cardNumber: card.cardNumber,
      cardType: card.cardType,
      spendingLimit: card.spendingLimit,
      fuelTypeRestrictions: card.fuelTypeRestrictions,
    );
    await load();
  }

  Future<void> update(FuelCard card) async {
    await FuelCardService().updateCard(card);
    await load();
  }

  Future<void> delete(String cardId) async {
    await FuelCardService().deleteCard(cardId);
    await load();
  }

  void replaceAll(List<FuelCard> cards) {
    state = cards;
  }

  void clear() {
    state = [];
  }
}

class FuelTransactionsNotifier extends StateNotifier<List<FuelTransaction>> {
  FuelTransactionsNotifier() : super([]);

  Future<void> load() async {
    final transactions = await FuelCardService().getAllTransactions();
    state = transactions;
  }

  Future<void> add(FuelTransaction transaction) async {
    await FuelCardService().addTransaction(
      fuelCardId: transaction.fuelCardId,
      driverId: transaction.driverId,
      vehicleId: transaction.vehicleId,
      type: transaction.type,
      amount: transaction.amount,
      quantity: transaction.quantity,
      pricePerUnit: transaction.pricePerUnit,
      station: transaction.station,
      location: transaction.location,
      authorizationCode: transaction.authorizationCode,
      receiptNumber: transaction.receiptNumber,
    );
    await load();
  }

  Future<void> update(FuelTransaction transaction) async {
    await FuelCardService().updateTransaction(transaction);
    await load();
  }

  Future<void> delete(String transactionId) async {
    await FuelCardService().deleteTransaction(transactionId);
    await load();
  }

  void replaceAll(List<FuelTransaction> transactions) {
    state = transactions;
  }

  void clear() {
    state = [];
  }
}

class FuelCardAssignmentsNotifier
    extends StateNotifier<List<FuelCardAssignment>> {
  FuelCardAssignmentsNotifier() : super([]);

  Future<void> load() async {
    final assignments = await FuelCardService().getAllAssignments();
    state = assignments;
  }

  Future<void> add(FuelCardAssignment assignment) async {
    await FuelCardService().assignCard(
      fuelCardId: assignment.fuelCardId,
      driverId: assignment.driverId,
      assignedBy: assignment.assignedBy,
      vehicleId: assignment.vehicleId,
      notes: assignment.notes,
    );
    await load();
  }

  Future<void> update(FuelCardAssignment assignment) async {
    await FuelCardService().updateAssignment(assignment);
    await load();
  }

  Future<void> delete(String assignmentId) async {
    await FuelCardService().unassignCard(assignmentId);
    await load();
  }

  void replaceAll(List<FuelCardAssignment> assignments) {
    state = assignments;
  }

  void clear() {
    state = [];
  }
}

class FuelCardLockersNotifier extends StateNotifier<List<FuelCardLocker>> {
  FuelCardLockersNotifier() : super([]);

  Future<void> load() async {
    final lockers = await FuelCardService().getAllLockers();
    state = lockers;
  }

  Future<void> add(FuelCardLocker locker) async {
    await FuelCardService().addLocker(locker);
    await load();
  }

  Future<void> update(FuelCardLocker locker) async {
    await FuelCardService().updateLocker(locker);
    await load();
  }

  Future<void> delete(String lockerId) async {
    await FuelCardService().deleteLocker(lockerId);
    await load();
  }

  void replaceAll(List<FuelCardLocker> lockers) {
    state = lockers;
  }

  void clear() {
    state = [];
  }
}

// Providers
final fuelCardsProvider =
    StateNotifierProvider<FuelCardsNotifier, List<FuelCard>>(
      (ref) => FuelCardsNotifier(),
    );

final fuelTransactionsProvider =
    StateNotifierProvider<FuelTransactionsNotifier, List<FuelTransaction>>(
      (ref) => FuelTransactionsNotifier(),
    );

final fuelCardAssignmentsProvider = StateNotifierProvider<
  FuelCardAssignmentsNotifier,
  List<FuelCardAssignment>
>((ref) => FuelCardAssignmentsNotifier());

final fuelCardLockersProvider =
    StateNotifierProvider<FuelCardLockersNotifier, List<FuelCardLocker>>(
      (ref) => FuelCardLockersNotifier(),
    );
