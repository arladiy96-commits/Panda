import 'package:flutter_test/flutter_test.dart';
import 'package:panda_flutter/core/theme/panda_theme.dart';

void main() {
  test('Panda visual theme uses a dark background', () {
    expect(PandaTheme.dark.scaffoldBackgroundColor, PandaColors.background);
  });
}
