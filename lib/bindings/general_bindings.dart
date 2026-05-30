import 'package:get/get.dart';
import 'package:notes/features/settings/controllers/settings_controller.dart';
import '../data/database/database_helper.dart';
import '../data/datasource/note_local_datasource.dart';
import '../data/datasource/task_local_datasource.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/folder_repository.dart';
import '../data/repositories/note_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/tasks_repository.dart';
import '../features/folders/models/folder_view_model.dart';
import '../features/settings/controllers/colors_controller.dart';
import '../features/settings/controllers/language_controller.dart';
import '../features/settings/controllers/themes_controller.dart';
import '../features/note/models/note_view_model.dart';
import '../features/task/models/task_view_model.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(DatabaseHelper());
    Get.put(SettingsRepository(Get.find<DatabaseHelper>()));
    Get.put(SettingsController(Get.find<SettingsRepository>()));
    Get.put(ThemesController(Get.find<SettingsRepository>()));
    Get.put(LanguagesController());
    Get.put(ColorsController());
    Get.put(NoteLocalDataSource(Get.find<DatabaseHelper>()));
    Get.put(NoteRepository(Get.find<NoteLocalDataSource>()));
    Get.put(NoteViewModel(Get.find<NoteRepository>()));
    Get.put(TaskLocalDataSource(Get.find<DatabaseHelper>()));
    Get.put(TaskRepository(Get.find<TaskLocalDataSource>()));
    Get.put(TaskViewModel(Get.find<TaskRepository>()));
    Get.put(FolderRepository(Get.find<DatabaseHelper>()));
    Get.put(CategoryRepository(Get.find<DatabaseHelper>()));
    Get.put(FolderViewModel(Get.find<FolderRepository>(), Get.find<CategoryRepository>()));
  }
}
