import 'package:flutter/material.dart';
import '../../../models/stroke_model.dart';

class HandwritingPainter extends CustomPainter {
  final List<StrokeModel> strokes;

  HandwritingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final paint = Paint()..strokeWidth = 3..strokeCap = StrokeCap.round;

    for (final stroke in strokes) {
      paint.color = stroke.color;

      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p1 = stroke.points[i];
        final p2 = stroke.points[i + 1];

        if (p1 != null && p2 != null) {
          canvas.drawLine(p1, p2, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant HandwritingPainter oldDelegate) {
    return true;
  }
}
