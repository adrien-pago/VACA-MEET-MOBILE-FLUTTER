import 'package:flutter/material.dart';

class HomeCampingTheme {
  static const String backgroundImage = 'assets/background.png';

  static BoxDecoration backgroundDecoration = const BoxDecoration(
    image: DecorationImage(
      image: AssetImage(backgroundImage),
      fit: BoxFit.cover,
    ),
  );

  static TextStyle welcomeTextStyle = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(
        blurRadius: 8,
        color: Colors.black38,
        offset: Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.92),
    borderRadius: BorderRadius.circular(28),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.10),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ],
    border: Border.all(
      color: Colors.white.withOpacity(0.18),
      width: 1.2,
    ),
  );

  static TextStyle sectionTitleStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1A237E),
    letterSpacing: 0.2,
  );

  static ButtonStyle activityButtonStyle = TextButton.styleFrom(
    foregroundColor: Colors.black,
    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
    alignment: Alignment.centerLeft,
  );
}
