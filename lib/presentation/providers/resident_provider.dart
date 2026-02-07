import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/resident_model.dart';
import '../../data/repositories/resident_repository.dart';

// Repository Provider
final residentRepositoryProvider = Provider<ResidentRepository>((ref) {
  return ResidentRepository();
});

// Family Residents Provider (with lineage sorting)
final familyResidentsProvider =
    FutureProvider.family<List<ResidentModel>, String>((ref, familyId) async {
      final repository = ref.watch(residentRepositoryProvider);
      return repository.getLineageTree(familyId);
    });

// Single Resident Provider
final residentDetailProvider = FutureProvider.family<ResidentModel?, String>((
  ref,
  residentId,
) async {
  final repository = ref.watch(residentRepositoryProvider);
  return repository.getResidentById(residentId);
});

// Children of Resident Provider
final residentChildrenProvider =
    FutureProvider.family<List<ResidentModel>, String>((ref, parentId) async {
      final repository = ref.watch(residentRepositoryProvider);
      return repository.getChildren(parentId);
    });

// Resident State Notifier for CRUD operations
class ResidentNotifier extends StateNotifier<AsyncValue<void>> {
  final ResidentRepository _repository;

  ResidentNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createResident(ResidentModel resident) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createResident(resident);
    });
  }

  Future<void> updateResident(String id, ResidentModel resident) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateResident(id, resident);
    });
  }

  Future<void> deleteResident(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteResident(id);
    });
  }
}

final residentNotifierProvider =
    StateNotifierProvider<ResidentNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(residentRepositoryProvider);
      return ResidentNotifier(repository);
    });
