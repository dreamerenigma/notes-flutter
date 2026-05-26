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

  List<BoxShadow> lightShadows = [
    BoxShadow(color: const Color(0xFF4F8CFF).withAlpha((0.35 * 255).toInt()), blurRadius: 18, spreadRadius: 2, offset: const Offset(0, 6)),
    BoxShadow(color: const Color(0xFF6C5CE7).withAlpha((0.25 * 255).toInt()), blurRadius: 28, spreadRadius: 4, offset: const Offset(0, 8)),
    BoxShadow(color: const Color(0xFF6C5CE7).withAlpha((0.15 * 255).toInt()), blurRadius: 40, spreadRadius: 6, offset: const Offset(0, 12)),
    BoxShadow(color: const Color(0xFF00D2FF).withAlpha((0.15 * 255).toInt()), blurRadius: 40, spreadRadius: 6, offset: const Offset(0, 16)),
  ];

  List<BoxShadow> darkShadows = [
    BoxShadow(color: AppColors.blueAccent.withAlpha((0.6 * 255).toInt()), blurRadius: 6, spreadRadius: 2),
    BoxShadow(color: AppColors.blueAccent.withAlpha((0.3 * 255).toInt()), blurRadius: 6, spreadRadius: 2),
  ];

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
                width: widget.size, height: widget.size, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: context.isDarkMode ? darkShadows : lightShadows),
                child: _buildFab(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    final fab = FloatingActionButton(
      heroTag: widget.heroTag,
      onPressed: widget.onPressed,
      backgroundColor: context.isDarkMode ? AppColors.blueAccent : AppColors.white,
      splashColor: AppColors.blueAccent,
      hoverColor: AppColors.blueAccent,
      shape: widget.borderRadius != null ? RoundedRectangleBorder(borderRadius: widget.borderRadius!) : const CircleBorder(),
      elevation: 0,
      child: AnimatedScale(
        scale: _iconScale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: context.isDarkMode
          ? SvgPicture.asset(AppVectors.add, width: 23, height: 23, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn))
          : ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(colors: [Color(0xFF4A90E2), Color(0xFF6C5CE7)], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(bounds);
              },
              child: SvgPicture.asset(AppVectors.add, colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn), width: 23, height: 23),
            ),
      ),
    );

    if (context.isDarkMode) return fab;

    return Container(decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.blueAccent), child: fab);
  }
}
