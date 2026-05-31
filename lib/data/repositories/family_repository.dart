import 'dart:async';
import 'dart:io';
import '../models/family_model.dart';
import '../services/supabase_service.dart';
import '../services/storage_service.dart';
import '../services/local_db_service.dart';
import '../services/sync_service.dart';
import '../../core/utils/image_compressor.dart';
import '../../core/utils/network_resilience.dart';

class FamilyRepository {
  final StorageService _storageService = StorageService();

  /// Get all families
  Future<List<FamilyModel>> getAllFamilies() async {
    try {
      final List<FamilyModel> families = await NetworkResilience.runWithRetry(() async {
        final response = await SupabaseService.families.select().order(
          'created_at',
          ascending: false,
        );

        return (response as List)
            .map((json) => FamilyModel.fromJson(json))
            .toList();
      });

      // Cache data locally on success
      await LocalDbService.cacheFamilies(families);
      
      // Auto sync pending operations in background since we are online now
      unawaited(SyncService.syncPendingOperations());

      return families;
    } catch (e) {
      // Fallback to local cache if offline
      final cached = LocalDbService.getCachedFamilies();
      if (cached.isNotEmpty) {
        // ignore: avoid_print
        print('FamilyRepository: Network query failed ($e). Falling back to Hive local cache.');
        return cached;
      }
      throw Exception('Failed to fetch families and no local cache available: $e');
    }
  }

  /// Get family by ID
  Future<FamilyModel?> getFamilyById(String id) async {
    try {
      final FamilyModel? family = await NetworkResilience.runWithRetry(() async {
        final response =
            await SupabaseService.families.select().eq('id', id).single();

        return FamilyModel.fromJson(response);
      });

      if (family != null) {
        await LocalDbService.cacheFamily(family);
      }
      return family;
    } catch (e) {
      // Fallback to local cache if offline
      final cached = LocalDbService.getCachedFamily(id);
      if (cached != null) {
        // ignore: avoid_print
        print('FamilyRepository: Network query for family $id failed. Falling back to local cache.');
        return cached;
      }
      return null;
    }
  }

  /// Search families by KK number, name, or address
  Future<List<FamilyModel>> searchFamilies(String query) async {
    try {
      final List<FamilyModel> families = await NetworkResilience.runWithRetry(() async {
        final response = await SupabaseService.families
            .select()
            .or(
              'kk_number.ilike.%$query%,head_of_household.ilike.%$query%,address.ilike.%$query%',
            )
            .order('created_at', ascending: false);

        return (response as List)
            .map((json) => FamilyModel.fromJson(json))
            .toList();
      });

      return families;
    } catch (e) {
      // Fallback to local filtering if offline
      final cached = LocalDbService.getCachedFamilies();
      if (cached.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        return cached.where((f) =>
          f.kkNumber.toLowerCase().contains(lowerQuery) ||
          f.headOfHousehold.toLowerCase().contains(lowerQuery) ||
          f.address.toLowerCase().contains(lowerQuery)
        ).toList();
      }
      return [];
    }
  }

