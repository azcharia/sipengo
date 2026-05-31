import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageCompressor {
  /// Compress image file to a temporary location with target size and quality.
  /// If compression fails or is skipped, it returns the original file to prevent breaking the flow.
  static Future<File> compressImage(File file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      
      // Pure Dart string manipulation to get file extension safely
      final filePath = file.path;
      final dotIndex = filePath.lastIndexOf('.');
      final extension = dotIndex != -1 ? filePath.substring(dotIndex) : '.jpg';
      
      final targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}$extension';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 80,
        minWidth: 1080,
        minHeight: 1080,
      );

      if (result != null) {
        final compressedFile = File(result.path);
        
        // Log compression ratio for developer visibility
        final originalSize = await file.length();
        final compressedSize = await compressedFile.length();
        final ratio = ((originalSize - compressedSize) / originalSize * 100).toStringAsFixed(1);
        
        // Use print safely or local logging
        // ignore: avoid_print
        print('ImageCompressed: $originalSize bytes -> $compressedSize bytes ($ratio% reduction)');
        
        return compressedFile;
      }
      return file;
    } catch (e) {
      // ignore: avoid_print
      print('ImageCompressionError: Failed to compress, using original file instead. $e');
      return file;
    }
  }
}
