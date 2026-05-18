import 'dart:developer';
import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ionicons/ionicons.dart';
import 'package:notes/features/utils/widgets/scrolls/no_glow_scroll_behavior.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/constants/app_sizes.dart';
import '../../../utils/constants/app_vectors.dart';
import '../../utils/widgets/buttons/custom_switch.dart';
import '../widgets/app_bars/custom_app_bar.dart';
import '../widgets/popups/add_watermark_dialog.dart';
import '../widgets/popups/language_bottom_sheet_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final GetStorage storage = GetStorage();
  String watermarkText = 'Из Заметок Honor';
  String appVersion = '';

  @override
  void initState() {
    super.initState();
    watermarkText = storage.read('watermarkText') ?? 'Из Заметок Honor';
    loadAppVersion();
  }

  void onSave(String newText) {
    setState(() {
      watermarkText = newText;
    });
    storage.write('watermarkText', newText);
  }

  Future<int> getAndroidSdk() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    return androidInfo.version.sdkInt;
  }

  Future<void> openNotificationSettings(int sdk) async {
    AndroidIntent intent;

    if (sdk >= 26) {
      intent = AndroidIntent(
        action: 'android.settings.APP_NOTIFICATION_SETTINGS',
        arguments: {'android.provider.extra.APP_PACKAGE': 'com.inputstudios.notes'},
      );
    } else {
      intent = AndroidIntent(
        action: 'android.settings.APP_NOTIFICATION_SETTINGS',
        arguments: {'app_package': 'com.inputstudios.notes', 'app_uid': 0},
      );
    }

    await intent.launch();
  }

  Future<void> loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();

    setState(() {
      appVersion = '${info.version}.${info.buildNumber}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Настройки'),
      body: _build(),
    );
  }

  Widget _build() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettings(),
      ],
    );
  }

  Widget _buildSettings() {
    return ScrollConfiguration(
      behavior: NoGlowScrollBehavior(),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              _buildSection(
                title: 'Общие',
                children: [
                  _buildSettingsRow(
                    leading: const Icon(PhosphorIcons.moon, size: 24, color: AppColors.darkGrey),
                    title: 'Темный режим',
                    onTap: () {
                      showLanguageBottomSheetDialog(context);
                    },
                  ),
                  _buildDivider(context),
                  _buildSettingsRow(
                    leading: const Icon(Ionicons.language_outline, size: 24, color: AppColors.darkGrey),
                    title: 'Языковые параметры',
                    onTap: () {},
                  ),
                  _buildDivider(context),
                  _buildSettingsRow(
                    leading: SvgPicture.asset(AppVectors.watermark, width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.darkGrey, BlendMode.srcIn)),
                    title: 'Водяной знак',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(watermarkText, style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.darkGrey)),
                        const Icon(Icons.keyboard_arrow_right, size: 24, color: AppColors.darkGrey),
                      ],
                    ),
                    onTap: () {
                      showAddWatermarkDialog(context, onSave, watermarkText);
                    },
                  ),
                  _buildDivider(context),
                  _buildSettingsRow(
                    leading: Icon(Icons.notifications_none_rounded, size: 23, color: AppColors.darkGrey),
                    title: 'Уведомления',
                    trailing: const Icon(Icons.keyboard_arrow_right, size: 24, color: AppColors.darkGrey),
                    onTap: () async {
                      try {
                        final sdk = await getAndroidSdk();
                        await openNotificationSettings(sdk);
                      } catch (e) {
                        log('Error opening notification settings: $e');

                        await AndroidIntent(
                          action: 'android.settings.APP_NOTIFICATION_SETTINGS',
                          arguments: {
                            'android.provider.extra.APP_PACKAGE':
                            'com.inputstudios.notes',
                            'app_package': 'com.inputstudios.notes',
                          },
                        ).launch();
                      }
                    },
                  ),
                ],
              ),
              _buildSection(
                title: 'Безопасность',
                children: [
                  _buildSettingsRow(
                    leading: SvgPicture.asset(AppVectors.lock, width: 23, height: 23, colorFilter: const ColorFilter.mode(AppColors.darkGrey, BlendMode.srcIn)),
                    title: 'Задать пароль',
                    trailing: CustomSwitch(
                      value: true,
                      onChanged: (bool value) {

                      },
                      switchWidth: 34,
                    ),
                    onTap: () {},
                  ),
                  _buildDivider(context),
                  _buildSettingsRow(
                    leading: SvgPicture.asset(AppVectors.change, width: 23, height: 23, colorFilter: const ColorFilter.mode(AppColors.darkGrey, BlendMode.srcIn)),
                    title: 'Изменить пароль',
                    onTap: () {},
                  ),
                ],
              ),
              _buildSection(
                title: 'Другое',
                children: [
                  _buildSettingsRow(
                    leading: Icon(Icons.share_outlined, size: 23, color: AppColors.darkGrey),
                    title: 'Поделиться',
                    onTap: () {},
                  ),
                  _buildDivider(context),
                  _buildSettingsRow(
                    leading: SvgPicture.asset(AppVectors.confidential, width: 23, height: 23, colorFilter: const ColorFilter.mode(AppColors.darkGrey, BlendMode.srcIn)),
                    title: 'Политика конфиденциальности',
                    onTap: () {},
                  ),
                ],
              ),
              _buildVersionApp(

              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? AppColors.greySlate : AppColors.softGrey, borderRadius: BorderRadius.circular(18)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Text(title, style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.blueAccent, fontWeight: FontWeight.w400)),
              ),
              ...children,
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSettingsRow({required String title, Widget? leading, Widget? trailing, VoidCallback? onTap}) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
        splashColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
        highlightColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
        hoverColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              if (leading != null) ...[
                leading,
                const SizedBox(width: 14),
              ],
              Expanded(child: Text(title, style: TextStyle(fontSize: AppSizes.fontSizeMd))),
              if (trailing != null) ...[
                trailing,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionApp() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Center(
        child: Text('Версия $appVersion', style: TextStyle(color: AppColors.darkGrey, fontSize: AppSizes.fontSizeSm, fontWeight: FontWeight.w400)),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Divider(height: 0, thickness: 1, color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSlate : AppColors.buttonDisabled),
    );
  }
}
