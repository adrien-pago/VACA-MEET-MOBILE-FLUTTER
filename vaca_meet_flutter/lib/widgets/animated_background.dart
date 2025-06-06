import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({Key? key, required this.child}) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * t, -1 + 2 * (1 - t)),
              end: Alignment(1 - 2 * t, 1 - 2 * (1 - t)),
              colors: [
                Color.lerp(const Color(0xFF2196F3), const Color(0xFF03A9F4), t)!,
                Color.lerp(const Color(0xFF00BCD4), const Color(0xFF4DD0E1), 1 - t)!,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
} 