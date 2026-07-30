import 'package:flutter/material.dart';
import '../../../../utils/constants/app_colors.dart';

class ColorPickerPanel extends StatefulWidget {
  final int selectedColorIndex;
  final ValueChanged<int> onColorSelected;
  final EdgeInsetsGeometry padding;

  const ColorPickerPanel({
    super.key,
    required this.selectedColorIndex,
    required this.onColorSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  @override
  State<ColorPickerPanel> createState() => _ColorPickerPanelState();
}

class _ColorPickerPanelState extends State<ColorPickerPanel> {

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: widget.padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int index = 0; index < AppColors.categoryColors.length; index++)
            Expanded(
              child: GestureDetector(
                onTap: (){
                  widget.onColorSelected(index);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: AppColors.categoryColors[index], shape: BoxShape.circle),
                    ),
                    if(widget.selectedColorIndex == index)
                      Container(width: 11, height: 11, decoration: const BoxDecoration(color: AppColors.black, shape: BoxShape.circle)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
