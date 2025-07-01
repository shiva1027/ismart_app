class CourseModel {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String imageUrl;
  final int durationInWeeks;
  final List<String> topics;
  final double rating;
  final int enrolledCount;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.imageUrl,
    required this.durationInWeeks,
    required this.topics,
    this.rating = 0.0,
    this.enrolledCount = 0,
  });

  factory CourseModel.fromMap(String id, Map<String, dynamic> map) {
    return CourseModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      instructor: map['instructor'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      durationInWeeks: map['durationInWeeks'] ?? 0,
      topics: List<String>.from(map['topics'] ?? []),
      rating: map['rating']?.toDouble() ?? 0.0,
      enrolledCount: map['enrolledCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'instructor': instructor,
      'imageUrl': imageUrl,
      'durationInWeeks': durationInWeeks,
      'topics': topics,
      'rating': rating,
      'enrolledCount': enrolledCount,
    };
  }
}
