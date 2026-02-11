class ClassificationResult {
  final String label;       // Nama objek
  final double confidence;  // Konfiden score

  ClassificationResult({
    required this.label,
    required this.confidence,
  });

  // Helper: confindece dalam persen
  String get confidencePercent {
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }

  // Sort berdasarkan confidence (tertinggi dulu)
  static List<ClassificationResult> sortByConfidence(List<ClassificationResult> results) {
    final sorted = List<ClassificationResult>.from(results);
    sorted.sort((a, b) => b.confidence.compareTo(a.confidence));
    return sorted;
  }

  @override
  String toString() {
    return '$label: $confidencePercent';
  }
}