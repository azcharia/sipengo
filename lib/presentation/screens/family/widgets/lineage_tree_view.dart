import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/models/resident_model.dart';
import '../../../providers/resident_provider.dart';
import '../../resident/resident_form_screen.dart';

class LineageTreeView extends ConsumerStatefulWidget {
  final List<ResidentModel> residents;
  final String familyId;

  const LineageTreeView({
    super.key,
    required this.residents,
    required this.familyId,
  });

  @override
  ConsumerState<LineageTreeView> createState() => _LineageTreeViewState();
}

class _LineageTreeViewState extends ConsumerState<LineageTreeView> {
  // Tracks the collapsed state of each resident node by their ID.
  // false or null = expanded, true = collapsed.
  final Map<String, bool> _collapsedNodes = {};

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.residents.length,
      itemBuilder: (context, index) {
        final resident = widget.residents[index];
        final depth = _getResidentDepth(resident, widget.residents);
        final isLast = _isLastChildAtLevel(resident, index, widget.residents);
        final isVisible = !_isAncestorCollapsed(resident, widget.residents);

        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: isVisible
              ? IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (depth > 0) ...[
                        _buildLineageGuide(depth, isLast),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildResidentCard(context, ref, resident, index),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity, height: 0),
        );
      },
    );
  }

  /// Determines if any ancestor of this resident is collapsed.
  bool _isAncestorCollapsed(ResidentModel resident, List<ResidentModel> allResidents) {
    if (resident.parentId == null) return false;

    // Check direct parent
    if (_collapsedNodes[resident.parentId] == true) return true;

    // Check recursive parents
    final parent = allResidents.where((r) => r.id == resident.parentId).firstOrNull;
    if (parent == null) return false;

    return _isAncestorCollapsed(parent, allResidents);
  }

  int _getResidentDepth(ResidentModel resident, List<ResidentModel> allResidents) {
    if (resident.parentId == null) return 0;

    final parent = allResidents.where((r) => r.id == resident.parentId).firstOrNull;
    if (parent == null) {
      if (resident.relationship.value == 'child') return 1;
      if (resident.relationship.value == 'grandchild') return 2;
      return 0;
    }

    return 1 + _getResidentDepth(parent, allResidents);
  }

  bool _isLastChildAtLevel(
    ResidentModel resident,
    int currentIndex,
    List<ResidentModel> allResidents,
  ) {
    if (resident.parentId == null) return true;

    for (int i = currentIndex + 1; i < allResidents.length; i++) {
      if (allResidents[i].parentId == resident.parentId) {
        return false;
      }
    }
    return true;
  }

  Widget _buildLineageGuide(int depth, bool isLast) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < depth - 1; i++)
          Container(
            width: 24,
            alignment: Alignment.center,
            child: Container(
              width: 2,
              color: AppColors.border,
            ),
          ),
        SizedBox(
          width: 24,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                bottom: isLast ? null : 0,
                height: isLast ? 32 : null,
                left: 11,
                child: Container(
                  width: 2,
                  color: AppColors.border,
                ),
              ),
              Positioned(
                top: 32,
                left: 11,
                right: 0,
                child: Container(
                  height: 2,
                  color: AppColors.border,
                ),
              ),
              // Premium node dot at the intersection
              Positioned(
                top: 27,
                left: 7,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
    final hasChildren = widget.residents.any((r) => r.parentId == resident.id);
    final isCollapsed = _collapsedNodes[resident.id] == true;

    return Container(
      decoration: BoxDecoration(
        color: isHead 
            ? AppColors.primary.withValues(alpha: 0.02) 
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHead ? AppColors.primary.withValues(alpha: 0.5) : AppColors.border,
          width: isHead ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showResidentOptions(context, ref, resident),
          borderRadius: BorderRadius.circular(16),
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              resident.fullName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isHead) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF59E0B), // Gold/Amber
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.star_rounded,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Relationship Badge & Fold Button
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getRelationshipColor(
                                resident.relationship.value,
                              ).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              resident.relationship.label,
                              style: TextStyle(
                                fontSize: 11,
                                color: _getRelationshipColor(
                                  resident.relationship.value,
                                ),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (hasChildren) ...[
                            const SizedBox(width: 8),
                            // Elevated/pill toggle button for expansion with animations
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _collapsedNodes[resident.id] = !isCollapsed;
                                  });
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(alpha: 0.15),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AnimatedRotation(
                                        turns: isCollapsed ? 0 : 0.25,
                                        duration: const Duration(milliseconds: 200),
                                        child: Icon(
                                          Icons.chevron_right_rounded,
                                          color: AppColors.primary,
                                          size: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        isCollapsed ? 'Lihat Silsilah' : 'Sembunyikan',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Birth Date & Age
                      Row(
                        children: [
                          Icon(
                            Icons.cake_rounded,
                            size: 14,
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${dateFormat.format(resident.birthDate)} (${resident.age} tahun)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // NIK
                      Row(
                        children: [
                          Icon(
                            Icons.badge_rounded,
                            size: 14,
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            resident.nik,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Gender Icon wrapped in smooth circle
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: resident.gender.value == 'male'
                        ? Colors.blue.withValues(alpha: 0.08)
                        : Colors.pink.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    resident.gender.value == 'male' 
                        ? Icons.male_rounded 
                        : Icons.female_rounded,
                    color: resident.gender.value == 'male' 
                        ? Colors.blue 
                        : Colors.pink,
                    size: 20,
                  ),
                ),
              ],
            ),
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
                              familyId: widget.familyId,
                              resident: resident,
                              familyMembers: widget.residents,
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
                    ref.invalidate(familyResidentsProvider(widget.familyId));

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
