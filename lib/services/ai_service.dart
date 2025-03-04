import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:appwrite/appwrite.dart';
import 'appwrite_service.dart';

class AIService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';
  static const String _apiKey = 'AIzaSyDwbmYqmDlBhONI52KD-PQa_6jr5CXIUvs';

  static final Map<String, String> _navigationKeywords = {
    'study materials': '/study-materials',
    'materials': '/study-materials',
    'calendar': '/calendar',
    'events': '/calendar',
    'faculty': '/faculty',
    'professors': '/faculty',
    'exams': '/exams',
    'exam schedules': '/exams',
    'maps': '/maps',
    'campus map': '/maps',
    'links': '/links',
    'important links': '/links',
  };

  static final FlutterTts _tts = FlutterTts();
  static final stt.SpeechToText _speech = stt.SpeechToText();

  static Future<void> initializeSpeech() async {
    await _speech.initialize();
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.9);
  }

  static Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  static Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  static bool get isListening => _speech.isListening;

  static Future<bool> startListening(Function(String) onResult) async {
    if (!_speech.isAvailable) return false;

    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      localeId: 'en_US',
    );
    return true;
  }

  static Future<void> stopListening() async {
    await _speech.stop();
  }

  static Future<Map<String, dynamic>> getResponse(String message) async {
    try {
      // Extract hall number if present
      final hallNumber = _extractHallNumber(message);
      if (hallNumber != null) {
        return await _handleHallQuery({'type': 'number', 'value': hallNumber});
      }

      // Check for navigation keywords
      final navigationPath = _checkForNavigation(message);
      
      // Make API request for non-hall queries
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [{
            "parts": [{
              "text": message
            }]
          }]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String aiResponse = data['candidates'][0]['content']['parts'][0]['text'] ?? 
          'I apologize, but I couldn\'t generate a response.';

        if (navigationPath != null) {
          aiResponse += '\n\nWould you like me to take you to the ${_getPageName(navigationPath)} page?';
        }

        return {
          'type': 'text',
          'text': aiResponse,
          'navigationPath': navigationPath,
        };
      } else {
        throw Exception('Failed to get AI response');
      }
    } catch (e) {
      debugPrint('AI Error: $e');
      return {
        'type': 'error',
        'text': 'I encountered an error processing your request.',
      };
    }
  }

  static String? _extractHallNumber(String message) {
    // Match patterns like "hall 123", "room 123", "123", etc.
    final RegExp hallPattern = RegExp(r'(?:hall|room)?\s*(\d+)', caseSensitive: false);
    final match = hallPattern.firstMatch(message);
    return match?.group(1);
  }

  static String? _checkForNavigation(String message) {
    for (var entry in _navigationKeywords.entries) {
      if (message.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  static String _getPageName(String path) {
    return path.replaceAll('-', ' ').replaceAll('/', '').trim();
  }

  static Future<Map<String, dynamic>> _handleHallQuery(Map<String, String> hallInfo) async {
    try {
      // Search for video in Appwrite
      final videoData = await _searchHallVideo(hallInfo);
      
      if (videoData != null && videoData['fileId'] != null) {
        final videoUrl = await AppwriteService.getVideoUrl(videoData['fileId'].toString());
        return {
          'type': 'video',
          'videoUrl': videoUrl,
          'text': 'Playing video guide for hall ${hallInfo['value']}',
        };
      } else {
        return {
          'type': 'filtered_list',
          'searchQuery': hallInfo['value'] ?? '',
          'text': 'No exact match found. Here are similar halls:',
        };
      }
    } catch (e) {
      debugPrint('Error handling hall query: $e');
      return {
        'type': 'error',
        'text': 'I encountered an error while searching for the hall video.',
      };
    }
  }

  static Future<Map<String, dynamic>?> _searchHallVideo(Map<String, String> hallInfo) async {
    try {
      final String searchValue = hallInfo['value'] ?? '';
      if (searchValue.isEmpty) {
        return null;
      }

      var queries = [
        Query.equal('status', 'active'),
      ];

      // Add search query based on type
      if (hallInfo['type'] == 'number') {
        queries.add(Query.equal('hallNumber', searchValue));
      } else {
        queries.add(Query.search('title', searchValue));
      }

      final response = await AppwriteService.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.collectionId,
        queries: queries,
      );

      if (response.documents.isNotEmpty) {
        return response.documents.first.data;
      }
      return null;
    } catch (e) {
      debugPrint('Error searching hall video: $e');
      return null;
    }
  }
} 