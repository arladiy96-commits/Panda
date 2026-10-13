import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/panda_theme.dart';
import 'features/home/home_screen.dart';
import 'features/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const PandaApp());
}

class PandaApp extends StatefulWidget {
  const PandaApp({super.key});

  @override
  State<PandaApp> createState() => _PandaAppState();
}

class _PandaAppState extends State<PandaApp> {
  bool _started = false;

  void _openHome() {
    if (!mounted || _started) return;
    setState(() => _started = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panda',
      debugShowCheckedModeBanner: false,
      theme: PandaTheme.dark,
      // No AnimatedSwitcher here: it cross-faded the splash with HomeScreen,
      // making the menu visible through the animation in the previous build.
      home: _started
          ? const HomeScreen(key: ValueKey('home'))
          : SplashScreen(
              key: const ValueKey('splash'),
              onFinished: _openHome,
            ),
    );
  }
}
