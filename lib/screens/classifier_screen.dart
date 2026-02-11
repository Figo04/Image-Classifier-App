import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_classifier_app/providers/classifier_provider.dart';
import 'package:image_classifier_app/widgets/image_picker_section.dart';
import 'package:image_classifier_app/widgets/results_display.dart';

class ClassifierScreen extends ConsumerWidget {
  const ClassifierScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classifierState = ref.watch(classifierProvider);
    final classifierNotifier = ref.read(classifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Classifier'),
        backgroundColor: Colors.blue.shade500,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (classifierState.selectedImage != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                classifierNotifier.clearResults();
              },
              tooltip: 'Clear',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            if (!classifierState.isModelLoaded)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.orange.shade100,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Loading AI model...',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

            // Error message
            if (classifierState.error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        classifierState.error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),

            // Image Picker Section
            ImagePickerSection(
              currentImage: classifierState.selectedImage,
              onImageSelected: (image) {
                classifierNotifier.classifyImage(image);
              },
            ),

            // Results Display
            if (classifierState.isLoading)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Classifying image...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

            // Results
            if (classifierState.results != null &&
                classifierState.results!.isNotEmpty &&
                !classifierState.isLoading)
              ResultsDisplay(results: classifierState.results!),
          ],
        ),
      ),
    );
  }
}
