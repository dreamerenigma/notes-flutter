import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:notes/utils/constants/app_vectors.dart';
import '../../../utils/constants/app_colors.dart';
import '../../utils/widgets/scrolls/no_glow_scroll_behavior.dart';
import '../widgets/app_bars/custom_app_bar.dart';
import '../widgets/rows/settings_row.dart';

class ManageAccountScreen extends StatefulWidget {
  const ManageAccountScreen({super.key});

  @override
  State<ManageAccountScreen> createState() => _ManageAccountScreenState();
}

class _ManageAccountScreenState extends State<ManageAccountScreen> {
  @override
  Widget build(BuildContext context) {
    final baseColor = context.isDarkMode ? AppColors.black : AppColors.white;

    return Scaffold(
      backgroundColor: baseColor,
      appBar: const CustomAppBar(title: 'Управление аккаунтом'),
      body: _buildSettings(),
    );
  }

  Widget _buildSettings() {
    return ScrollConfiguration(
      behavior: NoGlowScrollBehavior(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        children: [
          SettingsRow(
            leading: SvgPicture.asset(AppVectors.clearData, width: 24, height: 24, colorFilter: ColorFilter.mode(context.isDarkMode ? AppColors.white : AppColors.black, BlendMode.srcIn)),
            title: 'Очистить все данные',
            onTap: () {},
          ),
          SettingsRow(
            leading: SvgPicture.asset(AppVectors.deleteAccount, width: 24, height: 24, colorFilter: ColorFilter.mode(context.isDarkMode ? AppColors.white : AppColors.black, BlendMode.srcIn)),
            title: 'Удалить учетную запись',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
