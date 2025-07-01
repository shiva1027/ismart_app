import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  final String apiKey = 'YOUR_NEWS_API_KEY';

  Future<List<Map<String, String>>> fetchNews(List<String> categories) async {
    List<Map<String, String>> articles = [];
    for (String category in categories) {
      final res = await http.get(
        Uri.parse('https://newsapi.org/v2/top-headlines?category=$category&apiKey=$apiKey&country=in')
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final news = (data['articles'] as List).take(3).map((item) => {
          'title': item['title'] ?? '',
          'url': item['url'] ?? ''
        }).toList();
        articles.addAll(news);
      }
    }
    return articles;
  }
}