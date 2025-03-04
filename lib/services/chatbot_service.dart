class ChatbotService {
  static final Map<String, String> _responses = {
    'hello': 'Hello! How can I help you today?',
    'hi': 'Hi there! What can I do for you?',
    'help': 'I can help you with engineering topics, study tips, and more!',
    'bye': 'Goodbye! Feel free to come back if you have more questions.',
    'engineering': '''Engineering is a broad field that includes:
- Computer Engineering
- Civil Engineering
- Mechanical Engineering
- Electrical Engineering
And many more!''',
    'study': '''Here are some study tips:
1. Practice regularly
2. Join study groups
3. Take good notes
4. Review past exams
5. Ask questions''',
  };

  static String getResponse(String input) {
    input = input.toLowerCase();
    
    for (var entry in _responses.entries) {
      if (input.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return 'I\'m not sure about that. Could you try asking something else?';
  }
} 