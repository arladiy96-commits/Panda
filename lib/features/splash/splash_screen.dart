import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

/// Original Panda sequence: a 3-second animated intro, then a short static
/// logo frame while the first screen opens. No network connection is needed.
class SplashScreen extends StatefulWidget {
  const SplashScreen({required this.onFinished, super.key});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _player;
  Timer? _fallbackTimer;
  Timer? _finishTimer;
  bool _videoReady = false;
  bool _showSecond = false;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final player = VideoPlayerController.asset(
      'assets/videos/panda_splash.mp4',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _player = player;
    player.addListener(_watchVideo);
    try {
      await player.initialize();
      if (!mounted) return;
      await player.setLooping(false);
      await player.setVolume(0);
      if (!mounted) return;
      setState(() => _videoReady = true);
      await player.play();
      // In case the device's video decoder does not report completion.
      _fallbackTimer = Timer(const Duration(seconds: 5), _showSecondSplash);
    } catch (_) {
      // The static original splash is still available on older devices.
      if (mounted) _showSecondSplash();
    }
  }

  void _watchVideo() {
    final value = _player?.value;
    if (value != null && value.isInitialized && value.isCompleted) {
      _showSecondSplash();
    }
  }

  void _showSecondSplash() {
    if (_finishing || !mounted) return;
    _finishing = true;
    _fallbackTimer?.cancel();
    setState(() => _showSecond = true);
    _finishTimer = Timer(const Duration(milliseconds: 420), () {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _finishTimer?.cancel();
    _player?.removeListener(_watchVideo);
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = _player;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFF7F7F7),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/second_splash.png',
              fit: BoxFit.cover,
            ),
            if (_videoReady && !_showSecond && player != null)
              ClipRect(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: player.value.size.width,
                    height: player.value.size.height,
                    child: VideoPlayer(player),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
