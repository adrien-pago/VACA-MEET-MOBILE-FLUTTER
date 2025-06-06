import 'package:flutter/material.dart';

class HomeTheme {
  static const String backgroundImage = 'assets/background.png';

  static BoxDecoration backgroundDecoration = const BoxDecoration(
    image: DecorationImage(
      image: AssetImage(backgroundImage),
      fit: BoxFit.cover,
    ),
  );

  static TextStyle welcomeTextStyle = const TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(
        blurRadius: 8,
        color: Colors.black26,
        offset: Offset(0, 2),
      ),
    ],
  );

  static TextStyle nameTextStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    shadows: [
      Shadow(
        blurRadius: 6,
        color: Colors.black26,
        offset: Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.85),
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 16,
        offset: Offset(0, 8),
      ),
    ],
  );
} 