// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../services/ai_service.dart';

class UserChatbotPage extends StatefulWidget {
  const UserChatbotPage({super.key});

  @override
  State<UserChatbotPage> createState() => _UserChatbotPageState();
}

class _UserChatbotPageState extends State<UserChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _addMessage(
      'Hello! I\'m your Engineering Assistant powered by engineering navigator AI. How can I help you?',
      false,
      null,
    );
    AIService.initializeSpeech();
  }

  void _addMessage(String message, bool isUserMessage, String? navigationPath) {
    setState(() {
      _messages.add({
        'message': message,
        'isUserMessage': isUserMessage,
        'navigationPath': navigationPath,
        'timestamp': DateTime.now(),
      });
    });
  }

  Future<void> _startVoiceInput() async {
    final isAvailable = await AIService.startListening((text) {
      if (text.isNotEmpty) {
        _controller.text = text;
      }
    });

    if (!isAvailable) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }

    setState(() => _isListening = true);
  }

  Future<void> _stopVoiceInput() async {
    await AIService.stopListening();
    setState(() => _isListening = false);
    if (_controller.text.isNotEmpty) {
      _sendMessage();
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    String message = _controller.text;
    _controller.clear();

    if (!mounted) return;
    _addMessage(message, true, null);
    setState(() => _isTyping = true);

    try {
      final response = await AIService.getResponse(message);
      if (!mounted) return;
      _addMessage(
        response['text'], 
        false, 
        response['navigationPath'],
      );
      await AIService.speak(response['text']);
    } catch (e) {
      if (!mounted) return;
      _addMessage(
        'Sorry, I encountered an error. Please try again.',
        false,
        null,
      );
    } finally {
      if (mounted) {
        setState(() => _isTyping = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering Assistant'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(
                  message: message['message'],
                  isUser: message['isUserMessage'],
                  navigationPath: message['navigationPath'],
                );
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isUser,
    String? navigationPath,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.assistant,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser 
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isUser ? Colors.white : null,
                    ),
                  ),
                ),
                if (navigationPath != null && !isUser) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Go to page'),
                    onPressed: () => Navigator.pushNamed(context, navigationPath),
                  ),
                ],
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? Colors.red : null,
            ),
            onPressed: _isListening ? _stopVoiceInput : _startVoiceInput,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type or speak your message...',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Available Topics'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You can ask about:'),
            SizedBox(height: 8),
            Text('• Engineering concepts'),
            Text('• Study tips'),
            Text('• Course information'),
            Text('• And more!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    AIService.stopSpeaking();
    AIService.stopListening();
    _controller.dispose();
    super.dispose();
  }
}

 
