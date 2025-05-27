import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:async';


class GeminiRestService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  // TODO: Move this to a secure configuration file or environment variable
  static const String _apiKey = 'AIzaSyDErDVclH9Fs_KrYglpypqktVihbwJVgZA';

  // Hệ thống prompt để định hướng AI trở thành trợ lý ẩm thực
  static const String _systemPrompt = '''
Bạn là một trợ lý ẩm thực chuyên nghiệp, có kiến thức sâu rộng về ẩm thực Việt Nam và thế giới. 
Nhiệm vụ của bạn là:
1. Tư vấn món ăn phù hợp với sở thích và nhu cầu của khách hàng
2. Giải thích về nguyên liệu và cách chế biến
3. Đề xuất món ăn kèm phù hợp
4. Tư vấn về giá cả và khẩu phần
5. Gợi ý các món ăn theo mùa hoặc dịp đặc biệt

Hãy trả lời ngắn gọn, dễ hiểu và thân thiện. Nếu khách hàng không cung cấp đủ thông tin, hãy đặt câu hỏi để hiểu rõ hơn về nhu cầu của họ.
''';

  Future<String> sendMessage(String message) async {
    try {
      if (message.trim().isEmpty) {
        throw Exception('Vui lòng nhập tin nhắn');
      }

      // Kết hợp system prompt với tin nhắn của người dùng
      final fullPrompt = '$_systemPrompt\n\nKhách hàng: $message';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': fullPrompt}]}],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Kết nối bị gián đoạn. Vui lòng thử lại'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];

        if (text == null) {
          throw Exception('Không nhận được phản hồi từ hệ thống');
        }

        return text;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Không thể kết nối: ${errorData['error']?['message'] ?? 'Lỗi không xác định'}');
      }
    } on TimeoutException {
      throw Exception('Kết nối bị gián đoạn. Vui lòng thử lại');
    } on FormatException {
      throw Exception('Lỗi định dạng dữ liệu');
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi trong GeminiRestService: $e');
      }
      throw Exception('Đã xảy ra lỗi. Vui lòng thử lại sau');
    }
  }
}