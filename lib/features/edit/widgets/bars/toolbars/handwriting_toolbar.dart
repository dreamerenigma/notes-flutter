import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../../utils/constants/app_colors.dart';
import '../../../../../utils/constants/app_vectors.dart';

class HandwritingToolbar extends StatefulWidget {
  final VoidCallback? onKeyboardPressed;
  final ValueChanged<Color>? onColorChanged;
  final VoidCallback? onShowColorPicker;
  final Color selectedColor;

  const HandwritingToolbar({
    super.key,
    this.onKeyboardPressed,
    this.onColorChanged,
    this.onShowColorPicker,
    required this.selectedColor,
  });

  @override
  State<HandwritingToolbar> createState() => _HandwritingToolbarState();
}

class _HandwritingToolbarState extends State<HandwritingToolbar> {
  final List<String> tools = [AppVectors.colorWheel, AppVectors.pen, AppVectors.pencil];
  bool isExpanded = true;
  bool showColorPicker = false;
  int selectedTool = 0;
  int selectedColorIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: isExpanded ? _buildExpanded() : _buildCollapsed(),
    );
  }

  Widget _buildExpanded() {
    return Container(
      key: const ValueKey('expanded'),
      width: 210,
      height: 90,
      decoration: BoxDecoration(color: context.isDarkMode ? AppColors.nightGrey : AppColors.grey, borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      child: Column(
        children: [
          GestureDetector(
            onTap: (){
              setState(() {
                isExpanded = false;
              });
            },
            child: SizedBox(height: 32, width: double.infinity, child: Center(child: SvgPicture.asset(AppVectors.arrowDown, width: 38, height: 38, colorFilter: ColorFilter.mode(context.isDarkMode ? AppColors.darkerGrey : AppColors.black, BlendMode.srcIn)))),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildToolButton(AppVectors.keyboard, 0, iconColor: context.isDarkMode ? AppColors.grey : AppColors.black, onTap: widget.onKeyboardPressed),
                _buildVerticalDivider(),
                _buildToolButton(AppVectors.colorWheel, 1, onTap: widget.onShowColorPicker),
                _buildToolButton(AppVectors.pen, 2, iconSize: 60, padding: EdgeInsets.zero),
                _buildToolButton(AppVectors.pencil, 3, iconSize: 60, padding: EdgeInsets.only(left: 12)),
                _buildToolButton(AppVectors.circlePlus, 4, iconColor: context.isDarkMode ? AppColors.grey : AppColors.black),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsed() {
    return GestureDetector(
      key: const ValueKey('collapsed'),
      onTap: (){
        setState(() {
          isExpanded = true;
        });
      },
      child: Container(
        height: 48,
        width: 64,
        decoration: const BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Center(child: SvgPicture.asset(tools[selectedTool], width: 24, height: 24)),
      ),
    );
  }

  Widget _buildToolButton(String icon, int index, {VoidCallback? onTap, Color? iconColor, double iconSize = 24, EdgeInsetsGeometry padding = const EdgeInsets.all(12)}){
    final selected = selectedTool == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTool = index;
        });

        onTap?.call();
      },
      child: Container(
        padding: padding,
        decoration: BoxDecoration(color: selected ? (context.isDarkMode ? AppColors.nightGrey : AppColors.grey) : AppColors.transparent, borderRadius: BorderRadius.circular(14)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(icon, width: iconSize, height: iconSize, colorFilter: iconColor != null ? ColorFilter.mode(iconColor, BlendMode.srcIn) : null),
            if(index == 1)
              Container(width: 14, height: 14, decoration: BoxDecoration(color: widget.selectedColor, shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Container(height: 24, width: 1, color: context.isDarkMode ? AppColors.darkerGrey : AppColors.grey),
    );
  }
}
