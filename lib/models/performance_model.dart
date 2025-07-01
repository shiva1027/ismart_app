class PerformanceModel {
  final String level;
  final List<String> suggestedCourses;
  final double? score;
  final DateTime lastUpdated;

  PerformanceModel({
    required this.level,
    required this.suggestedCourses,
    this.score,
    required this.lastUpdated,
  });

  factory PerformanceModel.fromMap(Map<String, dynamic> map) {
    return PerformanceModel(
      level: map['level'] ?? 'Unknown',
      suggestedCourses: List<String>.from(map['suggestedCourses'] ?? []),
      score: map['score']?.toDouble(),
      lastUpdated: map['lastUpdated'] != null 
        ? DateTime.parse(map['lastUpdated']) 
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'suggestedCourses': suggestedCourses,
      'score': score,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  PerformanceModel copyWith({
    String? level,
    List<String>? suggestedCourses,
    double? score,
    DateTime? lastUpdated,
  }) {
    return PerformanceModel(
      level: level ?? this.level,
      suggestedCourses: suggestedCourses ?? this.suggestedCourses,
      score: score ?? this.score,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
