import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:notes/bindings/general_bindings.dart';
import 'package:notes/features/note/bloc/note_cubit.dart';
import 'package:notes/routes/app_routes.dart';
import 'package:notes/utils/devices/device_utility.dart';
import 'package:provider/provider.dart';
import 'package:notes/generated/l10n/l10n.dart';
import 'package:notes/utils/constants/app_colors.dart';
import 'package:notes/utils/theme/theme.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/states/app_state.dart';
import 'data/database/database_helper.dart';
import 'data/datasource/note_local_datasource.dart';
import 'data/datasource/task_local_datasource.dart';
import 'data/repositories/note_repository.dart';
import 'data/repositories/tasks_repository.dart';
import 'features/settings/controllers/language_controller.dart';
import 'features/note/models/note_view_model.dart';
import 'features/settings/controllers/themes_controller.dart';
import 'features/task/bloc/task_cubit.dart';
import 'features/task/models/task_view_model.dart';
import 'features/note/screens/note_screen.dart';

Future<void> initApp() async {
  /// -- Widget Binding
  WidgetsFlutterBinding.ensureInitialized();

  /// -- Initialize Date Formating
  initializeDateFormatting('ru_RU', null);

  /// -- GetX Local Storage
  await GetStorage.init();

  /// -- Initialize bindings here to ensure they're ready
  GeneralBindings().dependencies();

  /// -- System Ui mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);

  /// -- Set system UI status bar color globally
  DeviceUtils.setStatusBarColor(AppColors.transparent);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: AppColors.transparent, statusBarIconBrightness: Brightness.light));

  /// -- Set setting orientation to portrait only
  DeviceUtils.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguagesController languageController = Get.find<LanguagesController>();
    final ThemesController themesController = Get.find<ThemesController>();

    final dbHelper = Get.find<DatabaseHelper>();

    final noteLocalDataSource = NoteLocalDataSource(dbHelper);
    final noteRepository = NoteRepository(noteLocalDataSource);
    final noteViewModel = NoteViewModel(noteRepository);

    final taskLocalDataSource = TaskLocalDataSource(dbHelper);
    final taskRepository = TaskRepository(taskLocalDataSource);
    final taskViewModel = TaskViewModel(taskRepository);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()..load()),
        ChangeNotifierProvider.value(value: noteViewModel),
        ChangeNotifierProvider.value(value: taskViewModel),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<NoteCubit>(create: (_) => NoteCubit(noteRepository)),
          BlocProvider<TaskCubit>(create: (_) => TaskCubit(taskRepository)),
        ],
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themesController.getThemeMode(),
          theme: NotesAppTheme.getLightTheme(),
          darkTheme: NotesAppTheme.getDarkTheme(),
          getPages: AppRoutes.pages,
          locale: Locale(languageController.selectedLanguage.value),
          localizationsDelegates: const [AppLocalizationDelegate(), ...GlobalMaterialLocalizations.delegates, GlobalWidgetsLocalizations.delegate],
          supportedLocales: const [Locale('ru'), Locale('en'), Locale('es')],
          initialBinding: GeneralBindings(),
          home: const NoteScreen(),
        ),
      ),
    );
  }
}
