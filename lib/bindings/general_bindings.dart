import 'package:get/get.dart';
import '../database/database_helper.dart';
import '../features/note/controllers/colors_controller.dart';
import '../features/note/controllers/language_controller.dart';
import '../features/note/controllers/themes_controller.dart';
import '../features/note/models/note_view_model.dart';
import '../features/task/models/task_view_model.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<DatabaseHelper>(DatabaseHelper());
    Get.put<NoteViewModel>(NoteViewModel());
    Get.put<TaskViewModel>(TaskViewModel());
    Get.put<LanguageController>(LanguageController());
    Get.put<ThemesController>(ThemesController());
    Get.put<ColorsController>(ColorsController());
  }
}
