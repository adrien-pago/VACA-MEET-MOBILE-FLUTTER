import 'package:flutter/material.dart';
import 'login_theme.dart';

class RegisterTheme {
  // Textes
  static const TextStyle title = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 1.2,
  );
  static const TextStyle subtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.white70,
    letterSpacing: 0.5,
  );
  static const TextStyle error = TextStyle(
    color: Color(0xFFD32F2F),
    fontWeight: FontWeight.w600,
  );
  static const TextStyle link = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );
  static const TextStyle label = TextStyle(
    color: Colors.white70,
    fontSize: 15,
  );

  // Espacements et tailles
  static const EdgeInsets cardPadding = EdgeInsets.all(24);
  static const EdgeInsets pagePadding = EdgeInsets.all(24);
  static const EdgeInsets errorBoxPadding = EdgeInsets.all(12);
  static const double iconSize = 80;
  static const double cardSpacing = 32;
  static const double fieldSpacing = 16;
  static const double buttonSpacing = 24;

  // Décorations
  static BoxDecoration glassCard = BoxDecoration(
    color: Colors.white.withOpacity(0.18),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: Colors.white.withOpacity(0.25),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ],
  );
  static BoxDecoration errorBox = BoxDecoration(
    color: AuthTheme.errorColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
  );
} 