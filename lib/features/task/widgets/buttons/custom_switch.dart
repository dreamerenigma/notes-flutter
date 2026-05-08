import 'package:flutter/material.dart';
import '../../../../utils/constants/app_colors.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double thumbSize;


  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.thumbSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.8,
      child: SizedBox(
        height: thumbSize,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.white,
          inactiveThumbColor: AppColors.white,
          inactiveTrackColor: AppColors.darkGrey,
          activeTrackColor: AppColors.blueAccent,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
