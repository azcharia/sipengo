import 'dart:async';
import '../models/resident_model.dart';
import '../services/supabase_service.dart';
import '../services/local_db_service.dart';
import '../services/sync_service.dart';
import '../../core/utils/network_resilience.dart';

class ResidentRepository {
  /// Get all residents for a family
  Future<List<ResidentModel>> getResidentsByFamily(String familyId) async {
    try {
      final List<ResidentModel> residents = await NetworkResilience.runWithRetry(() async {
        final response = await SupabaseService.residents
            .select()
            .eq('family_id', familyId)
            .order('relationship', ascending: true);

        return (response as List)
            .map((json) => ResidentModel.fromJson(json))
            .toList();
      });

      // Cache locally on success
      await LocalDbService.cacheResidents(familyId, residents);
      
      // Auto sync pending operations in background since we are online now
      unawaited(SyncService.syncPendingOperations());

      return residents;
    } catch (e) {
      // Fallback to local cache if offline
      final cached = LocalDbService.getCachedResidents(familyId);
      if (cached.isNotEmpty) {
        // ignore: avoid_print
        print('ResidentRepository: Network query failed ($e). Falling back to local cache.');
        return cached;
      }
      throw Exception('Failed to fetch residents and no local cache available: $e');
    }
  }

  /// Get resident by ID
  Future<ResidentModel?> getResidentById(String id) async {
    try {
      final ResidentModel? resident = await NetworkResilience.runWithRetry(() async {
        final response =
            await SupabaseService.residents.select().eq('id', id).single();

        return ResidentModel.fromJson(response);
      });

      return resident;
    } catch (e) {
      // Fallback to searching all local cached records
      final allCached = LocalDbService.getCachedAllResidents();
      final resident = allCached.where((r) => r.id == id).firstOrNull;
      if (resident != null) return resident;

      // Fallback to searching in each family cache
      final families = LocalDbService.getCachedFamilies();
      for (var f in families) {
        final familyResidents = LocalDbService.getCachedResidents(f.id);
        final res = familyResidents.where((r) => r.id == id).firstOrNull;
        if (res != null) return res;
      }
      return null;
    }
  }

  /// Get lineage tree for a family
  /// Returns residents organized by parent-child relationships
  Future<List<ResidentModel>> getLineageTree(String familyId) async {
    try {
      final residents = await getResidentsByFamily(familyId);

      // Sort by hierarchy: head -> spouse -> children -> grandchildren
      residents.sort((a, b) {
        final hierarchyOrder = {
          'head': 0,
          'wife': 1,
          'husband': 1,
          'child': 2,
          'grandchild': 3,
          'parent': 4,
          'grandparent': 5,
          'sibling': 6,
          'other': 7,
        };

        final orderA = hierarchyOrder[a.relationship.value] ?? 99;
        final orderB = hierarchyOrder[b.relationship.value] ?? 99;

        return orderA.compareTo(orderB);
      });

      return residents;
    } catch (e) {
      throw Exception('Failed to fetch lineage tree: $e');
    }
  }

  /// Create new resident
  Future<ResidentModel> createResident(ResidentModel resident) async {
    try {
      return await NetworkResilience.runWithRetry(() async {
        final response =
            await SupabaseService.residents
                .insert(resident.toInsertJson())
                .select()
                .single();

        final createdResident = ResidentModel.fromJson(response);

        // Update local cache
        final currentCached = LocalDbService.getCachedResidents(resident.familyId);
        currentCached.add(createdResident);
        await LocalDbService.cacheResidents(resident.familyId, currentCached);

        return createdResident;
      });
    } catch (e) {
      // Offline fallback: queue operation and update local cache for instant UI
      await LocalDbService.queueSyncOperation(
        operationType: 'create_resident',
        modelType: 'resident',
        data: resident.toInsertJson(),
      );

      // Write into local cache immediately
      final currentCached = LocalDbService.getCachedResidents(resident.familyId);
      currentCached.add(resident);
      await LocalDbService.cacheResidents(resident.familyId, currentCached);

      // ignore: avoid_print
      print('ResidentRepository: Offline mode active. Queued resident creation for sync later.');
      return resident;
    }
  }

