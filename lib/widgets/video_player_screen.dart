// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String url;
  final bool autoPlay;

  const VideoPlayerScreen({
    super.key,
    required this.url,
    this.autoPlay = true,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.network(widget.url);
      
      // Initialize controller
      await _controller.initialize();
      
      // Configure playback settings immediately
      await Future.wait([
        _controller.setLooping(true),
        _controller.setVolume(1.0),
      ]);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        
        // Play immediately without delay
        if (widget.autoPlay) {
          await _controller.play();
          debugPrint('Video playing started: ${widget.url}');
        }
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing video: $e'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hall Video Guide'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _controller.pause();
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: _isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    _VideoControls(controller: _controller),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _VideoControls extends StatelessWidget {
  final VideoPlayerController controller;

  const _VideoControls({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, VideoPlayerValue value, child) {
        return Stack(
          children: [
            // Play/Pause button
            IconButton(
              icon: Icon(
                value.isPlaying ? Icons.pause : Icons.play_arrow,
                size: 32.0,
                color: Colors.white,
              ),
              onPressed: () {
                value.isPlaying ? controller.pause() : controller.play();
              },
            ),
            // Progress bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
              ),
            ),
          ],
        );
      },
    );
  }
}
