import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/family_model.dart';
import '../../../data/services/export_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/family_provider.dart';
import '../../providers/resident_provider.dart';
import '../family/family_detail_screen.dart';
import '../family/family_form_screen.dart';
import 'widgets/statistics_dashboard.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounceTimer;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_searchQuery.isNotEmpty) return; // Do not paginate during search

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    const delta = 200.0; // Trigger pagination 200px before bottom

    if (maxScroll - currentScroll <= delta) {
      ref.read(paginatedFamiliesProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _searchQuery.isNotEmpty;
    final familiesAsync = isSearching
        ? ref.watch(searchFamiliesProvider(_searchQuery))
        : null;
    final paginatedStateAsync = isSearching
        ? null
        : ref.watch(paginatedFamiliesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''), // Empty title, dashboard shows SIPENGO
        actions: [
          // Export Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.download),
            onSelected: (value) => _handleExport(value),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'excel',
                    child: Row(
                      children: [
                        Icon(Icons.table_chart, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Export Excel'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'pdf',
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Cetak Laporan PDF'),
                      ],
                    ),
                  ),
                ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(),
          ),
        ],
      ),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Statistics Dashboard as Sliver
            SliverToBoxAdapter(child: const StatisticsDashboard()),
            // Search Bar as Sliver
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.surface,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari berdasarkan No. KK, Nama, atau Alamat',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                  ),
                  onChanged: (value) {
                    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
                    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                      setState(() {
                        _searchQuery = value;
                      });
                    });
                  },
                ),
              ),
            ),
          ];
        },
        body: isSearching
            ? familiesAsync!.when(
                data: (families) => _buildFamiliesList(context, ref, families, isSearch: true),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              )
            : paginatedStateAsync!.when(
                data: (state) => RefreshIndicator(
                  onRefresh: () async {
                    ref.read(paginatedFamiliesProvider.notifier).refresh();
                  },
                  child: _buildFamiliesList(
                    context,
                    ref,
                    state.families,
                    isLoadingMore: state.isLoadingMore,
                    hasReachedEnd: state.hasReachedEnd,
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FamilyFormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addFamily),
      ),
    );
  }

  Widget _buildFamiliesList(
    BuildContext context,
    WidgetRef ref,
    List<FamilyModel> families, {
    bool isSearch = false,
    bool isLoadingMore = false,
    bool hasReachedEnd = false,
  }) {
    if (families.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.textHint.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.family_restroom_rounded,
                size: 64,
                color: AppColors.textHint.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSearch
                  ? 'Tidak ditemukan KK dengan kata kunci tersebut.'
                  : 'Belum ada data KK di database Desa Gombang.\nSilakan tambahkan data baru.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
      itemCount: families.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == families.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          );
        }

        final family = families[index];
        final hasPhoto = family.housePhotoUrl != null && family.housePhotoUrl!.isNotEmpty;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FamilyDetailScreen(familyId: family.id),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Modern leading avatar with gradient
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.85),
                            AppColors.primary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        family.headOfHousehold.isNotEmpty
                            ? family.headOfHousehold.substring(0, 1).toUpperCase()
                            : 'K',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Family details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            family.headOfHousehold,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'KK: ${family.kkNumber}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            family.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textHint,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // House Photo status badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: hasPhoto
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  hasPhoto ? Icons.check_circle_rounded : Icons.pending_rounded,
                                  size: 14,
                                  color: hasPhoto ? AppColors.success : AppColors.warning,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  hasPhoto ? 'Foto Rumah Terunggah' : 'Belum Ada Foto',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: hasPhoto ? AppColors.success : AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Modern Trailing Chevron Button
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.04),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(AppStrings.logout),
            content: const Text('Apakah Anda yakin ingin keluar?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(AppStrings.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(AppStrings.logout),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authNotifierProvider.notifier).signOut();
    }
  }

  Future<void> _handleExport(String type) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Membuat file...'),
              ],
            ),
          ),
    );

    try {
      final familyRepo = ref.read(familyRepositoryProvider);
      final residentRepo = ref.read(residentRepositoryProvider);
      final exportService = ExportService(familyRepo, residentRepo);

      if (type == 'excel') {
        await exportService.exportToExcel();
      } else if (type == 'pdf') {
        await exportService.exportToPDF();
      }

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil export ke ${type.toUpperCase()}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal export: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
