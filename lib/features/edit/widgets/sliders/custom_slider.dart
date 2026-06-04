import 'package:flutter/material.dart';
import '../../../../utils/constants/app_colors.dart';

class CustomSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;

  const CustomSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: AppColors.blueAccent,
        inactiveTrackColor: AppColors.darkerGrey,
        thumbColor: AppColors.white,
        overlayColor: AppColors.transparent,
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
        trackHeight: 20,
        thumbShape: CustomSliderThumbShape(),
        trackShape: CustomSliderTrackShape(min: min, max: max),
        tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 4),
        activeTickMarkColor: AppColors.transparent,
        inactiveTickMarkColor: AppColors.transparent,
      ),
      child: Slider(value: value, min: min, max: max, divisions: 4, onChanged: onChanged),
    );
  }
}

class CustomSliderThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(24.0, 24.0);
  }

  @override
  void paint(PaintingContext context, Offset center,
      {required SliderThemeData sliderTheme,
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required Size sizeWithOverflow,
        required TextDirection textDirection,
        required double textScaleFactor,
        required double value}) {

    final Canvas canvas = context.canvas;
    const Radius thumbRadius = Radius.circular(12);
    final Paint thumbPaint = Paint()..color = sliderTheme.thumbColor!..style = PaintingStyle.fill;
    final Offset shiftedCenter = Offset(center.dx - 10, center.dy);
    final Rect thumbRect = Rect.fromCenter(center: shiftedCenter, width: 12, height: 12);
    final RRect thumbRRect = RRect.fromRectAndRadius(thumbRect, thumbRadius);

    canvas.drawRRect(thumbRRect, thumbPaint);
  }
}

class CustomSliderTrackShape extends SliderTrackShape {
  final double min;
  final double max;

  CustomSliderTrackShape({required this.min, required this.max});

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    Offset offset = Offset.zero,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset,
      {required SliderThemeData sliderTheme,
        required Animation<double> enableAnimation,
        required RenderBox parentBox,
        required TextDirection textDirection,
        required Offset thumbCenter,
        bool isDiscrete = false,
        bool isEnabled = false,
        Offset? secondaryOffset
      }) {
    final Canvas canvas = context.canvas;

    final Paint activeTrackPaint = Paint()..color = sliderTheme.activeTrackColor ?? AppColors.blue..style = PaintingStyle.fill;
    final Paint inactiveTrackPaint = Paint()..color = sliderTheme.inactiveTrackColor ?? AppColors.grey..style = PaintingStyle.fill;

    final double trackHeight = sliderTheme.trackHeight ?? 20;
    final double trackWidth = parentBox.size.width;

    final Rect trackRect = Rect.fromLTWH(offset.dx, offset.dy + (parentBox.size.height - trackHeight) / 2, trackWidth, trackHeight);
    canvas.drawRRect(RRect.fromRectAndRadius(trackRect, Radius.circular(trackHeight / 2)), inactiveTrackPaint);

    final double thumbPosition = thumbCenter.dx - offset.dx;
    final double activeTrackWidth = (thumbPosition / trackWidth) * trackWidth;
    final double constrainedWidth = activeTrackWidth.clamp(0, trackWidth);

    final Rect activeTrackRect = Rect.fromLTWH(offset.dx, offset.dy + (parentBox.size.height - trackHeight) / 2, constrainedWidth, trackHeight);
    canvas.drawRRect(RRect.fromRectAndRadius(activeTrackRect, Radius.circular(trackHeight / 2)), activeTrackPaint);
  }
}
