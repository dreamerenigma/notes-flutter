import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:notes/features/task/models/task_model.dart';
import 'package:notes/features/edit/widgets/forms/task_form.dart';
import 'package:provider/provider.dart';
import 'package:notes/utils/constants/app_colors.dart';
import '../../edit/widgets/nav_bar/custom_bottom_nav_bar.dart';
import '../models/task_view_model.dart';

class AddEditTaskScreen extends StatefulWidget {
  final String taskType;
  final String? taskTitle;
  final String? taskDescription;
  final DateTime? time;
  final int? taskId;

  const AddEditTaskScreen({
    super.key,
    this.taskType = 'Add',
    this.taskTitle,
    this.taskDescription,
    this.taskId,
    required this.time,
  });

  @override
  AddEditTaskScreenState createState() => AddEditTaskScreenState();
}

class AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final TextEditingController taskTitleController = TextEditingController();
  final TextEditingController taskDescriptionController = TextEditingController();
  final FocusNode taskTitleFocusNode = FocusNode();
  final FocusNode taskDescriptionFocusNode = FocusNode();
  final ValueNotifier<int> characterCountNotifier = ValueNotifier<int>(0);
  bool isWarningIconSelected = false;

  @override
  void initState() {
    super.initState();
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
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
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

                          if (taskTitle.isNotEmpty && taskDescription.isNotEmpty) {
                            if (widget.taskType == 'Edit') {
                              if (widget.taskId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Task ID is null')));
                                return;
                              }
                              final updatedTask = TaskModel(id: widget.taskId!, title: taskTitle, description: taskDescription, createdAt: currentDate, isImportant: isWarningIconSelected, dueDate: widget.time);
                              viewModel.updateTask(updatedTask);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Задача обновлена')));
                            } else {
                              final newTask = TaskModel(title: taskTitle, description: taskDescription, createdAt: currentDate, id: 0, dueDate: widget.time);
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
            Expanded(
              child: TaskForm(
                taskTitleController: taskTitleController,
                taskTitleFocusNode: taskTitleFocusNode,
                taskDescriptionController: taskDescriptionController,
                taskDescriptionFocusNode: taskDescriptionFocusNode,
                characterCountNotifier: characterCountNotifier,
                taskType: widget.taskType,
                taskColor: widget.taskType == 'Edit' ? AppColors.blueAccent : AppColors.red,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        onShare: () {
          log('Share clicked');
        },
        onDelete: () {
          log('Delete clicked');
        },
        showFavorites: false,
        showMore: false,
        selectedNotes: const [],
        allNotes: const [],
      ),
    );
  }
}
