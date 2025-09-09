import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConsignmentDocumentService {
  static final _client = Supabase.instance.client;
  static const String bucketName = 'consignment-docs';
  static final ImagePicker _picker = ImagePicker();

  /// Upload a document image and attach it to a consignment
  static Future<String?> uploadAndAttachDocument(String consignmentId, ImageSource source) async {
    try {
      // Pick an image (documents can be photographed)
      XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        File file = File(pickedFile.path);
        String fileName = pickedFile.name;
        
        // Upload to storage
        String? uploadedUrl = await uploadDocument(file, fileName, consignmentId);
        
        if (uploadedUrl != null) {
          // Update consignment with document URL
          await _client
              .from('consignments')
              .update({'document_url': uploadedUrl})
              .eq('id', consignmentId);
          
          return uploadedUrl;
        }
      }
      return null;
    } catch (e) {
      print('Error uploading and attaching document: $e');
      return null;
    }
  }

  /// Upload document to storage
  static Future<String?> uploadDocument(File file, String fileName, String consignmentId) async {
    try {
      // Generate unique file name
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String uniqueFileName = '${consignmentId}_${timestamp}_$fileName';

      // Upload file to Supabase storage
      await _client.storage
          .from(bucketName)
          .upload(uniqueFileName, file);

      // Get public URL
      String publicUrl = _client.storage
          .from(bucketName)
          .getPublicUrl(uniqueFileName);

      return publicUrl;
    } catch (e) {
      print('Error uploading document: $e');
      return null;
    }
  }

  /// Delete document from storage
  static Future<bool> deleteDocument(String documentUrl) async {
    try {
      // Extract file name from URL
      Uri uri = Uri.parse(documentUrl);
      String fileName = uri.pathSegments.last;

      // Delete from storage
      await _client.storage
          .from(bucketName)
          .remove([fileName]);

      return true;
    } catch (e) {
      print('Error deleting document: $e');
      return false;
    }
  }

  /// Remove document from consignment and delete from storage
  static Future<bool> removeDocumentFromConsignment(String consignmentId, String? documentUrl) async {
    try {
      // Update consignment to remove document URL
      await _client
          .from('consignments')
          .update({'document_url': null})
          .eq('id', consignmentId);

      // Delete from storage if URL exists
      if (documentUrl != null) {
        await deleteDocument(documentUrl);
      }

      return true;
    } catch (e) {
      print('Error removing document from consignment: $e');
      return false;
    }
  }

  /// Get document URL for a consignment
  static Future<String?> getConsignmentDocumentUrl(String consignmentId) async {
    try {
      final response = await _client
          .from('consignments')
          .select('document_url')
          .eq('id', consignmentId)
          .single();

      return response['document_url'] as String?;
    } catch (e) {
      print('Error getting consignment document URL: $e');
      return null;
    }
  }
}
