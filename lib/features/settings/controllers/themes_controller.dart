import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../generated/l10n/l10n.dart';

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

  String getThemeDescription(BuildContext context) {
    switch (selectedTheme.value) {
      case 'system':
        return S.of(context).system;
      case 'dark':
        return S.of(context).dark;
      default:
        return S.of(context).light;
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
}
