import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/storage_constants.dart';
import 'supabase_service.dart';

class StorageService {
  final SupabaseStorageClient _storage = SupabaseService.storage;

  /// Upload house photo to Supabase Storage
  /// Returns the public URL of the uploaded image
  Future<String> uploadHousePhoto({
    required File imageFile,
    required String familyId,
  }) async {
    try {
      final String fileName =
          '${familyId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload file
      await _storage
          .from(StorageConstants.housePhotosBucket)
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Get public URL
      final String publicUrl = _storage
          .from(StorageConstants.housePhotosBucket)
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete house photo from Supabase Storage
  Future<void> deleteHousePhoto(String photoUrl) async {
    try {
      // Extract file name from URL
      final uri = Uri.parse(photoUrl);
      final fileName = uri.pathSegments.last;

      await _storage.from(StorageConstants.housePhotosBucket).remove([
        fileName,
      ]);
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Update house photo (delete old, upload new)
  Future<String> updateHousePhoto({
    required File newImageFile,
    required String familyId,
    String? oldPhotoUrl,
  }) async {
    try {
      // Delete old photo if exists
      if (oldPhotoUrl != null && oldPhotoUrl.isNotEmpty) {
        await deleteHousePhoto(oldPhotoUrl);
      }

      // Upload new photo
      return await uploadHousePhoto(
        imageFile: newImageFile,
        familyId: familyId,
      );
    } catch (e) {
      throw Exception('Failed to update image: $e');
    }
  }
}
