import 'package:flutter/material.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerPage({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late FlickManager flickManager;
  bool _isInitialized = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() async {
    if (_isDisposed) return;

    try {
      String videoUrl = widget.videoUrl;
      if (videoUrl.contains('drive.google.com')) {
        final fileId = videoUrl.split('/d/')[1].split('/')[0];
        videoUrl = 'https://drive.google.com/uc?export=download&id=$fileId';
      }

      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.networkUrl(
          Uri.parse(videoUrl),
        ),
        autoPlay: true,
      );

      if (!_isDisposed && mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Ошибка инициализации видео: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (_isInitialized) {
      flickManager.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: _isInitialized
              ? AspectRatio(
                  aspectRatio: 16 / 9,
                  child: FlickVideoPlayer(
                    flickManager: flickManager,
                    flickVideoWithControls: const FlickVideoWithControls(
                      controls: FlickPortraitControls(),
                    ),
                    flickVideoWithControlsFullscreen:
                        const FlickVideoWithControls(
                      controls: FlickLandscapeControls(),
                    ),
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
