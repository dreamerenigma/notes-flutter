import 'package:flutter/material.dart';

class PopupPositionHelper {
  static RelativeRect fromKey(GlobalKey key, BuildContext context, {double dx = 0, double dy = 0}) {
    final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);

    return RelativeRect.fromRect(Rect.fromLTWH(position.dx + dx, position.dy + box.size.height + dy, box.size.width, 0), Offset.zero & overlay.size);
  }
}
