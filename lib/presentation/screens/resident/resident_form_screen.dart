import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/resident_model.dart';
import '../../../domain/enums/gender.dart';
import '../../../domain/enums/relationship.dart';
import '../../providers/resident_provider.dart';

class ResidentFormScreen extends ConsumerStatefulWidget {
  final String familyId;
  final ResidentModel? resident; // null = create, not null = edit
  final List<ResidentModel>? familyMembers; // For parent selection

  const ResidentFormScreen({
    super.key,
    required this.familyId,
    this.resident,
    this.familyMembers,
  });

  @override
  ConsumerState<ResidentFormScreen> createState() => _ResidentFormScreenState();
}

class _ResidentFormScreenState extends ConsumerState<ResidentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();

  DateTime? _selectedBirthDate;
  Gender _selectedGender = Gender.male;
  Relationship _selectedRelationship = Relationship.child;
  String? _selectedParentId;
  bool _isLoading = false;

  bool get isEditMode => widget.resident != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _nikController.text = widget.resident!.nik;
      _nameController.text = widget.resident!.fullName;
      _selectedBirthDate = widget.resident!.birthDate;
      _birthDateController.text = DateFormat(
        'dd/MM/yyyy',
      ).format(_selectedBirthDate!);
      _selectedGender = widget.resident!.gender;
      _selectedRelationship = widget.resident!.relationship;
      _selectedParentId = widget.resident!.parentId;
    }
  }

  @override
  void dispose() {
    _nikController.dispose();
    _nameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih tanggal lahir')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final resident = ResidentModel(
        id: widget.resident?.id ?? '',
        familyId: widget.familyId,
        nik: _nikController.text.trim(),
        fullName: _nameController.text.trim(),
        birthDate: _selectedBirthDate!,
        gender: _selectedGender,
        relationship: _selectedRelationship,
        parentId: _selectedParentId,
        createdAt: widget.resident?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditMode) {
        await ref
            .read(residentNotifierProvider.notifier)
            .updateResident(widget.resident!.id, resident);
      } else {
        await ref
            .read(residentNotifierProvider.notifier)
            .createResident(resident);
      }

      // Refresh resident list
      ref.invalidate(familyResidentsProvider(widget.familyId));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Anggota keluarga berhasil diperbarui'
                  : 'Anggota keluarga berhasil ditambahkan',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? AppStrings.editResident : AppStrings.addResident,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // NIK Field
            TextFormField(
              controller: _nikController,
              decoration: const InputDecoration(
                labelText: AppStrings.nik,
                hintText: 'Contoh: 3301012001010001',
                prefixIcon: Icon(Icons.badge),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.fieldRequired;
                }
                if (value.length != 16) {
                  return AppStrings.invalidNIK;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Full Name Field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.fullName,
                hintText: 'Contoh: Ahmad Santoso',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.fieldRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Birth Date Field
            TextFormField(
              controller: _birthDateController,
              decoration: const InputDecoration(
                labelText: AppStrings.birthDate,
                hintText: 'Pilih tanggal lahir',
                prefixIcon: Icon(Icons.cake),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: _selectBirthDate,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.fieldRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Gender Dropdown
            DropdownButtonFormField<Gender>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: AppStrings.gender,
                prefixIcon: Icon(Icons.wc),
              ),
              items:
                  Gender.values.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Row(
                        children: [
                          Icon(
                            gender == Gender.male ? Icons.male : Icons.female,
                            color:
                                gender == Gender.male
                                    ? Colors.blue
                                    : Colors.pink,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(gender.label),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedGender = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Relationship Dropdown
            DropdownButtonFormField<Relationship>(
              value: _selectedRelationship,
              decoration: const InputDecoration(
                labelText: AppStrings.relationship,
                prefixIcon: Icon(Icons.family_restroom),
              ),
              items:
                  Relationship.values.map((relationship) {
                    return DropdownMenuItem(
                      value: relationship,
                      child: Text(relationship.label),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedRelationship = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Parent Selector (Optional)
            if (widget.familyMembers != null &&
                widget.familyMembers!.isNotEmpty)
              DropdownButtonFormField<String?>(
                value: _selectedParentId,
                decoration: const InputDecoration(
                  labelText: '${AppStrings.parent} (Opsional)',
                  prefixIcon: Icon(Icons.supervisor_account),
                  helperText: 'Pilih orang tua jika ada',
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Tidak ada'),
                  ),
                  ...widget.familyMembers!
                      .where(
                        (member) => member.id != widget.resident?.id,
                      ) // Exclude self
                      .map((member) {
                        return DropdownMenuItem<String?>(
                          value: member.id,
                          child: Text(
                            '${member.fullName} (${member.relationship.label})',
                          ),
                        );
                      })
                      .toList(),
                ],
                onChanged: (value) {
                  setState(() => _selectedParentId = value);
                },
              ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Text(
                        AppStrings.save,
                        style: TextStyle(fontSize: 16),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
