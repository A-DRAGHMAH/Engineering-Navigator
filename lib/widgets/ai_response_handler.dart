import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import 'video_player_screen.dart';

class AIResponseHandler extends StatelessWidget {
  final String query;

  const AIResponseHandler({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: AIService.getResponse(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final response = snapshot.data!;
        
        switch (response['type']) {
          case 'video':
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(
                    url: response['videoUrl'],
                    autoPlay: true,
                  ),
                ),
              );
              debugPrint('Navigating to video: ${response['videoUrl']}');
            });
            return const Center(child: CircularProgressIndicator());
          
          case 'filtered_list':
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushNamed(
                context,
                '/hall-videos',
                arguments: {'searchQuery': response['searchQuery']},
              );
            });
            return const Center(child: CircularProgressIndicator());
          
          case 'error':
          case 'text':
          default:
            return Text(response['text']);
        }
      },
    );
  }
} 