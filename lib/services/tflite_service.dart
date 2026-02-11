import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:image_classifier_app/models/classification_result.dart';

class TfliteService {
  Interpreter? _interpreter;
  List<String>? _labels;

  // Model specifications
  static const String modelPath = 'assets/mobilenet_v1_1.0_224_quant.tflite';
  static const String labelsPath = 'assets/labels_mobilenet_quant_v1_224.txt';
  static const int inputSize = 224; // Model input: 224x224 pixels

  // initialize model
  Future<void> loadModel() async {
    try {
      // 1. Load TFLite model
      _interpreter = await Interpreter.fromAsset(modelPath);

      // 2. Load labels
      final labelsData = await rootBundle.loadString(labelsPath);
      _labels = labelsData
          .split('\n')
          .where((line) => line.isNotEmpty)
          .toList();

      print('Model loaded successfully');
      print('Total labels: ${_labels?.length}');
    } catch (e) {
      print('Failed to load model: $e');
      throw Exception('Failed to load model: $e');
    }
  }

  // Classify image
  Future<List<ClassificationResult>> classifyImage(File imageFile) async {
    if (_interpreter == null || _labels == null) {
      throw Exception('Model not loaded. Call loadModel() first.');
    }

    try {
      // 1. Load & decode image
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // 2. Preprocess: Resize to 224x224
      img.Image resizedImage = img.copyResize(
        image,
        width: inputSize,
        height: inputSize,
      );

      // 3. Convert to input format (Uint8List)
      var inputBytes = _imageToByteList(resizedImage);

      // 4. Prepare outpput buffer
      var outputBytes = Uint8List(1 * _labels!.length);

      // 5. Run inference
      _interpreter!.run(inputBytes, outputBytes);

      // 6. Parse results
      List<ClassificationResult> results = [];
      for (int i = 0; i < _labels!.length; i++) {
        // Convert uint8 output (0-255) to confidence (0.0-1.0)
        double confidence = outputBytes[i] / 255.0;

        results.add(
          ClassificationResult(label: _labels![i], confidence: confidence),
        );
      }

      // 7. sort by confidence
      final sorted = ClassificationResult.sortByConfidence(results);
      return sorted.take(5).toList();
    } catch (e) {
      print('Error classifying: $e');
      throw Exception('Failed to classifying: $e');
    }
  }

  // Convert image to byte list (model input format)
  Uint8List _imageToByteList(img.Image image) {
    var convertedBytes = Uint8List(1 * inputSize * inputSize * 3);
    var buffer = Uint8List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        var pixel = image.getPixel(x, y);

        // Extract RGB values
        buffer[pixelIndex++] = pixel.r.toInt(); // Red
        buffer[pixelIndex++] = pixel.g.toInt(); // Green
        buffer[pixelIndex++] = pixel.b.toInt(); // Blue
      }
    }

    return convertedBytes;
  }

  // Close interpreter
  void dispose() {
    _interpreter?.close();
  }
}
