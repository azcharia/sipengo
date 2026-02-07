import '../models/resident_model.dart';
import '../services/supabase_service.dart';

class ResidentRepository {
  /// Get all residents for a family
  Future<List<ResidentModel>> getResidentsByFamily(String familyId) async {
    try {
      final response = await SupabaseService.residents
          .select()
          .eq('family_id', familyId)
          .order('relationship', ascending: true);

      return (response as List)
          .map((json) => ResidentModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch residents: $e');
    }
  }

  /// Get resident by ID
  Future<ResidentModel?> getResidentById(String id) async {
    try {
      final response =
          await SupabaseService.residents.select().eq('id', id).single();

      return ResidentModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch resident: $e');
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
      final response =
          await SupabaseService.residents
              .insert(resident.toInsertJson())
              .select()
              .single();

      return ResidentModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create resident: $e');
    }
  }

  /// Update resident
  Future<ResidentModel> updateResident(
    String id,
    ResidentModel resident,
  ) async {
    try {
      final response =
          await SupabaseService.residents
              .update(resident.toUpdateJson())
              .eq('id', id)
              .select()
              .single();

      return ResidentModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update resident: $e');
    }
  }

  /// Delete resident
  Future<void> deleteResident(String id) async {
    try {
      await SupabaseService.residents.delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete resident: $e');
    }
  }

  /// Get children of a resident
  Future<List<ResidentModel>> getChildren(String parentId) async {
    try {
      final response = await SupabaseService.residents
          .select()
          .eq('parent_id', parentId)
          .order('birth_date', ascending: true);

      return (response as List)
          .map((json) => ResidentModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch children: $e');
    }
  }
}
