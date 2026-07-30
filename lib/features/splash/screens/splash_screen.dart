import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/app_images.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/constants/app_vectors.dart';
import '../../../utils/platforms/platform_utils.dart';
import '../../note/screens/note_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Get.offAll(() => const NoteScreen());
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: context.isDarkMode ? AppColors.black : AppColors.grey.withAlpha((0.7 * 255).toInt()),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: SafeArea(
              child: isWebOrWindows ? Image.asset(AppImages.logoSplash, width: mq.size.width * .15) : SvgPicture.asset(AppVectors.logo, width: mq.size.width * .20),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(minimum: const EdgeInsets.only(bottom: 50), child: Image.asset(AppImages.logoIS, width: 130)),
          ),
        ],
      ),
    );
  }
}
