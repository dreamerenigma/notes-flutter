import 'package:flutter/material.dart';
import 'package:notes/features/task/models/task_model.dart';
import 'package:notes/features/edit/widgets/forms/task_form.dart';
import 'package:provider/provider.dart';
import 'package:notes/utils/constants/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import '../../edit/widgets/nav_bar/custom_bottom_nav_bar.dart';
import '../models/task_view_model.dart';

class AddEditTaskScreen extends StatefulWidget {
  final String taskType;
  final TaskModel? task;
  final String? taskTitle;
  final String? taskDescription;
  final int? taskId;
  final ValueChanged<TaskModel>? onSave;
  final DateTime? time;

  const AddEditTaskScreen({
    super.key,
    this.taskType = 'Add',
    this.task,
    this.taskTitle,
    this.taskDescription,
    this.taskId,
    this.onSave,
    required this.time,
  });

  @override
  AddEditTaskScreenState createState() => AddEditTaskScreenState();
}

class AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final GlobalKey moreKey = GlobalKey();
  final TextEditingController taskTitleController = TextEditingController();
  final TextEditingController taskDescriptionController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final FocusNode taskTitleFocusNode = FocusNode();
  final FocusNode taskDescriptionFocusNode = FocusNode();
  final ValueNotifier<int> characterCountNotifier = ValueNotifier<int>(0);
  bool isWarningIconSelected = false;
  bool isSwitched = false;
  bool isCompleted = false;
  TaskModel? currentTask;

  @override
  void initState() {
    super.initState();
    currentTask = widget.task;
    isSwitched = widget.task?.isImportant ?? false;
    isCompleted = widget.task?.isCompleted ?? false;

    if (widget.taskType == 'Edit') {
      taskTitleController.text = widget.taskTitle ?? '';
      taskDescriptionController.text = widget.taskDescription ?? '';
    }

    taskTitleFocusNode.addListener(updateIconVisibility);
    taskDescriptionFocusNode.addListener(updateIconVisibility);

    taskDescriptionController.addListener(() {
      characterCountNotifier.value = taskDescriptionController.text.length;
    });
  }

  @override
  void dispose() {
    taskTitleFocusNode.dispose();
    taskDescriptionFocusNode.dispose();
    characterCountNotifier.dispose();
    super.dispose();
  }

  void updateIconVisibility() {
    setState(() {});
  }

  void _unfocusAll() {
    taskTitleFocusNode.unfocus();
    taskDescriptionFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TaskViewModel>(context, listen: false);

    return Scaffold(
      body: Container(
        color: AppColors.transparent,
        padding: const EdgeInsets.only(left: 6, right: 6, top: 40),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, size: 32),
                  onPressed: () async {
                    final updatedTask = currentTask!.copyWith(title: taskTitleController.text, description: taskDescriptionController.text, isImportant: isSwitched, isCompleted: isCompleted);

                    await viewModel.updateTask(updatedTask);
                    Navigator.pop(context);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (taskTitleFocusNode.hasFocus || taskDescriptionFocusNode.hasFocus)
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () {
                          final taskTitle = taskTitleController.text;
                          final taskDescription = taskDescriptionController.text;
                          final currentDate = DateTime.now();

                          _unfocusAll();
                          setState(() {});

                          if (taskTitle.isNotEmpty && taskDescription.isNotEmpty) {
                            if (widget.taskType == 'Edit') {
                              if (widget.taskId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Task ID is null')));
                                return;
                              }
                              final updatedTask = TaskModel(id: widget.taskId!, title: taskTitle, description: taskDescription, createdAt: currentDate, isImportant: isSwitched, dueDate: currentTask?.dueDate);

                              viewModel.updateTask(updatedTask);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Задача обновлена')));
                            } else {
                              final newTask = TaskModel(title: taskTitle, description: taskDescription, createdAt: currentDate, id: null, dueDate: currentTask?.dueDate, isImportant: isSwitched);

                              viewModel.addTask(newTask);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Задача добавлена')));
                            }
                            Navigator.popUntil(context, ModalRoute.withName('/'));
                          }
                        },
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Expanded(
              child: TaskForm(
                task: widget.task,
                isImportant: widget.task?.isImportant,
                taskTitleController: taskTitleController,
                taskTitleFocusNode: taskTitleFocusNode,
                taskDescriptionController: taskDescriptionController,
                taskDescriptionFocusNode: taskDescriptionFocusNode,
                noteController: noteController,
                characterCountNotifier: characterCountNotifier,
                taskType: widget.taskType,
                taskColor: widget.taskType == 'Edit' ? AppColors.blueAccent : AppColors.red,
                onImportantChanged: (value) {
                  isSwitched = value;
                },
                onSave: (updatedTask) {
                  viewModel.updateTask(updatedTask);
                },
                onTaskChanged: (task) {
                  currentTask = task;
                },
                onCompletedChanged: (value) {
                  isCompleted = value;
                },
                isCompleted: isCompleted,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        onShare: () {
          final task = currentTask;
          if (task == null) return;
          final textToShare = '''📝 ${task.title} ${task.description}''';

          SharePlus.instance.share(ShareParams(text: textToShare));
        },
        onDelete: () {},
        showFavorites: false,
        showMore: false,
        selectedNotes: const [],
        allNotes: const [],
        moreKey: moreKey,
        isFavorite: false,
      ),
    );
  }
}