  /// Create new family
  Future<FamilyModel> createFamily({
    required FamilyModel family,
    File? housePhoto,
  }) async {
    String? photoUrl;
    File? compressedPhoto;

    // Pre-compress photo if available to save bandwidth
    if (housePhoto != null) {
      try {
        compressedPhoto = await ImageCompressor.compressImage(housePhoto);
      } catch (e) {
        // ignore: avoid_print
        print('FamilyRepository: Pre-compression failed: $e');
        compressedPhoto = housePhoto;
      }
    }

    try {
      return await NetworkResilience.runWithRetry(() async {
        // Upload photo if provided
        if (compressedPhoto != null && photoUrl == null) {
          final tempId = DateTime.now().millisecondsSinceEpoch.toString();
          photoUrl = await _storageService.uploadHousePhoto(
            imageFile: compressedPhoto,
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

        final createdFamily = FamilyModel.fromJson(response);
        
        // Cache locally
        await LocalDbService.cacheFamily(createdFamily);
        final currentCached = LocalDbService.getCachedFamilies();
        currentCached.insert(0, createdFamily);
        await LocalDbService.cacheFamilies(currentCached);

        return createdFamily;
      });
    } catch (e) {
      // Transient network failure during save: Queue the operation and update local cache for instant UI feedback
      final familyWithLocalPhoto = family.copyWith(
        housePhotoUrl: compressedPhoto?.path,
      );

      await LocalDbService.queueSyncOperation(
        operationType: 'create_family',
        modelType: 'family',
        data: familyWithLocalPhoto.toInsertJson(),
      );

      // Write into local cache immediately
      await LocalDbService.cacheFamily(familyWithLocalPhoto);
      final currentCached = LocalDbService.getCachedFamilies();
      currentCached.insert(0, familyWithLocalPhoto);
      await LocalDbService.cacheFamilies(currentCached);

      // ignore: avoid_print
      print('FamilyRepository: Offline mode active. Queued family creation for sync later.');
      return familyWithLocalPhoto;
    }
  }

  /// Update family
  Future<FamilyModel> updateFamily({
    required String id,
    required FamilyModel family,
    File? newHousePhoto,
  }) async {
    String? photoUrl = family.housePhotoUrl;
    File? compressedPhoto;

    if (newHousePhoto != null) {
      try {
        compressedPhoto = await ImageCompressor.compressImage(newHousePhoto);
      } catch (e) {
        compressedPhoto = newHousePhoto;
      }
    }

    try {
      return await NetworkResilience.runWithRetry(() async {
        // Update photo if new one provided
        if (compressedPhoto != null && photoUrl == family.housePhotoUrl) {
          photoUrl = await _storageService.updateHousePhoto(
            newImageFile: compressedPhoto,
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

        final updatedFamily = FamilyModel.fromJson(response);

        // Cache locally
        await LocalDbService.cacheFamily(updatedFamily);
        final currentCached = LocalDbService.getCachedFamilies();
        final idx = currentCached.indexWhere((f) => f.id == id);
        if (idx != -1) {
          currentCached[idx] = updatedFamily;
          await LocalDbService.cacheFamilies(currentCached);
        }

        return updatedFamily;
      });
    } catch (e) {
      // Offline fallback: Queue the operation and update local cache for instant UI feedback
      final familyWithLocalPhoto = family.copyWith(
        housePhotoUrl: compressedPhoto != null ? compressedPhoto.path : family.housePhotoUrl,
      );

      await LocalDbService.queueSyncOperation(
        operationType: 'update_family',
        modelType: 'family',
        data: familyWithLocalPhoto.toUpdateJson(),
        targetId: id,
      );

      // Write into local cache immediately
      await LocalDbService.cacheFamily(familyWithLocalPhoto);
      final currentCached = LocalDbService.getCachedFamilies();
      final idx = currentCached.indexWhere((f) => f.id == id);
      if (idx != -1) {
        currentCached[idx] = familyWithLocalPhoto;
        await LocalDbService.cacheFamilies(currentCached);
      }

      // ignore: avoid_print
      print('FamilyRepository: Offline mode active. Queued family update for sync later.');
      return familyWithLocalPhoto;
    }
  }

  /// Delete family
  Future<void> deleteFamily(String id) async {
    try {
      await NetworkResilience.runWithRetry(() async {
        // Get family to delete photo
        final family = await getFamilyById(id);

        // Delete photo if exists
        if (family?.housePhotoUrl != null) {
          try {
            await _storageService.deleteHousePhoto(family!.housePhotoUrl!);
          } catch (e) {
            // non-fatal
          }
        }

        // Delete family (cascade will delete residents)
        await SupabaseService.families.delete().eq('id', id);
      });

      // Clear from cache
      final currentCached = LocalDbService.getCachedFamilies();
      currentCached.removeWhere((f) => f.id == id);
      await LocalDbService.cacheFamilies(currentCached);
    } catch (e) {
      // Queue deletion operation offline
      await LocalDbService.queueSyncOperation(
        operationType: 'delete_family',
        modelType: 'family',
        data: {},
        targetId: id,
      );

      // Remove from cache immediately
      final currentCached = LocalDbService.getCachedFamilies();
      currentCached.removeWhere((f) => f.id == id);
      await LocalDbService.cacheFamilies(currentCached);

      // ignore: avoid_print
      print('FamilyRepository: Offline mode active. Queued family deletion for sync later.');
    }
  }

  /// Get families with pagination
  Future<List<FamilyModel>> getFamiliesPaginated({
    required int page,
    required int pageSize,
  }) async {
    try {
      return await NetworkResilience.runWithRetry(() async {
        final from = page * pageSize;
        final to = from + pageSize - 1;

        final response = await SupabaseService.families
            .select()
            .order('created_at', ascending: false)
            .range(from, to);

        return (response as List)
            .map((json) => FamilyModel.fromJson(json))
            .toList();
      });
    } catch (e) {
      // Offline fallback: returns subset of cached families
      final cached = LocalDbService.getCachedFamilies();
      final from = page * pageSize;
      if (from >= cached.length) return [];
      final to = from + pageSize;
      return cached.sublist(from, to > cached.length ? cached.length : to);
    }
  }
}
