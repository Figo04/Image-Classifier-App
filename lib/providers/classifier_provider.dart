import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_classifier_app/models/classification_result.dart';
import 'package:image_classifier_app/services/tflite_service.dart';

// Provider for TfliteService
final tfliteServiceProvider = Provider<TfliteService>((ref) {
  return TfliteService();
});

// state untuk Classification
class ClassificationState {
  final File? selectedImage;     // Foto yang dipilih user
  final List<ClassificationResult>? results;  // Hasil klasifikasi
  final bool isLoading;          // Sedang process?
  final bool isModelLoaded;      // Model sudah di-load?
  final String? error;           // Error message

  ClassificationState({
    this.selectedImage,
    this.results,
    this.isLoading = false,
    this.isModelLoaded = false,
    this.error,
  });

  ClassificationState copyWith({
    File? selectedImage,
    List<ClassificationResult>? results,
    bool? isLoading,
    bool? isModelLoaded,
    String? error,
    bool clearImage = false,
    bool clearResults = false,
  }) {
    return ClassificationState(
      selectedImage: clearImage ? null : (selectedImage ?? this.selectedImage),
      results: clearResults ? null : (results ?? this.results),
      isLoading: isLoading ?? this.isLoading,
      isModelLoaded: isModelLoaded ?? this.isModelLoaded,
      error: error,
    );
  }
}

// Classfier Notifier
class ClassifierProvider extends StateNotifier<ClassificationState> {
  final TfliteService _tfliteService;

  ClassifierProvider(this._tfliteService) : super(ClassificationState()) {
    _initModel();
  }

  // Initialize model saat app dibuka
  Future<void> _initModel() async {
    try {
      state = state.copyWith(isLoading: true);

      await _tfliteService.loadModel();
      state = state.copyWith(isLoading: false, isModelLoaded: true);

      print('Model loaded successfully');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load model: $e',
      );
    }
  }

  // Classify image
  Future<void> classifyImage(File imageFile) async {
    if (!state.isModelLoaded) {
      state = state.copyWith(error: 'Model not loaded yet');
      return;
    }

    try {
      state = state.copyWith(
        selectedImage: imageFile,
        isLoading: true,
        error: null,
        clearResults: true,
      );

      // Run classification
      final results = await _tfliteService.classifyImage(imageFile);

      state = state.copyWith(isLoading: false, results: results);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Classification failed: $e',
      );
    }
  }

  // Clear results
  void clearResults() {
    state = ClassificationState(isModelLoaded: state.isModelLoaded);
  }

  @override
  void dispose() {
    _tfliteService.dispose();
    super.dispose();
  }
}

// Provider untuk ClassifierProvider
final classifierProvider = StateNotifierProvider<ClassifierProvider, ClassificationState>((ref) {
  final tfliteService = ref.watch(tfliteServiceProvider);
  return ClassifierProvider(tfliteService);
});

