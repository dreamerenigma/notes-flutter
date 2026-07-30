import 'package:flutter/material.dart';

class AnchoredDialog {
  static Future<T?> show<T>({required BuildContext context, required GlobalKey targetKey, required Widget child, double topOffset = 8, double leftOffset = 0}) async {
    final targetContext = targetKey.currentContext;

    if (targetContext == null) {
      return null;
    }

    final RenderBox renderBox = targetContext.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return showGeneralDialog<T>(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: 'Закрыть меню',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned(top: position.dy + size.height + topOffset, left: position.dx + leftOffset, child: child),
          ],
        );
      },
      transitionBuilder: (_, animation, _, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: Tween<double>(begin: 0.95, end: 1).animate(animation), child: child),
        );
      },
    );
  }
}
