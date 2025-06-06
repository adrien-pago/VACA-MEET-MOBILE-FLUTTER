import 'package:flutter/material.dart';

class ActivityCampingTheme {
  static const String backgroundImage = 'assets/background.png';

  static BoxDecoration backgroundDecoration = const BoxDecoration(
    image: DecorationImage(
      image: AssetImage(backgroundImage),
      fit: BoxFit.cover,
    ),
  );

  static TextStyle titleStyle = const TextStyle(
    fontSize: 26,
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
    color: Colors.white.withOpacity(0.95),
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.10),
        blurRadius: 18,
        offset: const Offset(0, 6),
      ),
    ],
  );

  static TextStyle headerStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 15,
    color: Color(0xFF1A237E),
  );

  static TextStyle slotStyle = const TextStyle(
    fontSize: 13,
    color: Colors.black87,
  );

  static TextStyle activityTextStyle = const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  static TextStyle legendTextStyle = const TextStyle(
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );
}
