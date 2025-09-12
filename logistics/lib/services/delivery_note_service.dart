import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/delivery_note.dart';

class DeliveryNoteService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _bucketName = 'delivery-notes';

  Future<String> uploadImage(File imageFile, String deliveryId) async {
    try {
      final String fileName = '${deliveryId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = 'delivery_notes/$fileName';

      await _supabase.storage
          .from(_bucketName)
          .upload(filePath, imageFile);

      final String publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<DeliveryNote> saveDeliveryNote({
    required String driverId,
    required String customerId,
    required String customerName,
    required String deliveryAddress,
    required File imageFile,
    String? notes,
  }) async {
    try {
      final String deliveryId = const Uuid().v4();
      
      // Upload image first
      final String imageUrl = await uploadImage(imageFile, deliveryId);

      // Create delivery note record
      final deliveryNote = DeliveryNote(
        id: deliveryId,
        driverId: driverId,
        customerId: customerId,
        customerName: customerName,
        deliveryAddress: deliveryAddress,
        imageUrl: imageUrl,
        imagePath: imageFile.path,
        createdAt: DateTime.now(),
        status: 'delivered',
        notes: notes,
      );

      // Save to database
      await _supabase
          .from('delivery_notes')
          .insert(deliveryNote.toJson());

      return deliveryNote;
    } catch (e) {
      throw Exception('Failed to save delivery note: $e');
    }
  }

  Future<List<DeliveryNote>> getDeliveryNotes(String? driverId) async {
    try {
      // Check if driverId is valid (not null/empty)
      if (driverId == null || driverId.isEmpty) {
        return []; // Return empty list instead of making an invalid query
      }
      
      final response = await _supabase
          .from('delivery_notes')
          .select()
          .eq('driver_id', driverId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => DeliveryNote.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch delivery notes: $e');
    }
  }

  Future<void> deleteDeliveryNote(String deliveryNoteId) async {
    try {
      await _supabase
          .from('delivery_notes')
          .delete()
          .eq('id', deliveryNoteId);
    } catch (e) {
      throw Exception('Failed to delete delivery note: $e');
    }
  }
}
