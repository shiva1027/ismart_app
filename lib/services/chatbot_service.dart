import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  final String apiKey = 'YOUR_OPENAI_API_KEY';

  Future<String> getBotReply(String message) async {
    final res = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "user", "content": message}
        ]
      })
    );
    final data = jsonDecode(res.body);
    return data['choices'][0]['message']['content'];
  }
}