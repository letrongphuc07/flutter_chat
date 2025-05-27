import 'package:flutter/material.dart';
import '../services/gemini_rest_service.dart';

class FloatingChatButton extends StatefulWidget {
  const FloatingChatButton({Key? key}) : super(key: key);

  @override
  State<FloatingChatButton> createState() => _FloatingChatButtonState();
}

class _FloatingChatButtonState extends State<FloatingChatButton> {
  bool _isExpanded = false;
  bool _isLoading = false;
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final GeminiRestService _geminiRestService = GeminiRestService();

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() async {
    try {
      setState(() => _isLoading = true);
      final response = await _geminiRestService.sendMessage("Xin chào, tôi muốn tư vấn món ăn!");
      setState(() {
        _messages.add({
          'text': response,
          'isUser': 'false',
        });
      });
    } catch (e) {
      _showErrorSnackBar('Không thể kết nối với trợ lý. Vui lòng thử lại sau.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text;
    setState(() {
      _messages.add({
        'text': userMessage,
        'isUser': 'true',
      });
      _messageController.clear();
      _isLoading = true;
    });

    try {
      final response = await _geminiRestService.sendMessage(userMessage);
      setState(() {
        _messages.add({
          'text': response,
          'isUser': 'false',
        });
      });
      _scrollToBottom();
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Đóng',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
      );
  }

  void _scrollToBottom() {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser ? Colors.blue : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              color: isUser ? Colors.white : Colors.black87,
              fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_isExpanded)
            Container(
              width: 320,
              height: 450,
              margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
          ),
        ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.restaurant_menu, color: Colors.blue),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                              Text(
            'Trợ lý ẩm thực',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Luôn sẵn sàng tư vấn',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            setState(() => _isExpanded = false);
                          },
          ),
        ],
      ),
                  ),
                  Expanded(
                    child: ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isUser = message['isUser'] == 'true';
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: _buildMessageBubble(message['text']!, isUser),
                        );
                      },
            ),
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
            ),
                  Container(
                    padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                      border: Border(
                        top: BorderSide(color: Colors.grey[200]!),
          ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
                            decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: _sendMessage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          FloatingActionButton(
            onPressed: () {
              setState(() => _isExpanded = !_isExpanded);
            },
            backgroundColor: Colors.blue,
            child: Icon(_isExpanded ? Icons.close : Icons.restaurant_menu),
          ),
        ],
      ),
    );
  }
} 