import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/repositories/settings_repository.dart';
import '../models/settings_model.dart';

class SettingsController extends GetxController {
  final SettingsRepository repo;

  SettingsController(this.repo);

  final box = GetStorage();
  final Rxn<SettingsModel> settings = Rxn<SettingsModel>();
  final RxInt weekStart = 1.obs;
  static SettingsController get instance => Get.find();
  static const weekStartKey = 'week_start';

  @override
  void onReady() {
    super.onReady();
    weekStart.value = box.read(weekStartKey) ?? 1;
    loadSettings();
  }

  Future<void> loadSettings() async {
    final settingsModel = await repo.getSettings();

    settings.value = settingsModel;
  }

  Future<void> updateSettings(SettingsModel updated) async {
    settings.value = updated;
    await repo.updateSettings(updated);
  }

  Future<void> updateWeekStart(int value) async {
    if (settings.value == null) return;
    weekStart.value = value;
    final updated = settings.value!.copyWith(weekStart: value);

    await updateSettings(updated);
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
  }

  Future<void> updateDefaultCategory(int category, int color) async {
    if (settings.value == null) return;

    final updated = settings.value!.copyWith(defaultCategory: category, defaultCategoryColor: color);

    settings.value = updated;

    await repo.updateCategory(category, color);
  }
}
