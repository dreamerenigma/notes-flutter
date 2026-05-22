import 'dart:developer';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../../models/task_view_model.dart';
import 'calendar_dialog.dart';
import '../../models/task_model.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final TaskModel? task;
  final ValueChanged<String> onTime;
  final ValueChanged<bool> onWarning;
  final String taskType;

  const AddTaskBottomSheet({
    super.key,
    required this.task,
    required this.onTime,
    required this.onWarning,
    this.taskType = 'Add',
  });

  @override
  AddTaskBottomSheetState createState() => AddTaskBottomSheetState();
}

class AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final TaskViewModel viewModel;
  late final String currentDate;
  bool isSaveButtonEnabled = false;
  bool isWarningIconSelected = false;
  DateTime? selectedDueDate;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<TaskViewModel>(context, listen: false);
    currentDate = widget.taskType == 'Edit' ? DateFormat('dd MMMM yyyy г., HH:mm').format(DateTime.now()) : DateFormat('dd MMMM yyyy г.').format(DateTime.now());
    _textController.addListener(_handleTextInputChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTextInputChange() {
    setState(() {
      isSaveButtonEnabled = _textController.text.trim().isNotEmpty;
    });
  }

  void _requestFocus() {
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void saveText() async {
    if (isSaveButtonEnabled) {
      final taskTitle = _textController.text.trim();

      if (widget.task == null) {
        final newTask = TaskModel(title: taskTitle, description: '', createdAt: DateTime.now(), id: 0, isImportant: isWarningIconSelected, dueDate: selectedDueDate);

        try {
          await viewModel.addTask(newTask);
        } catch (e, stackTrace) {
          log(stackTrace.toString());
        }
      } else {
        final updatedTask = widget.task!.copyWith(title: taskTitle, isImportant: isWarningIconSelected);

        log('🟡 UPDATE TASK: ${updatedTask.toMap()}');

        try {
          await viewModel.updateTask(updatedTask);

          log('✅ TASK UPDATED');
        } catch (e, stackTrace) {
          log('❌ ERROR UPDATING TASK: $e');
          log(stackTrace.toString());
        }
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Material(
          color: context.isDarkMode ? AppColors.greySlate : AppColors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 14),
                child: TextSelectionTheme(
                  data: TextSelectionThemeData(cursorColor: AppColors.blue, selectionColor: AppColors.blue.withAlpha((0.3 * 255).toInt()), selectionHandleColor: AppColors.blue),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 40),
                    decoration: BoxDecoration(color: context.isDarkMode ? AppColors.greyDarker : AppColors.softGrey, borderRadius: BorderRadius.circular(25)),
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      autofocus: true,
                      style: TextStyle(fontSize: AppSizes.fontSizeLg, fontWeight: FontWeight.w300, color: context.isDarkMode ? AppColors.white : AppColors.black),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: 'Задача',
                        hintStyle: TextStyle(fontSize: AppSizes.fontSizeMd, color: AppColors.darkGrey, fontWeight: FontWeight.w400),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildBottomSheetItem(
                          context,
                          Icon(LucideIcons.alarm_clock, size: 28, color: context.isDarkMode ? AppColors.white : AppColors.black),
                          () async {
                            _requestFocus();

                            final pickedDate = await showCustomCalendarDialog(context);

                            if (pickedDate != null) {
                              setState(() {
                                selectedDueDate = pickedDate;
                              });
                              final formatted = DateFormat('d MMMM HH:mm', 'ru').format(pickedDate);
                              widget.onTime(formatted);
                              log('📅 selectedDueDate: $selectedDueDate');
                            }
                          },
                        ),
                        const SizedBox(width: 23),
                        _buildBottomSheetItem(
                          context,
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Icon(
                              BootstrapIcons.exclamation_lg,
                              size: 30,
                              color: isWarningIconSelected ? AppColors.red : context.isDarkMode ? AppColors.white : AppColors.black,
                            ),
                          ),
                              () {
                            _requestFocus();
                            setState(() {
                              isWarningIconSelected = !isWarningIconSelected;
                            });
                            widget.onWarning(isWarningIconSelected);
                          },
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: isSaveButtonEnabled ? saveText : null,
                      style: TextButton.styleFrom(
                        backgroundColor: isSaveButtonEnabled ? AppColors.blueAccent : AppColors.blueAccent.withAlpha((0.4 * 255).toInt()),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        minimumSize: const Size(0, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: Text('СОХРАНИТЬ', style: TextStyle(color: isSaveButtonEnabled ? AppColors.white : AppColors.darkGrey.withAlpha((0.7 * 255).toInt()), fontSize: AppSizes.fontSizeLm)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetItem(BuildContext context, Widget icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        _requestFocus();
        onTap();
      },
      child: icon,
    );
  }
}
