enum FuelCardStatus {
  active,
  inactive,
  blocked,
  expired;

  String get name => toString().split('.').last;
}

enum FuelCardProvider {
  shell,
  bp,
  exxon,
  chevron,
  other;

  String get name => toString().split('.').last;
}

enum TransactionType {
  fuel,
  carWash,
  convenience,
  maintenance;

  String get name => toString().split('.').last;
}

enum CardType {
  physical,
  virtual,
  digital;

  String get name => toString().split('.').last;
}

class FuelCard {
  final String id;
  final String cardNumber;
  final String cardHolderName;
  final FuelCardProvider provider;
  final FuelCardStatus status;
  final CardType cardType;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final double spendingLimit;
  final double currentBalance;
  final List<String> fuelTypeRestrictions;
  final String? assignedDriverId;
  final String? vehicleId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FuelCard({
    required this.id,
    required this.cardNumber,
    required this.cardHolderName,
    required this.provider,
    required this.status,
    required this.cardType,
    required this.issueDate,
    this.expiryDate,
    required this.spendingLimit,
    required this.currentBalance,
    required this.fuelTypeRestrictions,
    this.assignedDriverId,
    this.vehicleId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FuelCard.fromJson(Map<String, dynamic> json) {
    return FuelCard(
      id: json['id'] as String,
      cardNumber: json['card_number'] as String,
      cardHolderName: json['card_holder_name'] as String,
      provider: FuelCardProvider.values.firstWhere(
        (e) => e.name == json['provider'],
        orElse: () => FuelCardProvider.other,
      ),
      status: FuelCardStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FuelCardStatus.inactive,
      ),
      cardType: CardType.values.firstWhere(
        (e) => e.name == json['card_type'],
        orElse: () => CardType.physical,
      ),
      issueDate: DateTime.parse(json['issue_date'] as String),
      expiryDate:
          json['expiry_date'] != null
              ? DateTime.parse(json['expiry_date'] as String)
              : null,
      spendingLimit: (json['spending_limit'] as num).toDouble(),
      currentBalance: (json['current_balance'] as num).toDouble(),
      fuelTypeRestrictions: List<String>.from(
        json['fuel_type_restrictions'] as List,
      ),
      assignedDriverId: json['assigned_driver_id'] as String?,
      vehicleId: json['vehicle_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_number': cardNumber,
      'card_holder_name': cardHolderName,
      'provider': provider.name,
      'status': status.name,
      'card_type': cardType.name,
      'issue_date': issueDate.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'spending_limit': spendingLimit,
      'current_balance': currentBalance,
      'fuel_type_restrictions': fuelTypeRestrictions,
      'assigned_driver_id': assignedDriverId,
      'vehicle_id': vehicleId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  FuelCard copyWith({
    String? id,
    String? cardNumber,
    String? cardHolderName,
    FuelCardProvider? provider,
    FuelCardStatus? status,
    CardType? cardType,
    DateTime? issueDate,
    DateTime? expiryDate,
    double? spendingLimit,
    double? currentBalance,
    List<String>? fuelTypeRestrictions,
    String? assignedDriverId,
    String? vehicleId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FuelCard(
      id: id ?? this.id,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      provider: provider ?? this.provider,
      status: status ?? this.status,
      cardType: cardType ?? this.cardType,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      spendingLimit: spendingLimit ?? this.spendingLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      fuelTypeRestrictions: fuelTypeRestrictions ?? this.fuelTypeRestrictions,
      assignedDriverId: assignedDriverId ?? this.assignedDriverId,
      vehicleId: vehicleId ?? this.vehicleId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FuelCardAssignment {
  final String id;
  final String fuelCardId;
  final String driverId;
  final String? vehicleId;
  final DateTime assignedDate;
  final DateTime? unassignedDate;
  final String assignedBy;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FuelCardAssignment({
    required this.id,
    required this.fuelCardId,
    required this.driverId,
    this.vehicleId,
    required this.assignedDate,
    this.unassignedDate,
    required this.assignedBy,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FuelCardAssignment.fromJson(Map<String, dynamic> json) {
    return FuelCardAssignment(
      id: json['id'] as String,
      fuelCardId: json['fuel_card_id'] as String,
      driverId: json['driver_id'] as String,
      vehicleId: json['vehicle_id'] as String?,
      assignedDate: DateTime.parse(json['assigned_date'] as String),
      unassignedDate:
          json['unassigned_date'] != null
              ? DateTime.parse(json['unassigned_date'] as String)
              : null,
      assignedBy: json['assigned_by'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fuel_card_id': fuelCardId,
      'driver_id': driverId,
      'vehicle_id': vehicleId,
      'assigned_date': assignedDate.toIso8601String(),
      'unassigned_date': unassignedDate?.toIso8601String(),
      'assigned_by': assignedBy,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  FuelCardAssignment copyWith({
    String? id,
    String? fuelCardId,
    String? driverId,
    String? vehicleId,
    DateTime? assignedDate,
    DateTime? unassignedDate,
    String? assignedBy,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FuelCardAssignment(
      id: id ?? this.id,
      fuelCardId: fuelCardId ?? this.fuelCardId,
      driverId: driverId ?? this.driverId,
      vehicleId: vehicleId ?? this.vehicleId,
      assignedDate: assignedDate ?? this.assignedDate,
      unassignedDate: unassignedDate ?? this.unassignedDate,
      assignedBy: assignedBy ?? this.assignedBy,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FuelTransaction {
  final String id;
  final String fuelCardId;
  final String? driverId;
  final String? vehicleId;
  final TransactionType type;
  final double amount;
  final double quantity;
  final double pricePerUnit;
  final String station;
  final String location;
  final DateTime transactionDate;
  final String? authorizationCode;
  final String? receiptNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FuelTransaction({
    required this.id,
    required this.fuelCardId,
    this.driverId,
    this.vehicleId,
    required this.type,
    required this.amount,
    required this.quantity,
    required this.pricePerUnit,
    required this.station,
    required this.location,
    required this.transactionDate,
    this.authorizationCode,
    this.receiptNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FuelTransaction.fromJson(Map<String, dynamic> json) {
    return FuelTransaction(
      id: json['id'] as String,
      fuelCardId: json['fuel_card_id'] as String,
      driverId: json['driver_id'] as String?,
      vehicleId: json['vehicle_id'] as String?,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.fuel,
      ),
      amount: (json['amount'] as num).toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
      pricePerUnit: (json['price_per_unit'] as num).toDouble(),
      station: json['station'] as String,
      location: json['location'] as String,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      authorizationCode: json['authorization_code'] as String?,
      receiptNumber: json['receipt_number'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fuel_card_id': fuelCardId,
      'driver_id': driverId,
      'vehicle_id': vehicleId,
      'type': type.name,
      'amount': amount,
      'quantity': quantity,
      'price_per_unit': pricePerUnit,
      'station': station,
      'location': location,
      'transaction_date': transactionDate.toIso8601String(),
      'authorization_code': authorizationCode,
      'receipt_number': receiptNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  FuelTransaction copyWith({
    String? id,
    String? fuelCardId,
    String? driverId,
    String? vehicleId,
    TransactionType? type,
    double? amount,
    double? quantity,
    double? pricePerUnit,
    String? station,
    String? location,
    DateTime? transactionDate,
    String? authorizationCode,
    String? receiptNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FuelTransaction(
      id: id ?? this.id,
      fuelCardId: fuelCardId ?? this.fuelCardId,
      driverId: driverId ?? this.driverId,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      quantity: quantity ?? this.quantity,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      station: station ?? this.station,
      location: location ?? this.location,
      transactionDate: transactionDate ?? this.transactionDate,
      authorizationCode: authorizationCode ?? this.authorizationCode,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FuelCardLocker {
  final String id;
  final String name;
  final String location;
  final int capacity;
  final int currentOccupancy;
  final List<String> fuelCardIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FuelCardLocker({
    required this.id,
    required this.name,
    required this.location,
    required this.capacity,
    required this.currentOccupancy,
    required this.fuelCardIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FuelCardLocker.fromJson(Map<String, dynamic> json) {
    return FuelCardLocker(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      capacity: json['capacity'] as int,
      currentOccupancy: json['current_occupancy'] as int,
      fuelCardIds: List<String>.from(json['fuel_card_ids'] as List),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'capacity': capacity,
      'current_occupancy': currentOccupancy,
      'fuel_card_ids': fuelCardIds,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  FuelCardLocker copyWith({
    String? id,
    String? name,
    String? location,
    int? capacity,
    int? currentOccupancy,
    List<String>? fuelCardIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FuelCardLocker(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      currentOccupancy: currentOccupancy ?? this.currentOccupancy,
      fuelCardIds: fuelCardIds ?? this.fuelCardIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
