import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class ImageUtils {
  static Future<File> compressImage(File imageFile) async {
    try {
      // Read the image file
      Uint8List imageBytes = await imageFile.readAsBytes();

      // Get temporary directory
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;

      // Create compressed file path with platform-aware path separator
      String fileName =
          'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      String compressedPath = '$tempPath${Platform.pathSeparator}$fileName';

      // For now, just copy the file (you can add actual compression logic here)
      File compressedFile = File(compressedPath);
      await compressedFile.writeAsBytes(imageBytes);

      return compressedFile;
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }

  static Future<bool> isImageSizeValid(
    File imageFile, {
    int maxSizeInMB = 5,
  }) async {
    try {
      int fileSizeInBytes = await imageFile.length();
      int maxSizeInBytes = maxSizeInMB * 1024 * 1024; // Convert MB to bytes
      return fileSizeInBytes <= maxSizeInBytes;
    } catch (e) {
      return false;
    }
  }

  static String getImageSizeString(File imageFile) {
    try {
      int fileSizeInBytes = imageFile.lengthSync();
      if (fileSizeInBytes < 1024) {
        return '$fileSizeInBytes B';
      } else if (fileSizeInBytes < 1024 * 1024) {
        return '${(fileSizeInBytes / 1024).toStringAsFixed(1)} KB';
      } else {
        return '${(fileSizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      return 'Unknown size';
    }
  }
}
