import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
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
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final familiesAsync =
        _searchQuery.isEmpty
            ? ref.watch(familiesProvider)
            : ref.watch(searchFamiliesProvider(_searchQuery));

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
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            ),
          ];
        },
        body: familiesAsync.when(
          data: (families) {
            if (families.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.family_restroom,
                      size: 64,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty
                          ? 'Belum ada data keluarga.\nTambahkan keluarga baru.'
                          : 'Tidak ada hasil pencarian.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(familiesProvider);
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: families.length,
                itemBuilder: (context, index) {
                  final family = families[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          family.headOfHousehold.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        family.headOfHousehold,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('KK: ${family.kkNumber}'),
                          Text(
                            family.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    FamilyDetailScreen(familyId: family.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
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
