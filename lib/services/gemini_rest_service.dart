import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiRestService {
  final String apiKey;

  GeminiRestService(this.apiKey);

  Future<String> generateContent(String prompt) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
    );

    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 'Không có phản hồi từ Gemini.';
    } else {
      return 'Lỗi: ${response.statusCode} - ${response.body}';
    }
  }
} 