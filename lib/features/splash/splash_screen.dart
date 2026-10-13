import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

/// Panda startup: native white screen -> original 3s video -> direct cut to Home.
/// The app UI is never rendered behind a fading splash.
class SplashScreen extends StatefulWidget {
  const SplashScreen({required this.onFinished, super.key});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _controller;
  Timer? _watchdog;
  Timer? _initializationTimeout;
  Timer? _endHold;
  bool _videoVisible = false;
  bool _useStaticFallback = false;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _initializationTimeout = Timer(
      const Duration(seconds: 6),
      _showFallback,
    );
    _prepareVideo();
  }

  Future<void> _prepareVideo() async {
    final controller = VideoPlayerController.asset(
      'assets/videos/panda_splash.mp4',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _controller = controller;
    controller.addListener(_onVideoChanged);

    try {
      await controller.initialize();
      if (!mounted || _finishing) return;
      await controller.setVolume(0);
      await controller.setLooping(false);
      if (!mounted || _finishing) return;

      // Match the short blank WHITE pause in the original startup.
      // Never show the finished-logo image before the video begins.
      await Future<void>.delayed(const Duration(milliseconds: 180));
      if (!mounted || _finishing) return;

      _initializationTimeout?.cancel();
      setState(() => _videoVisible = true);
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || _finishing) return;

      await controller.play();
      if (!mounted || _finishing) return;

      // Safety net only for devices where decoder completion isn't reported.
      _watchdog = Timer(const Duration(seconds: 6), _finishNormally);
    } catch (_) {
      _showFallback();
    }
  }

  void _onVideoChanged() {
    if (!mounted || _finishing) return;
    final value = _controller?.value;
    if (value == null) return;
    if (value.hasError) {
      _showFallback();
    } else if (_videoVisible && value.isCompleted) {
      _finishNormally();
    }
  }

  void _finishNormally() {
    if (!mounted || _finishing) return;
    _finishing = true;
    _watchdog?.cancel();

    // Leave the REAL last video frame visible (no translucent fade and
    // no jump to the PNG, whose background differs from the MP4).
    _endHold = Timer(const Duration(milliseconds: 160), () {
      if (mounted) widget.onFinished();
    });
  }

  void _showFallback() {
    if (!mounted || _finishing) return;
    _finishing = true;
    _watchdog?.cancel();
    _initializationTimeout?.cancel();
    setState(() => _useStaticFallback = true);
    // If video decoding fails, still let the user into the app.
    _endHold = Timer(const Duration(seconds: 2), () {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _watchdog?.cancel();
    _initializationTimeout?.cancel();
    _endHold?.cancel();
    _controller?.removeListener(_onVideoChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.expand(
          child: _useStaticFallback
              ? Image.asset(
                  'assets/images/second_splash.png',
                  fit: BoxFit.cover,
                )
              : _videoVisible && controller != null && controller.value.isInitialized
                  ? ClipRect(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: controller.value.size.width,
                          height: controller.value.size.height,
                          child: VideoPlayer(controller),
                        ),
                      ),
                    )
                  : const ColoredBox(color: Colors.white),
        ),
      ),
    );
  }
}
