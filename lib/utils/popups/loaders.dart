import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../helpers/helper_functions.dart';
import 'animated_snackbar.dart';

class AppLoaders {
  static void hideSnackBar() => ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();

  static void customToast({required String message, double? width}) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        elevation: 0,
        width: width,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: AppColors.transparent,
        content: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: HelperFunctions.isDarkMode(Get.context!) ? AppColors.darkerGrey.withAlpha((0.9 * 255).toInt()) : AppColors.grey.withAlpha((0.9 * 255).toInt()),
          ),
          child: Center(child: Text(message, style: Theme.of(Get.context!).textTheme.labelLarge)),
        ),
      ),
    );
  }

  static void successSnackbar({String? title, String message = '', int duration = 3, double? width, IconData icon = Iconsax.check}) {
    SnackPosition position = SnackPosition.BOTTOM;
    EdgeInsets margin = const EdgeInsets.all(10);

    if (!kIsWeb) {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        position = SnackPosition.TOP;
      }
    }

    if (position == SnackPosition.TOP) {
      margin = const EdgeInsets.only(top: 140);
    }

    Get.snackbar(
      '',
      '',
      snackStyle: SnackStyle.FLOATING,
      maxWidth: width,
      isDismissible: true,
      backgroundColor: AppColors.primary,
      duration: Duration(seconds: duration),
      margin: margin,
      snackPosition: position,
      titleText: const SizedBox.shrink(),
      messageText: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.white, size: 22),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title != null && title.isNotEmpty ? '$title: $message' : message,
              style: TextStyle(color: AppColors.white, fontSize: AppSizes.fontSizeMd),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  static void successClipBoard({required String title, String message = '', int duration = 3}) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: AppColors.white,
      backgroundColor: AppColors.primary,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: duration),
      margin: const EdgeInsets.all(10),
      icon: const Icon(Iconsax.clipboard_tick, color: AppColors.white),
    );
  }

  static void warningSnackBar({required String title, String message = ''}) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: AppColors.white,
      backgroundColor: AppColors.orange,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(20),
      icon: const Icon(Iconsax.warning_2, color: AppColors.white),
    );
  }

  static void errorSnackBar({String? title, String message = ''}) {
    Get.snackbar(
      title ?? "",
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: AppColors.white,
      backgroundColor: AppColors.red,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(20),
      icon: const Icon(Iconsax.warning_2, color: AppColors.white),
    );
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

        return Positioned(
          left: 16,
          right: 16,
          bottom: 20,
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
