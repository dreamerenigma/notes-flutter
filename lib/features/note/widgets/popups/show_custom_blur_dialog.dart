import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../utils/constants/app_colors.dart';

class GlassSnackBarContent extends StatelessWidget {
  final String message;

  const GlassSnackBarContent({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.black.withAlpha((0.3 * 255).toInt()), borderRadius: BorderRadius.circular(16)),
          child: Text(message, style: const TextStyle(color: AppColors.white)),
        ),
      ),
    );
  }
}
