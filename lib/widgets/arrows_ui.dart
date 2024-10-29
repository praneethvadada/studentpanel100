import 'package:flutter/material.dart';

class LeftArrowPainter extends CustomPainter {
  final Color strokeColor;
  final double strokeWidth;
  final PaintingStyle paintingStyle;

  LeftArrowPainter({
    required this.strokeColor,
    required this.strokeWidth,
    required this.paintingStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    Path path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(size.width * 0.3, size.height * 0.5);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width * 0.7, size.height * 0.5);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class RightArrowPainter extends CustomPainter {
  final Color strokeColor;
  final double strokeWidth;
  final PaintingStyle paintingStyle;

  RightArrowPainter({
    required this.strokeColor,
    required this.strokeWidth,
    required this.paintingStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    Path path = Path();
    path.moveTo(0, 0); // Start at the top-left corner
    path.lineTo(
        size.width * 0.7, size.height * 0.5); // Draw a line to the middle-right
    path.lineTo(0, size.height); // Draw a line to the bottom-left corner
    path.lineTo(size.width * 0.3,
        size.height * 0.5); // Draw a line to the middle-right bottom
    path.close(); // Close the path to form the arrow shape

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
