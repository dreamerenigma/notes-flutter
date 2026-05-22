import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:notes/routes/routes.dart';
import '../features/note/screens/note_screen.dart';
import '../features/task/screens/task_screen.dart';

class AppRoutes {
  static final pages = [
    GetPage(name: NotesRoutes.note, page: () => NoteScreen()),
    GetPage(name: NotesRoutes.task, page: () => TaskScreen()),
  ];
}
