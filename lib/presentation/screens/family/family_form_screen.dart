import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/family_model.dart';
import '../../providers/family_provider.dart';

class FamilyFormScreen extends ConsumerStatefulWidget {
  final FamilyModel? family; // null = create, not null = edit

  const FamilyFormScreen({super.key, this.family});

  @override
  ConsumerState<FamilyFormScreen> createState() => _FamilyFormScreenState();
}

class _FamilyFormScreenState extends ConsumerState<FamilyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kkNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _headController = TextEditingController();
  final _gmapsLinkController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  bool get isEditMode => widget.family != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _kkNumberController.text = widget.family!.kkNumber;
      _addressController.text = widget.family!.address;
      _headController.text = widget.family!.headOfHousehold;
      _gmapsLinkController.text = widget.family!.gmapsLink ?? '';
    }
  }

  @override
  void dispose() {
    _kkNumberController.dispose();
    _addressController.dispose();
    _headController.dispose();
    _gmapsLinkController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Kamera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galeri'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate image for new family
    if (!isEditMode && _selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Silakan pilih foto rumah')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final family = FamilyModel(
        id: widget.family?.id ?? '',
        kkNumber: _kkNumberController.text.trim(),
        address: _addressController.text.trim(),
        headOfHousehold: _headController.text.trim(),
        housePhotoUrl: widget.family?.housePhotoUrl,
        latitude: widget.family?.latitude,
        longitude: widget.family?.longitude,
        gmapsLink:
            _gmapsLinkController.text.trim().isEmpty
                ? null
                : _gmapsLinkController.text.trim(),
        createdAt: widget.family?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditMode) {
        // Update existing family
        await ref
            .read(familyNotifierProvider.notifier)
            .updateFamily(
              widget.family!.id,
              family,
              newHousePhoto: _selectedImage,
            );
      } else {
        // Create new family
        await ref
            .read(familyNotifierProvider.notifier)
            .createFamily(family, housePhoto: _selectedImage);
      }

      // Refresh family list
      ref.invalidate(familiesProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Keluarga berhasil diperbarui'
                  : 'Keluarga berhasil ditambahkan',
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
        title: Text(isEditMode ? AppStrings.editFamily : AppStrings.addFamily),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // House Photo Section
            _buildPhotoSection(),
            const SizedBox(height: 24),

            // KK Number Field
            TextFormField(
              controller: _kkNumberController,
              decoration: const InputDecoration(
                labelText: AppStrings.kkNumber,
                hintText: 'Contoh: 3301012001010001',
                prefixIcon: Icon(Icons.credit_card),
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
                  return AppStrings.invalidKK;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Head of Household Field
            TextFormField(
              controller: _headController,
              decoration: const InputDecoration(
                labelText: AppStrings.headOfHousehold,
                hintText: 'Contoh: Budi Santoso',
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

            // Address Field
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: AppStrings.address,
                hintText: 'Contoh: Jl. Raya Gombang No. 123, RT 01/RW 02',
                prefixIcon: Icon(Icons.location_on),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.fieldRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Google Maps Link Field
            TextFormField(
              controller: _gmapsLinkController,
              decoration: const InputDecoration(
                labelText: 'Link Google Maps (Opsional)',
                hintText: 'Contoh: https://maps.app.goo.gl/xxxxx',
                prefixIcon: Icon(Icons.map),
                helperText: 'Paste link Google Maps lokasi rumah',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 32),
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

  Widget _buildPhotoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.photo_camera, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  AppStrings.housePhoto,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (_selectedImage != null ||
                    (isEditMode && widget.family!.housePhotoUrl != null))
                  TextButton.icon(
                    onPressed: _showImageSourceDialog,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Ubah'),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Image Preview
            if (_selectedImage != null)
              _buildImagePreview(_selectedImage!)
            else if (isEditMode && widget.family!.housePhotoUrl != null)
              _buildNetworkImagePreview(widget.family!.housePhotoUrl!)
            else
              _buildImagePlaceholder(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(File image) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            image,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            backgroundColor: Colors.black54,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkImagePreview(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder();
        },
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return InkWell(
      onTap: _showImageSourceDialog,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap untuk memilih foto rumah',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Kamera atau Galeri',
              style: TextStyle(color: AppColors.textHint, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
