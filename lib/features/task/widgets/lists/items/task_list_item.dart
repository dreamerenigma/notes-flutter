import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../../core/enums/repeat_type.dart';
import '../../../../../core/extensions/repeat_type_extension.dart';
import '../../../../../routes/custom_page_route.dart';
import '../../../../../utils/constants/app_colors.dart';
import '../../../../../utils/constants/app_sizes.dart';
import '../../../../../utils/constants/app_vectors.dart';
import '../../../../../utils/popups/loaders.dart';
import '../../../models/task_model.dart';
import '../../../models/task_view_model.dart';
import '../../../screens/add_edit_task_screen.dart';

class TaskListItem extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onDelete;
  final VoidCallback onClick;
  final bool isSelected;
  final bool showCheckboxes;
  final VoidCallback onLongPress;
  final void Function(TaskModel) onTaskSelected;
  final Function(bool) onSelectionChanged;

  const TaskListItem({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onClick,
    required this.isSelected,
    required this.onSelectionChanged,
    required this.showCheckboxes,
    required this.onLongPress,
    required this.onTaskSelected,
  });

  @override
  State<TaskListItem> createState() => _TaskListItemState();
}

class _TaskListItemState extends State<TaskListItem> {
  bool isPressed = false;

  String formatTaskDateWithTime(DateTime time) {
    final now = DateTime.now();
    final isToday = time.year == now.year && time.month == now.month && time.day == now.day;
    final isSameYear = time.year == now.year;
    final timePart = DateFormat('HH:mm').format(time);

    if (isToday) {
      return timePart;
    }

    if (isSameYear) {
      final datePart = DateFormat('dd MMMM').format(time);
      return '$datePart, $timePart';
    }

    final datePart = DateFormat('dd MMMM yyyy').format(time);
    return '$datePart, $timePart';
  }

  @override
  void initState() {
    super.initState();
  }

  void toggleCheck() {
    final updatedTask = widget.task.copyWith(isCompleted: !widget.task.isCompleted);

    Provider.of<TaskViewModel>(context, listen: false).updateTask(updatedTask);
  }

  bool get isOverdue {
    if (widget.task.dueDate == null) return false;

    final now = DateTime.now();
    final taskTime = widget.task.dueDate!;

    final normalizedNow = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    final normalizedTask = DateTime(taskTime.year, taskTime.month, taskTime.day, taskTime.hour, taskTime.minute);

    return normalizedTask.isBefore(normalizedNow);
  }

  @override
  Widget build(BuildContext context) {
    final hasDate = widget.task.dueDate != null;
    final dateText = hasDate ? formatTaskDateWithTime(widget.task.dueDate!) : '';

    return GestureDetector(
      onTap: () {
        if (!widget.showCheckboxes) {
          Navigator.push(
            context,
            createPageRoute(AddEditTaskScreen(taskType: 'Edit', task: widget.task, taskTitle: widget.task.title, taskDescription: widget.task.description, taskId: widget.task.id, time: widget.task.dueDate)),
          ).then((result) {
            if (result == 'saved') {
              AppLoaders.successSnackbar(message: 'Задача обновлена', duration: 4);
            }
          });
        } else {
          widget.onSelectionChanged(!widget.isSelected);
        }
      },
      onTapDown: (_) {
        setState(() {
          isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          isPressed = false;
        });
      },
      onLongPress: () {
        if (widget.showCheckboxes) {
          widget.onSelectionChanged(!widget.isSelected);
        } else {
          widget.onLongPress();
        }
      },
      onLongPressStart: (_) {
        setState(() => isPressed = true);
      },
      onLongPressEnd: (_) {
        setState(() => isPressed = false);
      },
      child: AnimatedScale(
        scale: isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16).copyWith(right: widget.showCheckboxes ? 8 : 16),
          padding: EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppColors.blueAccent.withAlpha((0.3 * 255).toInt()) : (context.isDarkMode ? AppColors.greySlate : AppColors.softGrey),
            borderRadius: BorderRadius.circular(20),
            boxShadow: widget.showCheckboxes
              ? [
                  BoxShadow(color: context.isDarkMode ? AppColors.black : AppColors.white, blurRadius: 4, offset: const Offset(2, 2))
                ]
              : [],
          ),
          child: ListTile(
            contentPadding: widget.showCheckboxes ? EdgeInsets.only(left: 4, right: 16) : EdgeInsets.symmetric(horizontal: 16),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: toggleCheck,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder: (child, animation) {
                          final offsetAnimation = Tween<Offset>(begin: const Offset(-0.4, 0), end: Offset.zero).animate(animation);

                          return FadeTransition(opacity: animation, child: SlideTransition(position: offsetAnimation, child: child));
                        },
                        child: widget.showCheckboxes
                          ? SizedBox(key: const ValueKey('hidden'), width: 0, height: 22)
                          : GestureDetector(
                              key: const ValueKey('circle'),
                              onTap: toggleCheck,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    BootstrapIcons.circle,
                                    color: widget.task.isCompleted ? AppColors.transparent : widget.task.categoryColor != null ? Color(widget.task.categoryColor!) : AppColors.darkGrey,
                                    size: 22,
                                  ),
                                  if (widget.task.isCompleted)
                                    Container(
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(color: widget.task.categoryColor != null ? Color(widget.task.categoryColor!) : AppColors.blue, shape: BoxShape.circle),
                                      child: const Icon(Icons.check, color: AppColors.white, size: 20),
                                    ),
                                ],
                              ),
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
                              color: widget.task.isCompleted ? (context.isDarkMode ? AppColors.darkGrey : AppColors.darkGrey) : (context.isDarkMode ? AppColors.white : AppColors.black),
                              decoration: widget.task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                            ),
                            children: [
                              if (widget.task.isImportant)
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.top,
                                  child: Padding(padding: const EdgeInsets.only(top: 2), child: Icon(BootstrapIcons.exclamation_lg, size: 18, color: AppColors.ascentRed)),
                                ),
                              TextSpan(text: widget.task.title),
                            ],
                          ),
                        ),
                        SizedBox(height: 4),
                        if (hasDate) ...[
                          Padding(
                            padding: EdgeInsets.only(left: widget.task.isImportant ? 6 : 0),
                            child: Row(
                              children: [
                                if (widget.task.repeatType != RepeatType.none) ...[
                                  SvgPicture.asset(AppVectors.repeat, width: 20, height: 20, colorFilter: ColorFilter.mode(isOverdue ? AppColors.ascentRed : AppColors.darkGrey, BlendMode.srcIn)),
                                  const SizedBox(width: 4),
                                ],
                                Text(dateText, style: TextStyle(fontSize: AppSizes.fontSizeSm, color: isOverdue ? AppColors.ascentRed : AppColors.darkGrey, fontWeight: FontWeight.w400)),
                                if (widget.task.repeatType != RepeatType.none) ...[
                                  const SizedBox(width: 4),
                                  Container(width: 1.5, height: 16, color: AppColors.darkGrey.withAlpha((0.8 * 255).toInt())),
                                  const SizedBox(width: 4),
                                  Text(widget.task.repeatType.label, style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.darkGrey, fontWeight: FontWeight.w400)),
                                ],
                              ],
                            ),
                          ),
                        ],
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
      ),
    );
  }
}
