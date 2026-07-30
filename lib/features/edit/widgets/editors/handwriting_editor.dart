import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes/features/edit/widgets/editors/painters/handwriting_painter.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../models/stroke_model.dart';
import '../bars/toolbars/handwriting_toolbar.dart';
import '../panels/color_picker_panel.dart';
import 'borders/dotted_border_painter.dart';

class HandwritingEditor extends StatefulWidget {
  final VoidCallback onClose;

  const HandwritingEditor({
    super.key,
    required this.onClose,
  });

  @override
  State<HandwritingEditor> createState() => _HandwritingEditorState();
}

class _HandwritingEditorState extends State<HandwritingEditor> {
  final GlobalKey _paintKey = GlobalKey();
  List<StrokeModel> strokes = [];
  Color selectedColor = AppColors.categoryColors.first;
  double drawingPadding = 16;

  int get selectedColorIndex {
    final index = AppColors.categoryColors.indexOf(selectedColor);
    return index < 0 ? 0 : index;
  }

  bool _isInsideDrawingArea(Offset position) {
    const double left = 0;
    const double top = 0;
    const double right = 360;
    const double bottom = 500;

    return position.dx >= left && position.dx <= right && position.dy >= top && position.dy <= bottom;
  }

  void _showColorPickerPanelDialog() {
    showDialog(
      context: context,
      barrierColor: AppColors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return Dialog(
              backgroundColor: context.isDarkMode ? AppColors.nightGrey : AppColors.grey,
              elevation: 0,
              insetPadding: const EdgeInsets.only(bottom: 100),
              alignment: Alignment.bottomCenter,
              child: ColorPickerPanel(
                selectedColorIndex: selectedColorIndex,

                onColorSelected: (index) {
                  final color = AppColors.categoryColors[index];

                  setState(() {
                    selectedColor = color;
                  });

                  dialogSetState(() {});
                },

                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: ClipRect(
            child: CustomPaint(
              key: _paintKey,
              painter: DottedBorderPainter(),
              foregroundPainter: HandwritingPainter(strokes),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (details) {
                  if (!_isInsideDrawingArea(details.localPosition)) return;

                  setState(() {
                    strokes.add(StrokeModel(color: selectedColor, points: [details.localPosition]));
                  });
                },
                onPanUpdate: (details) {
                  if (!_isInsideDrawingArea(details.localPosition)) return;

                  setState(() {
                    strokes.last.points.add(details.localPosition);
                  });
                },
                onPanEnd: (_) {
                  if (strokes.isNotEmpty) {
                    strokes.last.points.add(null);
                  }
                },
                child: Container(),
              ),
            ),
          ),
        ),
        Align(alignment: Alignment.bottomCenter,
          child: HandwritingToolbar(
            selectedColor: selectedColor,
            onKeyboardPressed: widget.onClose,
            onColorChanged: (color) {
              setState(() {
                selectedColor = color;
              });
            },
            onShowColorPicker: _showColorPickerPanelDialog,
          ),
        ),
      ],
    );
  }
}
