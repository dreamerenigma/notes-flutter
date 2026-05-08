import '../../features/note/models/note_model.dart';
import '../../features/task/models/task_model.dart';

typedef NoteSelectionChangedCallback = void Function(bool hasSelected, List<NoteModel> selectedNotes);
typedef TaskSelectionChangedCallback = void Function(bool hasSelected, List<TaskModel> selectedTasks);
