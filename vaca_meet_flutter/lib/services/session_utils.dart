import 'package:flutter/material.dart';

Future<void> handleSessionExpired(BuildContext context, dynamic error) async {
  final errorStr = error.toString();
  if (errorStr.contains('401') || errorStr.toLowerCase().contains('unauthorized')) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expirée, veuillez vous reconnecter'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pushReplacementNamed(context, '/');
    }
  }
} 