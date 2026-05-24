import 'package:flutter/material.dart';

class ThemeManager with ChangeNotifier {
  bool _isDarkMode = false;
  double _textScale = 1.0;

  bool get isDarkMode => _isDarkMode;
  double get textScale => _textScale;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void updateTextScale(double scale) {
    _textScale = scale;
    notifyListeners();
  }

  // Couleurs pour le thème
  Color get backgroundColor => _isDarkMode
      ? const Color(0xFF1A1A1A)
      : const Color(0xFFFAF0E6);

  Color get primaryColor => _isDarkMode
      ? const Color(0xFFFFD700)
      : const Color(0xFFB8860B);

  Color get secondaryColor => _isDarkMode
      ? const Color(0xFFB8860B)
      : const Color(0xFF8B6914);

  Color get textColor => _isDarkMode
      ? Colors.white
      : const Color(0xFF333333);

  Color get cardColor => _isDarkMode
      ? const Color(0xFF2D1B00)
      : const Color(0xFFFFF8DC);

  Color get appBarColor => _isDarkMode
      ? const Color(0xCC1A1A1A)
      : const Color(0xCCFAF0E6);

  LinearGradient get backgroundGradient => _isDarkMode
      ? const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A1A1A),
      Color(0xFF2D1B00),
      Color(0xFF1A1A1A),
    ],
  )
      : const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFAF0E6),
      Color(0xFFFFF8DC),
      Color(0xFFFAF0E6),
    ],
  );
}