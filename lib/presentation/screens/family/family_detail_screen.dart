import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/family_model.dart';
import '../../../data/models/resident_model.dart';
import '../../providers/family_provider.dart';
import '../../providers/resident_provider.dart';
import '../resident/resident_form_screen.dart';
import 'family_form_screen.dart';
import 'widgets/lineage_tree_view.dart';

class FamilyDetailScreen extends ConsumerWidget {
  final String familyId;

  const FamilyDetailScreen({super.key, required this.familyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyAsync = ref.watch(familyDetailProvider(familyId));
    final residentsAsync = ref.watch(familyResidentsProvider(familyId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.familyDetail),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final family = familyAsync.value;
              if (family != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FamilyFormScreen(family: family),
                  ),
                ).then((_) {
                  // Refresh data after edit
                  ref.invalidate(familyDetailProvider(familyId));
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context, ref),
          ),
        ],
      ),
      body: familyAsync.when(
        data: (family) {
          if (family == null) {
            return const Center(child: Text(AppStrings.noData));
          }
          return _buildContent(context, ref, family, residentsAsync);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) =>
                Center(child: Text('${AppStrings.errorOccurred}: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final residents = residentsAsync.value ?? [];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ResidentFormScreen(
                    familyId: familyId,
                    familyMembers: residents,
                  ),
            ),
          ).then((_) {
            // Refresh data after adding resident
            ref.invalidate(familyResidentsProvider(familyId));
          });
        },
        icon: const Icon(Icons.person_add),
        label: const Text(AppStrings.addResident),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    FamilyModel family,
    AsyncValue<List<ResidentModel>> residentsAsync,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // House Photo Section
          _buildHousePhotoSection(family),

          // Family Information Card
          _buildFamilyInfoCard(family, context),

          // Family Members Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Anggota Keluarga',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),

          // Lineage Tree View
          residentsAsync.when(
            data: (residents) {
              if (residents.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'Belum ada anggota keluarga.\nTambahkan anggota baru.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return LineageTreeView(residents: residents, familyId: familyId);
            },
            loading:
                () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
            error:
                (error, stack) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: $error'),
                ),
          ),

          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildHousePhotoSection(FamilyModel family) {
    return Container(
      width: double.infinity,
      height: 250,
      color: AppColors.border,
      child:
          family.housePhotoUrl != null && family.housePhotoUrl!.isNotEmpty
              ? CachedNetworkImage(
                imageUrl: family.housePhotoUrl!,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                errorWidget:
                    (context, url, error) => const Center(
                      child: Icon(
                        Icons.home,
                        size: 64,
                        color: AppColors.textHint,
                      ),
                    ),
              )
              : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home, size: 64, color: AppColors.textHint),
                    SizedBox(height: 8),
                    Text(
                      'Foto rumah belum tersedia',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildFamilyInfoCard(FamilyModel family, BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              icon: Icons.credit_card,
              label: AppStrings.kkNumber,
              value: family.kkNumber,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.person,
              label: AppStrings.headOfHousehold,
              value: family.headOfHousehold,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.location_on,
              label: AppStrings.address,
              value: family.address,
            ),
            if (family.gmapsLink != null && family.gmapsLink!.isNotEmpty) ...[
              const Divider(height: 24),
              _buildGmapsLinkRow(family.gmapsLink!, context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGmapsLinkRow(String gmapsLink, BuildContext context) {
    return InkWell(
      onTap: () => _openGoogleMaps(gmapsLink, context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.map, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lokasi Google Maps',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        gmapsLink,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.open_in_new, size: 16, color: Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openGoogleMaps(String link, BuildContext context) async {
    try {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(AppStrings.deleteFamily),
            content: const Text(AppStrings.confirmDelete),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(AppStrings.cancel),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await ref
                        .read(familyRepositoryProvider)
                        .deleteFamily(familyId);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(AppStrings.deleteSuccess)),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text(AppStrings.delete),
              ),
            ],
          ),
    );
  }
}
