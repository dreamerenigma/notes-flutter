import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../generated/l10n/l10n.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/constants/app_sizes.dart';
import '../../note/widgets/tiles/custom_radio_list_tile.dart';

class ThemesController extends GetxController {
  final SettingsRepository repo;

  ThemesController(this.repo);

  static ThemesController get instance => Get.find();
  var selectedTheme = 'system'.obs;
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    selectedTheme.value = box.read('selectedTheme') ?? 'system';
    applyTheme(selectedTheme.value);
  }

  ThemeMode getThemeMode() {
    switch (selectedTheme.value) {
      case 'system':
        return ThemeMode.system;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }

  Future<void> setTheme(String theme) async {
    selectedTheme.value = theme;
    box.write('selectedTheme', theme);
    applyTheme(theme);
    await repo.updateTheme(theme);
  }

  void applyTheme(String theme) {
    if (theme == 'light') {
      Get.changeThemeMode(ThemeMode.light);
    } else if (theme == 'dark') {
      Get.changeThemeMode(ThemeMode.dark);
    } else {
      Get.changeThemeMode(ThemeMode.system);
    }
  }

  String getThemeDescription() {
    switch (selectedTheme.value) {
      case 'system':
        return 'Системная';
      case 'dark':
        return 'Темная';
      default:
        return 'Светлая';
    }
  }

  IconData getThemeIcon() {
    switch (selectedTheme.value) {
      case 'system':
        return Icons.settings_outlined;
      case 'dark':
        return Icons.dark_mode_outlined;
      default:
        return Icons.light_mode_outlined;
    }
  }

  Future<void> showThemeSelectionDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: context.isDarkMode ? AppColors.blackGrey : AppColors.white,
            title: Text(S.of(context).selectTheme),
            contentPadding: EdgeInsets.zero,
            titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            actionsPadding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomRadioListTile(
                  icon: Icons.settings,
                  title: Text(S.of(context).system),
                  value: 'system',
                  groupValue: selectedTheme.value,
                  onChanged: (value) {
                    setState(() {
                      selectedTheme.value = value as String;
                    });
                  },
                  iconColor: context.isDarkMode ? AppColors.white : AppColors.black,
                ),
                CustomRadioListTile(
                  icon: Icons.brightness_6,
                  title: Text(S.of(context).light),
                  value: 'light',
                  groupValue: selectedTheme.value,
                  onChanged: (value) {
                    setState(() {
                      selectedTheme.value = value as String;
                    });
                  },
                  iconColor: context.isDarkMode ? AppColors.white : AppColors.black,
                ),
                CustomRadioListTile(
                  icon: Icons.brightness_2,
                  title: Text(S.of(context).dark),
                  value: 'dark',
                  groupValue: selectedTheme.value,
                  onChanged: (value) {
                    setState(() {
                      selectedTheme.value = value as String;
                    });
                  },
                  iconColor: context.isDarkMode ? AppColors.white : AppColors.black,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.lightBlue, backgroundColor: AppColors.lightBlue.withAlpha((0.1 * 255).toInt()), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: Text(S.of(context).cancel, style: TextStyle(color: AppColors.lightBlue, fontSize: AppSizes.fontSizeSm)),
              ),
              TextButton(
                onPressed: () {
                  setTheme(selectedTheme.value);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.lightBlue, backgroundColor: AppColors.lightBlue.withAlpha((0.1 * 255).toInt()), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: Text(S.of(context).ok, style: TextStyle(color: AppColors.lightBlue, fontSize: AppSizes.fontSizeSm)),
              ),
            ],
          ),
        );
      },
    );
  }
}
