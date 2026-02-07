import 'dart:io';
import '../models/family_model.dart';
import '../services/supabase_service.dart';
import '../services/storage_service.dart';

class FamilyRepository {
  final StorageService _storageService = StorageService();

  /// Get all families
  Future<List<FamilyModel>> getAllFamilies() async {
    try {
      final response = await SupabaseService.families.select().order(
        'created_at',
        ascending: false,
      );

      return (response as List)
          .map((json) => FamilyModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch families: $e');
    }
  }

  /// Get family by ID
  Future<FamilyModel?> getFamilyById(String id) async {
    try {
      final response =
          await SupabaseService.families.select().eq('id', id).single();

      return FamilyModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch family: $e');
    }
  }

  /// Search families by KK number, name, or address
  Future<List<FamilyModel>> searchFamilies(String query) async {
    try {
      final response = await SupabaseService.families
          .select()
          .or(
            'kk_number.ilike.%$query%,head_of_household.ilike.%$query%,address.ilike.%$query%',
          )
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => FamilyModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search families: $e');
    }
  }

  /// Create new family
  Future<FamilyModel> createFamily({
    required FamilyModel family,
    File? housePhoto,
  }) async {
    try {
      String? photoUrl;

      // Upload photo if provided
      if (housePhoto != null) {
        // Create temporary ID for upload
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
        photoUrl = await _storageService.uploadHousePhoto(
          imageFile: housePhoto,
          familyId: tempId,
        );
      }

      // Create family with photo URL
      final familyWithPhoto = family.copyWith(housePhotoUrl: photoUrl);
      final response =
          await SupabaseService.families
              .insert(familyWithPhoto.toInsertJson())
              .select()
              .single();

      return FamilyModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create family: $e');
    }
  }

  /// Update family
  Future<FamilyModel> updateFamily({
    required String id,
    required FamilyModel family,
    File? newHousePhoto,
  }) async {
    try {
      String? photoUrl = family.housePhotoUrl;

      // Update photo if new one provided
      if (newHousePhoto != null) {
        photoUrl = await _storageService.updateHousePhoto(
          newImageFile: newHousePhoto,
          familyId: id,
          oldPhotoUrl: family.housePhotoUrl,
        );
      }

      // Update family
      final familyWithPhoto = family.copyWith(housePhotoUrl: photoUrl);
      final response =
          await SupabaseService.families
              .update(familyWithPhoto.toUpdateJson())
              .eq('id', id)
              .select()
              .single();

      return FamilyModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update family: $e');
    }
  }

  /// Delete family
  Future<void> deleteFamily(String id) async {
    try {
      // Get family to delete photo
      final family = await getFamilyById(id);

      // Delete photo if exists
      if (family?.housePhotoUrl != null) {
        await _storageService.deleteHousePhoto(family!.housePhotoUrl!);
      }

      // Delete family (cascade will delete residents)
      await SupabaseService.families.delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete family: $e');
    }
  }
}
