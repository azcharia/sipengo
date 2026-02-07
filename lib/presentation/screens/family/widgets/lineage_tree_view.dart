import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/models/resident_model.dart';
import '../../../providers/resident_provider.dart';
import '../../resident/resident_form_screen.dart';

class LineageTreeView extends ConsumerWidget {
  final List<ResidentModel> residents;
  final String familyId;

  const LineageTreeView({
    super.key,
    required this.residents,
    required this.familyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: residents.length,
      itemBuilder: (context, index) {
        final resident = residents[index];
        return _buildResidentCard(context, ref, resident, index);
      },
    );
  }

  Widget _buildResidentCard(
    BuildContext context,
    WidgetRef ref,
    ResidentModel resident,
    int index,
  ) {
    final isHead = resident.relationship.value == 'head';
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isHead ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            isHead
                ? const BorderSide(color: AppColors.primary, width: 2)
                : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _showResidentOptions(context, ref, resident),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar with hierarchy indicator
              _buildAvatar(resident, isHead),
              const SizedBox(width: 16),

              // Resident Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      resident.fullName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isHead ? FontWeight.bold : FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Relationship Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getRelationshipColor(
                          resident.relationship.value,
                        ).withAlpha(25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        resident.relationship.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getRelationshipColor(
                            resident.relationship.value,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Birth Date & Age
                    Row(
                      children: [
                        const Icon(
                          Icons.cake,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${dateFormat.format(resident.birthDate)} (${resident.age} tahun)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // NIK
                    Row(
                      children: [
                        const Icon(
                          Icons.badge,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          resident.nik,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Gender Icon
              Icon(
                resident.gender.value == 'male' ? Icons.male : Icons.female,
                color:
                    resident.gender.value == 'male' ? Colors.blue : Colors.pink,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResidentOptions(
    BuildContext context,
    WidgetRef ref,
    ResidentModel resident,
  ) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: AppColors.primary),
                  title: const Text('Edit Anggota'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ResidentFormScreen(
                              familyId: familyId,
                              resident: resident,
                              familyMembers: residents,
                            ),
                      ),
                    ).then((_) {
                      // Refresh will be handled by parent
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: AppColors.error),
                  title: const Text('Hapus Anggota'),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteDialog(context, ref, resident);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.close),
                  title: const Text('Batal'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    ResidentModel resident,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(AppStrings.deleteResident),
            content: Text(
              'Apakah Anda yakin ingin menghapus ${resident.fullName}?',
            ),
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
                        .read(residentNotifierProvider.notifier)
                        .deleteResident(resident.id);

                    // Refresh resident list
                    ref.invalidate(familyResidentsProvider(familyId));

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(AppStrings.deleteSuccess),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gagal menghapus: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
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

  Widget _buildAvatar(ResidentModel resident, bool isHead) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isHead ? AppColors.primary : AppColors.primaryLight,
        shape: BoxShape.circle,
        border: Border.all(
          color: isHead ? AppColors.primaryDark : AppColors.primary,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          resident.fullName.substring(0, 1).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getRelationshipColor(String relationship) {
    switch (relationship) {
      case 'head':
        return AppColors.primary;
      case 'wife':
      case 'husband':
        return AppColors.secondary;
      case 'child':
        return Colors.blue;
      case 'grandchild':
        return Colors.purple;
      case 'parent':
      case 'grandparent':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }
}
