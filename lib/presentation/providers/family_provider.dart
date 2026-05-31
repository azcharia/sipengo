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

// State class for Paginated Families list
class PaginatedFamiliesState {
  final List<FamilyModel> families;
  final int page;
  final bool isLoadingMore;
  final bool hasReachedEnd;

  PaginatedFamiliesState({
    required this.families,
    required this.page,
    required this.isLoadingMore,
    required this.hasReachedEnd,
  });

  PaginatedFamiliesState copyWith({
    List<FamilyModel>? families,
    int? page,
    bool? isLoadingMore,
    bool? hasReachedEnd,
  }) {
    return PaginatedFamiliesState(
      families: families ?? this.families,
      page: page ?? this.page,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }
}

// Notifier class for Paginated Families list
class PaginatedFamiliesNotifier extends StateNotifier<AsyncValue<PaginatedFamiliesState>> {
  final FamilyRepository _repository;
  static const int _pageSize = 15;

  PaginatedFamiliesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final items = await _repository.getFamiliesPaginated(page: 0, pageSize: _pageSize);
      return PaginatedFamiliesState(
        families: items,
        page: 0,
        isLoadingMore: false,
        hasReachedEnd: items.length < _pageSize,
      );
    });
  }

  Future<void> loadNextPage() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || current.hasReachedEnd) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));

    final nextState = await AsyncValue.guard(() async {
      final nextPage = current.page + 1;
      final items = await _repository.getFamiliesPaginated(page: nextPage, pageSize: _pageSize);

      return current.copyWith(
        families: [...current.families, ...items],
        page: nextPage,
        isLoadingMore: false,
        hasReachedEnd: items.length < _pageSize,
      );
    });

    if (nextState.hasValue) {
      state = nextState;
    } else {
      // Revert loading state but preserve current list
      state = AsyncValue.data(current.copyWith(isLoadingMore: false));
    }
  }

  void refresh() {
    loadFirstPage();
  }
}

final paginatedFamiliesProvider =
    StateNotifierProvider<PaginatedFamiliesNotifier, AsyncValue<PaginatedFamiliesState>>((ref) {
  final repository = ref.watch(familyRepositoryProvider);
  return PaginatedFamiliesNotifier(repository);
});

