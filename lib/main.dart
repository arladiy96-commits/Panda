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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panda',
      debugShowCheckedModeBanner: false,
      theme: PandaTheme.dark,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: _started
            ? const HomeScreen(key: ValueKey('home'))
            : SplashScreen(
                key: const ValueKey('splash'),
                onFinished: () {
                  if (mounted) setState(() => _started = true);
                },
              ),
      ),
    );
  }
}
