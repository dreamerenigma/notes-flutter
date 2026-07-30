import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/settings/widgets/dialogs/light_dialog.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import 'animated_snackbar.dart';

class Dialogs {
  static void showSnackbar(BuildContext context, String msg, {double? fontSize, EdgeInsets? margin, EdgeInsets? padding}) {
    fontSize ??= AppSizes.fontSizeSm;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center, style: TextStyle(color: AppColors.white, fontSize: fontSize)),
        backgroundColor: colorsController.getColor(colorsController.selectedColorScheme.value).withAlpha((0.8 * 255).toInt()),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  static void showSnackbarMargin(BuildContext context, String msg, {EdgeInsetsGeometry? margin, double? fontSize}) {
    margin ??= const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    fontSize ??= AppSizes.fontSizeSm;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center, style: TextStyle(color: AppColors.white, fontSize: fontSize)),
        backgroundColor: AppColors.blue.withAlpha((0.8 * 255).toInt()),
        behavior: SnackBarBehavior.floating,
        margin: margin,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static Future<void> showProgressBar(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(colorsController.getColor(colorsController.selectedColorScheme.value))),
            ),
          ),
        );
      },
    );
  }

  static Future<void> showProgressBarDialog(
    BuildContext context, {
    required String title,
    required String message,
    bool verticalLayout = false,
    double maxWidth = 300,
    double maxHeight = 200,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.isDarkMode ? AppColors.blackGrey : AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalLayout
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: SizedBox(
                              width: 42,
                              height: 42,
                              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(colorsController.getColor(colorsController.selectedColorScheme.value))),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(title, style: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.normal), textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          Text(message, style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.darkGrey), textAlign: TextAlign.center),
                        ],
                      ),
                    )
                  : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 42,
                        height: 42,
                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(colorsController.getColor(colorsController.selectedColorScheme.value))),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Text(message, style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.darkGrey), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void hideProgressBar(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  static Future<void> showCustomDialog({
    required BuildContext context,
    required String message,
    required Duration duration,
    bool isTransparent = false,
    double? dialogWidth,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(duration, () {
          Navigator.of(context, rootNavigator: true).pop();
        });

        return isTransparent ? Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          backgroundColor: AppColors.transparent,
          child: Container(
            width: dialogWidth ?? 310,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(color: context.isDarkMode ? AppColors.black.withAlpha((0.8 * 255).toInt()) : AppColors.white, borderRadius: BorderRadius.circular(12)),
            child: _buildDialogContent(context, message),
          ),
        )
        : AlertDialog(
            backgroundColor: context.isDarkMode ? AppColors.blackGrey : AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            content: _buildDialogContent(context, message),
          );
      },
    );
  }

  static Widget _buildDialogContent(BuildContext context, String message) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(colorsController.getColor(colorsController.selectedColorScheme.value))),
        const SizedBox(width: 30),
        Flexible(
          child: Text(
            message,
            style: TextStyle(color: context.isDarkMode ? AppColors.white : AppColors.black, fontSize: AppSizes.fontSizeSm),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}

class CustomSnackBar {
  static Future<void> showAnimatedSnackBar(BuildContext context, String message) async {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;

    GlobalKey<AnimatedSnackBarState> snackBarKey = GlobalKey<AnimatedSnackBarState>();

    overlayEntry = OverlayEntry(
      builder: (context) {
        double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

        return Positioned(
          bottom: keyboardHeight > 0 ? keyboardHeight + 12 : 12,
          left: 16,
          right: 16,
          child: AnimatedSnackBar(key: snackBarKey, message: message),
        );
      },
    );

    overlayState.insert(overlayEntry);

    await Future.delayed(const Duration(seconds: 4));

    if (snackBarKey.currentState != null) {
      await snackBarKey.currentState!.hideSnackBar();
    }
    overlayEntry.remove();
  }
}

class CustomIconSnackBar {
  static bool _isSnackBarVisible = false;

  static Future<void> showAnimatedSnackBar(BuildContext context, String message, {Widget? icon, Color? iconColor, Color? backgroundColor}) async {
    if (_isSnackBarVisible) return;

    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;

    GlobalKey<AnimatedSnackBarState> snackBarKey = GlobalKey<AnimatedSnackBarState>();

    overlayEntry = OverlayEntry(
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        const bottomBarHeight = 60.0;

        return Positioned(
          bottom: bottomPadding + bottomBarHeight + 16,
          left: 16,
          right: 16,
          child: AnimatedSnackBar(key: snackBarKey, message: message, icon: icon, iconColor: iconColor, backgroundColor: backgroundColor),
        );
      },
    );

    overlayState.insert(overlayEntry);
    _isSnackBarVisible = true;

    await Future.delayed(const Duration(seconds: 4));

    if (snackBarKey.currentState != null) {
      await snackBarKey.currentState!.hideSnackBar();
    }

    overlayEntry.remove();
    _isSnackBarVisible = false;
  }
}
