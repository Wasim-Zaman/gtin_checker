import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../models/report.dart';
import '../../../../providers/report_providers.dart';

class CreateReportScreen extends ConsumerStatefulWidget {
  const CreateReportScreen({super.key});

  @override
  ConsumerState<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends ConsumerState<CreateReportScreen> {
  final TextEditingController _gtinController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportDateTimeProvider.notifier).state = DateTime.now();
    });
  }

  @override
  void dispose() {
    _gtinController.dispose();
    super.dispose();
  }

  void _processGtin() {
    final gtin = _gtinController.text.trim();
    if (gtin.isEmpty) return;
    ref.read(reportGtinProvider.notifier).state = gtin;
  }

  void _clearGtin() {
    _gtinController.clear();
    ref.read(reportGtinProvider.notifier).state = '';
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 50, // Lower quality for smaller files
      );

      if (pickedFiles.isNotEmpty) {
        final currentImages = ref.read(reportImagesProvider);
        final newImages = pickedFiles.map((xFile) => File(xFile.path)).toList();
        final allImages = [...currentImages, ...newImages];
        final limitedImages = allImages.take(3).toList(); // Reduce to 3 images

        ref.read(reportImagesProvider.notifier).state = limitedImages;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking images: $e')));
      }
    }
  }

  Future<void> _takePicture() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        final currentImages = ref.read(reportImagesProvider);
        if (currentImages.length < 3) {
          final newImages = [...currentImages, File(pickedFile.path)];
          ref.read(reportImagesProvider.notifier).state = newImages;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Maximum 3 images allowed')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error taking picture: $e')));
      }
    }
  }

  void _removeImage(int index) {
    final currentImages = ref.read(reportImagesProvider);
    final newImages = List<File>.from(currentImages);
    newImages.removeAt(index);
    ref.read(reportImagesProvider.notifier).state = newImages;
  }

  Future<void> _submitReport() async {
    final gtin = ref.read(reportGtinProvider);
    final images = ref.read(reportImagesProvider);
    final dateTime = ref.read(reportDateTimeProvider);

    if (gtin.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a GTIN')));
      return;
    }

    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    await ref
        .read(reportProvider.notifier)
        .createReport(gtin: gtin, dateTimeScanned: dateTime, images: images);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final images = ref.watch(reportImagesProvider);
    final reportAsync = ref.watch(reportProvider);
    final gtin = ref.watch(reportGtinProvider);

    // Listen for state changes
    ref.listen<AsyncValue<Report?>>(reportProvider, (previous, next) {
      if (previous?.isLoading == true && next.isLoading == false) {
        next.when(
          data: (report) {
            if (report != null && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report submitted successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              _clearGtin();
              ref.read(reportImagesProvider.notifier).state = [];
              context.go('/');
            }
          },
          loading: () {},
          error: (error, stackTrace) {
            if (mounted) {
              String message = 'Failed to submit report';
              if (error.toString().toLowerCase().contains('timeout')) {
                message =
                    'Request timed out. Please try with fewer/smaller images.';
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: colorScheme.error,
                ),
              );
            }
          },
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // GTIN Input
            TextField(
              controller: _gtinController,
              decoration: InputDecoration(
                labelText: 'Product GTIN',
                hintText: 'Enter product GTIN',
                prefixIcon: const Icon(Icons.qr_code_scanner),
                suffixIcon: gtin.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearGtin,
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _processGtin(),
            ),

            const SizedBox(height: 20),

            // Images Section
            Text(
              'Product Images (${images.length}/3)',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 10),

            // Image Grid
            if (images.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              images[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 10),

            // Image Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: images.length < 3 ? _takePicture : null,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: images.length < 3 ? _pickImages : null,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    gtin.isNotEmpty &&
                        images.isNotEmpty &&
                        !reportAsync.isLoading
                    ? _submitReport
                    : null,
                child: reportAsync.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
