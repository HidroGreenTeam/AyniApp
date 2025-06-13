class DetectionHistoryItem {
  final String id;
  final String disease;
  final String diseaseName;
  final double confidence;
  final String imagePath;
  final DateTime timestamp;
  final String recommendation;

  DetectionHistoryItem({
    required this.id,
    required this.disease,
    required this.diseaseName,
    required this.confidence,
    required this.imagePath,
    required this.timestamp,
    required this.recommendation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'disease': disease,
      'diseaseName': diseaseName,
      'confidence': confidence,
      'imagePath': imagePath,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'recommendation': recommendation,
    };
  }

  factory DetectionHistoryItem.fromMap(Map<String, dynamic> map) {
    return DetectionHistoryItem(
      id: map['id'] ?? '',
      disease: map['disease'] ?? '',
      diseaseName: map['diseaseName'] ?? '',
      confidence: map['confidence'] ?? 0.0,
      imagePath: map['imagePath'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      recommendation: map['recommendation'] ?? '',
    );
  }
}
