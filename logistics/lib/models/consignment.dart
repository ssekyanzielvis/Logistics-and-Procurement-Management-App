class ConsignmentModel {
  final String id;
  final String clientId;
  final String? driverId;
  final String pickupLocation;
  final String deliveryLocation;
  final String itemDescription;
  final double weight;
  final String status;
  final String? specialInstructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConsignmentModel({
    required this.id,
    required this.clientId,
    this.driverId,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.itemDescription,
    required this.weight,
    required this.status,
    this.specialInstructions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConsignmentModel.fromJson(Map<String, dynamic> json) {
    return ConsignmentModel(
      id: json['id'],
      clientId: json['client_id'],
      driverId: json['driver_id'],
      pickupLocation: json['pickup_location'],
      deliveryLocation: json['delivery_location'],
      itemDescription: json['item_description'],
      weight: json['weight'].toDouble(),
      status: json['status'],
      specialInstructions: json['special_instructions'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'driver_id': driverId,
      'pickup_location': pickupLocation,
      'delivery_location': deliveryLocation,
      'item_description': itemDescription,
      'weight': weight,
      'status': status,
      'special_instructions': specialInstructions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
