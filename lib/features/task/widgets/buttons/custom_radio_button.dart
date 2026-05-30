import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../../../../utils/platforms/platform_utils.dart';
import '../../../note/widgets/popups/light_dialog.dart';

class CustomRadioButton extends StatefulWidget {
  final String? title;
  final String? imagePath;
  final int? value;
  final int? groupValue;
  final ValueChanged<int?> onChanged;
  final EdgeInsetsGeometry padding;
  final double? fontSize;

  const CustomRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.title,
    this.imagePath,
    this.padding = const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
    this.fontSize,
  });

  @override
  State<CustomRadioButton> createState() => _CustomRadioButtonState();
}

class _CustomRadioButtonState extends State<CustomRadioButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = widget.value == widget.groupValue;
    final Color selectedColor = colorsController.getColor(colorsController.selectedColorScheme.value);
    final double textSize = widget.fontSize ?? (isWebOrWindows ? 15 : AppSizes.fontSizeMd);

    return GestureDetector(
      onTap: () => widget.onChanged(widget.value),
      behavior: HitTestBehavior.translucent,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: widget.padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(color: _isHovered ? AppColors.steelGrey.withAlpha((0.3 * 255).toInt()) : AppColors.transparent, shape: BoxShape.circle),
                    child: Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? selectedColor : AppColors.darkGrey, width: 1.5)),
                      child: Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: isSelected ? selectedColor : AppColors.transparent),
                        ),
                      ),
                    ),
                  ),
                  if (widget.title != null) const SizedBox(width: 12),
                  if (widget.title != null)
                    Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 150),
                      child: Text(
                        widget.title ?? '',
                        style: TextStyle(fontSize: textSize, fontWeight: FontWeight.w300),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ),
                ],
              ),
            ),
            if (widget.imagePath?.isNotEmpty ?? false)
              ClipRRect(borderRadius: BorderRadius.circular(3), child: SvgPicture.asset(widget.imagePath!, width: 25, height: 25)),
          ],
        ),
      ),
    );
  }
}
