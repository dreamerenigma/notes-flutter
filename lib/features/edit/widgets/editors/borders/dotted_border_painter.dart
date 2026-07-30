import 'package:flutter/material.dart';
import '../../../../../utils/constants/app_colors.dart';

class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {

    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.darkerGrey, AppColors.darkerGrey, AppColors.darkerGrey.withAlpha(0)],
      stops: const [0.0, 0.9, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height),
    );
    final paint = Paint()..color = AppColors.softNight..shader = shader..style = PaintingStyle.fill;

    const double radius = 0.5;
    const double spacing = 4;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawCircle(Offset(x, 0), radius, paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawCircle(Offset(0, y), radius, paint);
      canvas.drawCircle(Offset(size.width, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
