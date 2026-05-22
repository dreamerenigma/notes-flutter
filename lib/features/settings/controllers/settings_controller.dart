import 'dart:developer';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import '../../../database/database_helper.dart';
import '../models/settings_model.dart';

class SettingsController extends GetxController {
  final box = GetStorage();
  final Rxn<SettingsModel> settings = Rxn<SettingsModel>();
  static SettingsController get instance => Get.find();
  static const weekStartKey = 'week_start';
  int weekStart = 1;

  @override
  void onReady() {
    super.onReady();
    weekStart = box.read(weekStartKey) ?? 1;
    loadSettings();
  }

  Future<void> loadSettings() async {
    settings.value = await DatabaseHelper.instance.getSettings();
  }

  Future<void> updateSettings(SettingsModel updated) async {
    log('UPDATE SETTINGS CALLED');
    settings.value = updated;
    await DatabaseHelper.instance.updateSettings(updated);
    log('DB UPDATED');
  }

  Future<void> updateWeekStart(int value) async {
    if (settings.value == null) return;

    final updated = settings.value!.copyWith(weekStart: value);

    log('NEW WEEK START: ${updated.weekStart}');

    await updateSettings(updated);

    final fromDb = await DatabaseHelper.instance.getSettings();
    log('FROM DB: ${fromDb?.weekStart}');
  }

  Future<void> updateWatermark(String text) async {
    if (settings.value == null) return;

    final updated = settings.value!.copyWith(watermarkText: text);

    await updateSettings(updated);
  }

  Future<void> updateLanguage(String lang) async {
    if (settings.value == null) return;

    final updated = settings.value!.copyWith(language: lang);

    await updateSettings(updated);

    log('LANG UPDATED: $lang');
  }
}
