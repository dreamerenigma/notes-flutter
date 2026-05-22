import 'package:get/get.dart';
import 'package:notes/features/settings/controllers/settings_controller.dart';
import '../database/database_helper.dart';
import '../features/settings/controllers/colors_controller.dart';
import '../features/settings/controllers/language_controller.dart';
import '../features/settings/controllers/themes_controller.dart';
import '../features/note/models/note_view_model.dart';
import '../features/task/models/task_view_model.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<DatabaseHelper>(DatabaseHelper());
    Get.put<NoteViewModel>(NoteViewModel());
    Get.put<TaskViewModel>(TaskViewModel());
    Get.put<LanguagesController>(LanguagesController());
    Get.put<ThemesController>(ThemesController());
    Get.put<ColorsController>(ColorsController());
    Get.put<SettingsController>(SettingsController());
  }
}
