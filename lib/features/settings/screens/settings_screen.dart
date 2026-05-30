import 'dart:developer';
import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ionicons/ionicons.dart';
import 'package:notes/features/settings/controllers/language_controller.dart';
import 'package:notes/features/settings/controllers/themes_controller.dart';
import 'package:notes/features/settings/screens/privacy_policy_screen.dart';
import 'package:notes/features/utils/widgets/scrolls/no_glow_scroll_behavior.dart';
import 'package:notes/utils/platforms/platform_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/enums/week_start_type.dart';
import '../../../core/extensions/settings_category_extension.dart';
import '../../../core/extensions/week_start_extension.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../routes/custom_page_route.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/constants/app_sizes.dart';
import '../../../utils/constants/app_vectors.dart';
import '../../../utils/helpers/popup_position_helper.dart';
import '../../../utils/popups/app_popup_menu.dart';
import '../../../utils/popups/dialogs.dart';
import '../../../utils/popups/items/popup_menu_items.dart';
import '../../task/widgets/items/category_items.dart';
import '../../task/widgets/popups/select_notebook_bottom_sheet_dialog.dart';
import '../../utils/widgets/buttons/custom_switch.dart';
import '../controllers/settings_controller.dart';
import '../models/settings_model.dart';
import '../widgets/app_bars/custom_app_bar.dart';
import '../widgets/popups/add_watermark_dialog.dart';
import '../widgets/popups/language_bottom_sheet_dialog.dart';
import '../widgets/popups/theme_bottom_sheet_dialog.dart';
import 'font_size_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final GetStorage storage = GetStorage();
  final GlobalKey _manageKey = GlobalKey();
  final themesController = ThemesController.instance;
  final languagesController = LanguagesController.instance;
  final settingsController = SettingsController.instance;
  late final SettingsRepository repo;
  bool isPasswordEnabled = false;
  String watermarkText = 'Из Заметок Honor';
  String appVersion = '';

  SettingsModel? settings;

  @override
  void initState() {
    super.initState();
    watermarkText = storage.read('watermarkText') ?? 'Из Заметок Honor';
    repo = Get.find<SettingsRepository>();
    loadAppVersion();
    loadSettings();
  }

  void onSave(String newText) {
    setState(() {
      watermarkText = newText;
    });
    storage.write('watermarkText', newText);
  }

  void openThemeSelector(BuildContext context) {
    if (isWebOrWindows) {
      themesController.showThemeSelectionDialog(context);
    } else {
      showThemeBottomSheetDialog(context, themesController);
    }
  }

  void togglePassword(bool value) {
    setState(() {
      isPasswordEnabled = value;
    });
  }

  Future<void> loadSettings() async {
    settings = await repo.getSettings();
    setState(() {});
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

  Future<int?> _showWeekStartMenu(BuildContext context, RelativeRect position) async {
    return AppPopupMenu.show<int>(
      context: context,
      position: position,
      maxWidth: 210,
      items: [
        PopupMenuItems.radioItem(
          value: WeekStartType.monday.value,
          text: 'понедельник',
          groupValue: settingsController.weekStart.value,
          onChanged: (int? value) {},
          context: context,
        ),
        PopupMenuItems.divider(),
        PopupMenuItems.radioItem(
          value: WeekStartType.sunday.value,
          text: 'воскресенье',
          groupValue: settingsController.weekStart.value,
          onChanged: (int? value) {},
          context: context,
        ),
      ],
    );
  }

  Future<void> selectWeekStart() async {
    final rect = PopupPositionHelper.fromKey(_manageKey, context, dx: 5, dy: 4);
    final result = await _showWeekStartMenu(context, rect);

    if (result == null) return;

    setState(() => settingsController.weekStart.value = result);

    await settingsController.updateWeekStart(result);
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = context.isDarkMode ? AppColors.black : AppColors.white;

    return Scaffold(
      backgroundColor: baseColor,
      appBar: const CustomAppBar(title: 'Настройки'),
      body: _buildSettings(themesController, languagesController),
    );
  }

  Widget _buildSettings(ThemesController themesController, LanguagesController languagesController) {
    return ScrollConfiguration(
      behavior: NoGlowScrollBehavior(),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          _buildSection(
            title: 'Общие',
            children: [
              Obx(() {
                return _buildSettingsRow(
                  leading: Icon(themesController.getThemeIcon(), size: 24, color: AppColors.darkGrey),
                  title: themesController.getThemeDescription(),
                  onTap: () {
                    showThemeBottomSheetDialog(context, themesController);
                  },
                );
              }),
              _buildDivider(context),
              Obx(() {
                final settings = settingsController.settings.value;

                return _buildSettingsRow(
                  leading: SvgPicture.asset(AppVectors.defaultFolder, width: 23, height: 23, colorFilter: const ColorFilter.mode(AppColors.darkGrey, BlendMode.srcIn)),
                  title: 'Папка по умолчанию',
                  onTap: () async {
                    final result = await selectNotebookBottomSheetDialog(context: context, categories: CategoryItems.categories, selected: settings?.defaultCategoryItem);

                    if (result?.id case final id?) {
                      await settingsController.updateDefaultCategory(id, result!.color.toARGB32());
                    }
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildColorIndicator(settings?.defaultCategoryColor != null ? Color(settings!.defaultCategoryColor!) : AppColors.blueAccent)
                    ],
                  ),
                );
              }),
              _buildDivider(context),
              Obx(() {
                return _buildSettingsRow(
                  leading: const Icon(Ionicons.language_outline, size: 24, color: AppColors.darkGrey),
                  title: 'Языковые параметры',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(languagesController.getLanguageTitle(), style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.darkGrey)),
                      const Icon(Icons.keyboard_arrow_right_rounded, size: 24, color: AppColors.darkGrey),
                    ],
                  ),
                  onTap: () {
                    showLanguageBottomSheetDialog(
                      context,
                      (lang) async {
                        languagesController.setLanguage(lang);
                        await repo.updateLanguage(lang);
                      },
                      languagesController,
                    );
                  },
                );
              }),
              _buildDivider(context),
              _buildSettingsRow(
                leading: SvgPicture.asset(AppVectors.font, width: 23, height: 23, colorFilter: const ColorFilter.mode(AppColors.darkGrey, BlendMode.srcIn)),
                title: 'Размер шрифта',
                onTap: () {
                  Navigator.push(context, createPageRoute(FontSizeScreen()));
                },
              ),
              _buildDivider(context),
              _buildSettingsRow(
                leading: SvgPicture.asset(AppVectors.calendar, width: 23, height: 23, colorFilter: const ColorFilter.mode(AppColors.darkGrey, BlendMode.srcIn)),
                title: 'Начало недели',
                onTap: selectWeekStart,
                trailing: Builder(
                  builder: (context) {
                    return InkWell(
                      key: _manageKey,
                      splashFactory: NoSplash.splashFactory,
                      borderRadius: BorderRadius.circular(8),
                      splashColor: AppColors.transparent,
                      highlightColor: AppColors.transparent,
                      hoverColor: AppColors.transparent,
                      onTap: selectWeekStart,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Obx(() {
                              return Text(settingsController.weekStart.value == 1 ? 'понедельник' : 'воскресенье', style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.darkGrey));
                            }),
                            const Icon(Icons.keyboard_arrow_right_rounded, size: 24, color: AppColors.darkGrey),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildDivider(context),
              _buildSettingsRow(
                leading: SvgPicture.asset(AppVectors.watermark, width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.darkGrey, BlendMode.srcIn)),
                title: 'Водяной знак',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(watermarkText, style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.darkGrey)),
                    const Icon(Icons.keyboard_arrow_right_rounded, size: 24, color: AppColors.darkGrey),
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
                trailing: const Icon(Icons.keyboard_arrow_right_rounded, size: 24, color: AppColors.darkGrey),
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
                  value: isPasswordEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      isPasswordEnabled = value;
                    });
                  },
                  switchWidth: 34,
                ),
                onTap: () {
                  togglePassword(!isPasswordEnabled);
                },
              ),
              _buildDivider(context),
              _buildSettingsRow(
                leading: SvgPicture.asset(AppVectors.change, width: 23, height: 23, colorFilter: const ColorFilter.mode(AppColors.darkGrey, BlendMode.srcIn)),
                title: 'Изменить пароль',
                onTap: () {
                  final box = GetStorage();
                  final hasPassword = box.hasData('user_password');

                  if (!hasPassword) {
                    CustomIconSnackBar.showAnimatedSnackBar(context, 'Пожалуйста сначала установите пароль', icon: const Icon(Icons.warning_rounded, color: AppColors.warning), backgroundColor: AppColors.darkerGrey.withAlpha((0.15 * 255).toInt()));
                    return;
                  }
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Другое',
            children: [
              _buildSettingsRow(
                leading: Icon(Icons.share_outlined, size: 23, color: AppColors.darkGrey),
                title: 'Поделиться',
                onTap: () {
                  SharePlus.instance.share(
                    ShareParams(
                      text: '''Привет!👋 Я использую Notes, чтобы вести заметки и составлять планы на день. Этим приложением для заметок очень легко пользоваться, и в нем есть напоминания.✨ Скачать его можно отсюда: https://play.google.com/store/apps/details?id=com.inputstudios.notes''',
                    ),
                  );
                },
              ),
              _buildDivider(context),
              _buildSettingsRow(
                leading: SvgPicture.asset(AppVectors.confidential, width: 23, height: 23, colorFilter: const ColorFilter.mode(AppColors.darkGrey, BlendMode.srcIn)),
                title: 'Политика конфиденциальности',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
                },
              ),
            ],
          ),
          _buildVersionApp(),
        ],
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
          decoration: BoxDecoration(color: context.isDarkMode ? AppColors.greySlate : AppColors.softGrey, borderRadius: BorderRadius.circular(18)),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
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

  Widget buildColorIndicator(Color color) {
    return Container(
      width: 25,
      height: 25,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color.withAlpha((0.4 * 255).toInt()), width: 2)),
      child: Container(decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
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
      child: Divider(height: 0, thickness: 1, color: context.isDarkMode ? AppColors.darkSlate : AppColors.buttonDisabled),
    );
  }
}
