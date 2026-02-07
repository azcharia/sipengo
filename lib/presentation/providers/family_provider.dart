import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/family_model.dart';
import '../../data/repositories/family_repository.dart';

// Repository Provider
final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
  return FamilyRepository();
});

// All Families Provider
final familiesProvider = FutureProvider<List<FamilyModel>>((ref) async {
  final repository = ref.watch(familyRepositoryProvider);
  return repository.getAllFamilies();
});

// Single Family Provider
final familyDetailProvider = FutureProvider.family<FamilyModel?, String>((
  ref,
  familyId,
) async {
  final repository = ref.watch(familyRepositoryProvider);
  return repository.getFamilyById(familyId);
});

// Search Families Provider
final searchFamiliesProvider = FutureProvider.family<List<FamilyModel>, String>(
  (ref, query) async {
    if (query.isEmpty) {
      return ref.watch(familiesProvider).value ?? [];
    }
    final repository = ref.watch(familyRepositoryProvider);
    return repository.searchFamilies(query);
  },
);

// Family State Notifier for CRUD operations
class FamilyNotifier extends StateNotifier<AsyncValue<void>> {
  final FamilyRepository _repository;

  FamilyNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createFamily(FamilyModel family, {dynamic housePhoto}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createFamily(family: family, housePhoto: housePhoto);
    });
  }

  Future<void> updateFamily(
    String id,
    FamilyModel family, {
    dynamic newHousePhoto,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateFamily(
        id: id,
        family: family,
        newHousePhoto: newHousePhoto,
      );
    });
  }

  Future<void> deleteFamily(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteFamily(id);
    });
  }
}

final familyNotifierProvider =
    StateNotifierProvider<FamilyNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(familyRepositoryProvider);
      return FamilyNotifier(repository);
    });
