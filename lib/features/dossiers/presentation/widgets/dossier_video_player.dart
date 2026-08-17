import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';

class DossierVideoPlayer extends StatefulWidget {
  final String videoPath;
  const DossierVideoPlayer({super.key, required this.videoPath});

  @override
  State<DossierVideoPlayer> createState() => _DossierVideoPlayerState();
}

class _DossierVideoPlayerState extends State<DossierVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
          });
        }
      });
      
    _controller.addListener(() {
      if (_controller.value.isPlaying != _isPlaying) {
        if (mounted) {
          setState(() {
            _isPlaying = _controller.value.isPlaying;
            if (!_isPlaying) _showControls = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      setState(() => _showControls = true);
    } else {
      _controller.setVolume(1.0);
      _controller.play();
      setState(() => _showControls = false);
      
      // Auto-hide controls after a delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _controller.value.isPlaying) {
          setState(() => _showControls = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            VideoPlayer(_controller),
            
            // Interaction layer
            GestureDetector(
              onTap: () {
                if (_isPlaying) {
                  setState(() => _showControls = !_showControls);
                  if (_showControls) {
                    Future.delayed(const Duration(seconds: 3), () {
                      if (mounted && _isPlaying) {
                        setState(() => _showControls = false);
                      }
                    });
                  }
                } else {
                  _togglePlay();
                }
              },
              child: AnimatedOpacity(
                opacity: _showControls || !_isPlaying ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Center(
                    child: GestureDetector(
                      onTap: _togglePlay,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
