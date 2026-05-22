import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  Color adaptiveDarken() {
    final luminance = computeLuminance();

    double amount;

    if (luminance > 0.7) {
      amount = 0.45;
    } else if (luminance > 0.5) {
      amount = 0.35;
    } else if (luminance > 0.3) {
      amount = 0.25;
    } else {
      amount = 0.15;
    }

    final hsl = HSLColor.fromColor(this);

    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  Color getBackgroundColor() {
    switch (this) {
      case AppColors.lightGreen:
        return darken(0.4);
      case AppColors.lightBlue:
        return darken(0.35);
      case AppColors.secondary:
        return darken(0.3);
      case AppColors.red:
        return darken(0.45);
      default:
        return darken(0.25);
    }
  }
}