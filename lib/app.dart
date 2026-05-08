import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:notes/bindings/general_bindings.dart';
import 'package:notes/features/note/bloc/note_cubit.dart';
import 'package:notes/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:notes/generated/l10n/l10n.dart';
import 'package:notes/utils/constants/app_colors.dart';
import 'package:notes/utils/theme/theme.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/note/controllers/language_controller.dart';
import 'features/note/controllers/themes_controller.dart';
import 'features/note/models/note_view_model.dart';
import 'features/task/bloc/task_cubit.dart';
import 'features/task/models/task_view_model.dart';
import 'features/note/screens/note_screen.dart';

Future<void> initApp() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: AppColors.transparent, statusBarIconBrightness: Brightness.light));

  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('ru_RU', null);

  await GetStorage.init();

  GeneralBindings().dependencies();
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageController languageController = Get.find<LanguageController>();
    final ThemesController themesController = Get.find<ThemesController>();
    final noteViewModel = NoteViewModel();
    final taskViewModel = TaskViewModel();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: noteViewModel),
        ChangeNotifierProvider.value(value: taskViewModel),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<NoteCubit>(create: (_) => NoteCubit(noteViewModel)),
          BlocProvider<TaskCubit>(create: (_) => TaskCubit(taskViewModel)),
        ],
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themesController.getThemeMode(),
          theme: NotesAppTheme.getLightTheme(),
          darkTheme: NotesAppTheme.getDarkTheme(),
          getPages: AppRoutes.pages,
          locale: Locale(languageController.selectedLanguage.value),
          localizationsDelegates: const [
            AppLocalizationDelegate(),
            ...GlobalMaterialLocalizations.delegates,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ru'),
          ],
          home: const NoteScreen(),
        ),
      ),
    );
  }
}
