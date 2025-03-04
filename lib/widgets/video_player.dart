import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool looping;

  const VideoPlayer({
    super.key,
    required this.videoUrl,
    this.autoPlay = false,
    this.looping = false,
  });

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // ignore: deprecated_member_use
      _videoPlayerController = VideoPlayerController.network(
        widget.videoUrl,
        httpHeaders: {'Range': 'bytes=0-'},
      );

      _videoPlayerController.addListener(() {
        if (_videoPlayerController.value.hasError) {
          setState(() => _hasError = true);
        }
      });

      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoInitialize: true,
        errorBuilder: (context, errorMessage) => Center(
          child: Text('Error playing video: $errorMessage'),
        ),
        allowedScreenSleep: false,
      );
    } catch (e) {
      setState(() => _hasError = true);
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _hasError
        ? const Center(child: Text('Could not play video'))
        : (_chewieController != null &&
                _chewieController!.videoPlayerController.value.isInitialized)
            ? Chewie(controller: _chewieController!)
            : const Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}
