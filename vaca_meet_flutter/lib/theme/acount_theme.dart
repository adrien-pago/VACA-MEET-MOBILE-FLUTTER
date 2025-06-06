import 'package:flutter/material.dart';

class AccountTheme {
  static const String backgroundImage = 'assets/background.png';

  static BoxDecoration backgroundDecoration = const BoxDecoration(
    image: DecorationImage(
      image: AssetImage(backgroundImage),
      fit: BoxFit.cover,
    ),
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.10),
        blurRadius: 18,
        offset: Offset(0, 6),
      ),
    ],
  );

  static BoxDecoration displayFieldDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: Color(0xFFE0E0E0), width: 1.3),
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

  static TextStyle labelStyle = const TextStyle(
    fontSize: 15,
    color: Colors.black54,
    fontWeight: FontWeight.w500,
  );

  static TextStyle valueStyle = const TextStyle(
    fontSize: 17,
    color: Colors.black87,
    fontWeight: FontWeight.bold,
  );

  static TextStyle sectionTitleStyle = const TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1A237E),
    shadows: [
      Shadow(
        blurRadius: 8,
        color: Colors.black26,
        offset: Offset(0, 2),
      ),
    ],
  );

  static ButtonStyle editButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: Colors.blue,
    side: const BorderSide(color: Colors.blue),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  );

  static ButtonStyle validateButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  );

  static ButtonStyle cancelButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: Colors.red,
    side: const BorderSide(color: Colors.red),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  );

  static ButtonStyle bigButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: Colors.blue,
    side: const BorderSide(color: Colors.blue),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  );

  static InputDecoration inputDecoration({String? label, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}
