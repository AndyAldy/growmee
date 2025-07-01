import 'package:flutter/material.dart';

class SmoothLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.grey.withOpacity(0.5), // Made the line a bit more visible
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 1.5), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}