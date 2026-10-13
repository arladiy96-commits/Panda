import 'package:flutter/material.dart';

abstract final class PandaColors {
  static const background = Color(0xFF202020);
  static const card = Color(0xFF303030);
  static const chip = Color(0xFF333333);
  static const muted = Color(0xFF999999);
  static const red = Color(0xFFDF1821);
}

abstract final class PandaTheme {
  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'GolosText',
    scaffoldBackgroundColor: PandaColors.background,
    colorScheme: const ColorScheme.dark(
      surface: PandaColors.background,
      primary: Colors.white,
      secondary: PandaColors.red,
    ),
    splashColor: Colors.white12,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white),
    ),
  );
}
