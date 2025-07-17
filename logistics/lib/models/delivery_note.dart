class DeliveryNote {
  final String id;
  final String driverId;
  final String customerId;
  final String customerName;
  final String deliveryAddress;
  final String imageUrl;
  final String imagePath;
  final DateTime createdAt;
  final String status;
  final String? notes;

  DeliveryNote({
    required this.id,
    required this.driverId,
    required this.customerId,
    required this.customerName,
    required this.deliveryAddress,
    required this.imageUrl,
    required this.imagePath,
    required this.createdAt,
    required this.status,
    this.notes,
  });

  factory DeliveryNote.fromJson(Map<String, dynamic> json) {
    return DeliveryNote(
      id: json['id'],
      driverId: json['driver_id'],
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      deliveryAddress: json['delivery_address'],
      imageUrl: json['image_url'],
      imagePath: json['image_path'],
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'customer_id': customerId,
      'customer_name': customerName,
      'delivery_address': deliveryAddress,
      'image_url': imageUrl,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }
}
