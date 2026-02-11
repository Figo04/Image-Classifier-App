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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Picker Section
            ImagePickerSection(),

            const SizedBox(height: 24),

            // Results Display
            ResultsDisplay(),
          ],
        ),
      ),
    );
  }
}