import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class FuelReceiptService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _bucketName = 'fuel-receipts';

  /// Upload fuel receipt image to storage
  Future<String?> uploadFuelReceipt({
    required File receiptFile,
    required String transactionId,
    required String driverId,
  }) async {
    try {
      final fileExtension = receiptFile.path.split('.').last.toLowerCase();
      final fileName = 'receipt_${transactionId}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final filePath = '$driverId/$fileName';

      // Upload file to storage
      await _supabase.storage
          .from(_bucketName)
          .upload(filePath, receiptFile);

      // Get public URL
      final publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload fuel receipt: $e');
    }
  }

  /// Delete fuel receipt from storage
  Future<void> deleteFuelReceipt(String receiptUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(receiptUrl);
      final pathSegments = uri.pathSegments;
      final filePath = pathSegments.sublist(pathSegments.indexOf(_bucketName) + 1).join('/');

      await _supabase.storage
          .from(_bucketName)
          .remove([filePath]);
    } catch (e) {
      throw Exception('Failed to delete fuel receipt: $e');
    }
  }

  /// Update fuel transaction with receipt URL
  Future<void> attachReceiptToTransaction({
    required String transactionId,
    required String receiptUrl,
  }) async {
    try {
      await _supabase
          .from('fuel_transactions')
          .update({'receipt_url': receiptUrl})
          .eq('id', transactionId);
    } catch (e) {
      throw Exception('Failed to attach receipt to transaction: $e');
    }
  }

  /// Remove receipt from fuel transaction
  Future<void> removeReceiptFromTransaction(String transactionId) async {
    try {
      await _supabase
          .from('fuel_transactions')
          .update({'receipt_url': null})
          .eq('id', transactionId);
    } catch (e) {
      throw Exception('Failed to remove receipt from transaction: $e');
    }
  }

  /// Upload receipt and attach to transaction in one operation
  Future<String?> uploadAndAttachReceipt({
    required File receiptFile,
    required String transactionId,
    required String driverId,
  }) async {
    try {
      // Upload receipt
      final receiptUrl = await uploadFuelReceipt(
        receiptFile: receiptFile,
        transactionId: transactionId,
        driverId: driverId,
      );

      if (receiptUrl != null) {
        // Attach to transaction
        await attachReceiptToTransaction(
          transactionId: transactionId,
          receiptUrl: receiptUrl,
        );
      }

      return receiptUrl;
    } catch (e) {
      throw Exception('Failed to upload and attach receipt: $e');
    }
  }
}
