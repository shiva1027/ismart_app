class NewsModel {
  final String title;
  final String url;
  final DateTime? publishedAt;

  NewsModel({
    required this.title,
    required this.url,
    this.publishedAt,
  });

  factory NewsModel.fromMap(Map<String, dynamic> map) {
    return NewsModel(
      title: map['title'] ?? '',
      url: map['url'] ?? '',
      publishedAt: map['publishedAt'] != null 
        ? DateTime.parse(map['publishedAt']) 
        : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'url': url,
      'publishedAt': publishedAt?.toIso8601String(),
    };
  }
}
