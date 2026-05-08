import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../../routes/custom_page_route.dart';
import '../../../../../utils/constants/app_colors.dart';
import '../../../../../utils/constants/app_sizes.dart';
import '../../../models/task_model.dart';
import '../../../models/task_view_model.dart';
import '../../../screens/add_edit_task_screen.dart';

class TaskListItem extends StatefulWidget {
  final void Function(TaskModel) onTaskSelected;
  final Function(bool) onSelectionChanged;
  final TaskModel task;
  final VoidCallback onDelete;
  final VoidCallback onClick;
  final bool isSelected;
  final bool showCheckboxes;
  final VoidCallback onLongPress;
  final DateTime? time;

  const TaskListItem({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onClick,
    required this.isSelected,
    required this.onSelectionChanged,
    required this.showCheckboxes,
    required this.onLongPress,
    required this.time,
    required this.onTaskSelected,
  });

  @override
  State<TaskListItem> createState() => _TaskListItemState();
}

class _TaskListItemState extends State<TaskListItem> {
  final GetStorage box = GetStorage();
  late String checkKey;
  bool isChecked = false;

  String formatTaskDateWithTime(DateTime? time) {
    if (time == null) return 'НЕТ ДАТЫ';

    final now = DateTime.now();
    final isToday = time.year == now.year && time.month == now.month && time.day == now.day;
    final datePart = isToday ? '' : DateFormat('dd MMMM yyyy г., ').format(time);
    final timePart = DateFormat('HH:mm').format(time);

    return '$datePart$timePart';
  }

  @override
  void initState() {
    super.initState();
    checkKey = 'task_${widget.task.id}_checked';
    isChecked = box.read(checkKey) ?? false;
  }

  void toggleCheck() {
    final newValue = !widget.task.isCompleted;

    setState(() {
      isChecked = newValue;
    });

    final updatedTask = widget.task.copyWith(isCompleted: newValue);

    Provider.of<TaskViewModel>(context, listen: false).updateTask(updatedTask);
  }

  bool get isOverdue {
    if (widget.time == null) return false;

    final now = DateTime.now();
    final taskTime = widget.time!;

    final normalizedNow = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    final normalizedTask = DateTime(taskTime.year, taskTime.month, taskTime.day, taskTime.hour, taskTime.minute);

    return normalizedTask.isBefore(normalizedNow);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = formatTaskDateWithTime(widget.time);

    return InkWell(
      onLongPress: () {
        if (widget.showCheckboxes) {
          widget.onSelectionChanged(!widget.isSelected);
        } else {
          widget.onLongPress();
        }
      },
      onTap: () {
        if (!widget.showCheckboxes) {
          Navigator.push(
            context,
            createPageRoute(AddEditTaskScreen(
              taskType: 'Edit',
              taskTitle: widget.task.title,
              taskDescription: widget.task.description,
              taskId: widget.task.id,
              time: widget.time,
            )),
          ).then((result) {
            if (result == 'saved') {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Задача обновлена')));
            }
          });
        } else {
          widget.onSelectionChanged(!widget.isSelected);
        }
      },
      customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      splashColor: Theme.of(context).brightness == Brightness.dark ? AppColors.black : AppColors.white,
      highlightColor: Theme.of(context).brightness == Brightness.dark ? AppColors.black : AppColors.white,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12).copyWith(right: widget.showCheckboxes ? 8.0 : 12.0),
        decoration: BoxDecoration(
          color: widget.isSelected ? AppColors.blueAccent.withAlpha((0.3 * 255).toInt()) : (Theme.of(context).brightness == Brightness.dark ? AppColors.greySlate : AppColors.softGrey),
          borderRadius: BorderRadius.circular(20),
          boxShadow: widget.showCheckboxes
            ? [
                BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? AppColors.black : AppColors.white, blurRadius: 4, offset: const Offset(2, 2))
              ]
            : [],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: toggleCheck,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(BootstrapIcons.circle, color: isChecked ? AppColors.transparent : AppColors.darkGrey, size: 22),
                    if (isChecked)
                      Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(color: isChecked ? AppColors.blue : AppColors.transparent, shape: BoxShape.circle),
                        child: Center(
                          child: isChecked ? const Icon(Icons.check, color: AppColors.white, size: 20) : null,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: widget.task.isImportant ? 8 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: AppSizes.fontSizeMd,
                            fontWeight: FontWeight.w400,
                            color: isChecked ? (Theme.of(context).brightness == Brightness.dark ? AppColors.darkGrey : AppColors.darkGrey) : (Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.black),
                            decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                          children: [
                            if (widget.task.isImportant)
                              WidgetSpan(
                                alignment: PlaceholderAlignment.top,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Icon(BootstrapIcons.exclamation_lg, size: 18, color: AppColors.ascentRed),
                                ),
                              ),
                            TextSpan(text: widget.task.title),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: EdgeInsets.only(left: widget.task.isImportant ? 6 : 0),
                        child: Text(
                          dateText,
                          style: TextStyle(fontSize: AppSizes.fontSizeSm, color: isOverdue ? AppColors.ascentRed : Theme.of(context).brightness == Brightness.dark ? AppColors.darkGrey : AppColors.darkGrey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          trailing: widget.showCheckboxes
            ? (widget.isSelected ? const Icon(Icons.check_box_rounded, color: AppColors.blueAccent) : const Icon(Icons.check_box_outline_blank, color: AppColors.darkGrey))
            : null,
        ),
      ),
    );
  }
}
