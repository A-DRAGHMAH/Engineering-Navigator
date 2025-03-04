class ChatMessageModel {
  final String id;
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final bool isVoice;

  ChatMessageModel({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.isVoice = false,
  });
} 