  /// Update resident
  Future<ResidentModel> updateResident(
    String id,
    ResidentModel resident,
  ) async {
    try {
      return await NetworkResilience.runWithRetry(() async {
        final response =
            await SupabaseService.residents
                .update(resident.toUpdateJson())
                .eq('id', id)
                .select()
                .single();

        final updatedResident = ResidentModel.fromJson(response);

        // Update local cache
        final currentCached = LocalDbService.getCachedResidents(resident.familyId);
        final idx = currentCached.indexWhere((r) => r.id == id);
        if (idx != -1) {
          currentCached[idx] = updatedResident;
          await LocalDbService.cacheResidents(resident.familyId, currentCached);
        }

        return updatedResident;
      });
    } catch (e) {
      // Offline fallback: queue operation and update local cache
      await LocalDbService.queueSyncOperation(
        operationType: 'update_resident',
        modelType: 'resident',
        data: resident.toUpdateJson(),
        targetId: id,
      );

      // Write into local cache immediately
      final currentCached = LocalDbService.getCachedResidents(resident.familyId);
      final idx = currentCached.indexWhere((r) => r.id == id);
      if (idx != -1) {
        currentCached[idx] = resident;
        await LocalDbService.cacheResidents(resident.familyId, currentCached);
      }

      // ignore: avoid_print
      print('ResidentRepository: Offline mode active. Queued resident update for sync later.');
      return resident;
    }
  }

  /// Delete resident
  Future<void> deleteResident(String id) async {
    String? familyId;
    
    // Find resident's familyId from cache first
    final allCached = LocalDbService.getCachedAllResidents();
    final cachedRes = allCached.where((r) => r.id == id).firstOrNull;
    familyId = cachedRes?.familyId;

    if (familyId == null) {
      final families = LocalDbService.getCachedFamilies();
      for (var f in families) {
        final familyResidents = LocalDbService.getCachedResidents(f.id);
        final res = familyResidents.where((r) => r.id == id).firstOrNull;
        if (res != null) {
          familyId = res.familyId;
          break;
        }
      }
    }

    try {
      await NetworkResilience.runWithRetry(() async {
        await SupabaseService.residents.delete().eq('id', id);
      });

      // Update local cache
      if (familyId != null) {
        final currentCached = LocalDbService.getCachedResidents(familyId);
        currentCached.removeWhere((r) => r.id == id);
        await LocalDbService.cacheResidents(familyId, currentCached);
      }
    } catch (e) {
      // Offline fallback: queue operation and delete from local cache
      await LocalDbService.queueSyncOperation(
        operationType: 'delete_resident',
        modelType: 'resident',
        data: {},
        targetId: id,
      );

      // Remove from cache immediately
      if (familyId != null) {
        final currentCached = LocalDbService.getCachedResidents(familyId);
        currentCached.removeWhere((r) => r.id == id);
        await LocalDbService.cacheResidents(familyId, currentCached);
      }

      // ignore: avoid_print
      print('ResidentRepository: Offline mode active. Queued resident deletion for sync later.');
    }
  }

  /// Get children of a resident
  Future<List<ResidentModel>> getChildren(String parentId) async {
    try {
      return await NetworkResilience.runWithRetry(() async {
        final response = await SupabaseService.residents
            .select()
            .eq('parent_id', parentId)
            .order('birth_date', ascending: true);

        return (response as List)
            .map((json) => ResidentModel.fromJson(json))
            .toList();
      });
    } catch (e) {
      // Offline fallback: search all cached resident lists
      final allCached = LocalDbService.getCachedAllResidents();
      final children = allCached.where((r) => r.parentId == parentId).toList();
      if (children.isNotEmpty) return children;

      // Deep search through all family caches
      final families = LocalDbService.getCachedFamilies();
      final List<ResidentModel> deepChildren = [];
      for (var f in families) {
        final familyResidents = LocalDbService.getCachedResidents(f.id);
        deepChildren.addAll(familyResidents.where((r) => r.parentId == parentId));
      }
      deepChildren.sort((a, b) => a.birthDate.compareTo(b.birthDate));
      return deepChildren;
    }
  }

  /// Get all residents in the database
  Future<List<ResidentModel>> getAllResidents() async {
    try {
      final List<ResidentModel> residents = await NetworkResilience.runWithRetry(() async {
        final response = await SupabaseService.residents.select();

        return (response as List)
            .map((json) => ResidentModel.fromJson(json))
            .toList();
      });

      // Cache locally on success
      await LocalDbService.cacheAllResidents(residents);

      return residents;
    } catch (e) {
      // Fallback to local cache
      final cached = LocalDbService.getCachedAllResidents();
      if (cached.isNotEmpty) {
        // ignore: avoid_print
        print('ResidentRepository: Network query for all residents failed. Falling back to local cache.');
        return cached;
      }
      return [];
    }
  }
}
