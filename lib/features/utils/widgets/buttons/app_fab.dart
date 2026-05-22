import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_vectors.dart';

class AppFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget? child;
  final double size;
  final String? heroTag;
  final BorderRadius? borderRadius;
  final bool visible;

  const AppFAB({
    super.key,
    required this.onPressed,
    this.child,
    this.size = 48,
    this.heroTag,
    this.borderRadius,
    this.visible = true,
  });

  @override
  State<AppFAB> createState() => _AppFABState();
}

class _AppFABState extends State<AppFAB> {
  double _iconScale = 1.0;
  double _containerScale = 1.0;

  void _press() {
    setState(() {
      _iconScale = 1.25;
      _containerScale = 0.9;
    });
  }

  void _release() {
    setState(() {
      _iconScale = 1.0;
      _containerScale = 1.0;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    log('FAB BUILD');

    return IgnorePointer(
      ignoring: !widget.visible,
      child: AnimatedScale(scale: widget.visible ? 1 : 0, duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic,
        child: AnimatedOpacity(opacity: widget.visible ? 1 : 0, duration: const Duration(milliseconds: 180),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _press(),
            onTapUp: (_) {
              _release();
              widget.onPressed();
            },
            onTapCancel: _release,
            child: AnimatedScale(
              scale: _containerScale,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.blueAccent.withAlpha((0.6 * 255).toInt()), blurRadius: 6, spreadRadius: 2),
                    BoxShadow(color: AppColors.blueAccent.withAlpha((0.3 * 255).toInt()), blurRadius: 6, spreadRadius: 2),
                  ],
                ),
                child: FloatingActionButton(
                  heroTag: widget.heroTag,
                  onPressed: widget.onPressed,
                  backgroundColor: AppColors.blueAccent,
                  splashColor: AppColors.blueAccent,
                  hoverColor: AppColors.blueAccent,
                  foregroundColor: AppColors.blueAccent,
                  shape: widget.borderRadius != null ? RoundedRectangleBorder(borderRadius: widget.borderRadius!) : const CircleBorder(),
                  child: AnimatedScale(
                    scale: _iconScale,
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeOut,
                    child: SvgPicture.asset(AppVectors.add, colorFilter: ColorFilter.mode(context.isDarkMode ? AppColors.white : AppColors.black, BlendMode.srcIn), width: 23, height: 23),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
