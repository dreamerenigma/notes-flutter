import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:notes/features/task/widgets/popups/calendar_dialog.dart';
import '../../../../core/enums/repeat_type.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../../../../utils/constants/app_vectors.dart';
import '../../../task/models/task_model.dart';
import '../../../utils/widgets/buttons/custom_switch.dart';
import '../../../task/widgets/cards/reminder_card.dart';
import '../../../task/widgets/popups/category_popup_menu.dart';

class TaskForm extends StatefulWidget {
  final TaskModel? task;
  final TextEditingController taskTitleController;
  final TextEditingController taskDescriptionController;
  final TextEditingController noteController;
  final FocusNode taskTitleFocusNode;
  final FocusNode taskDescriptionFocusNode;
  final ValueNotifier<int> characterCountNotifier;
  final String taskType;
  final Color taskColor;
  final bool? isImportant;
  final bool? isCompleted;
  final ValueChanged<TaskModel>? onSave;
  final ValueChanged<bool> onImportantChanged;
  final ValueChanged<TaskModel> onTaskChanged;
  final ValueChanged<bool> onCompletedChanged;

  const TaskForm({super.key,
    required this.taskTitleController,
    required this.taskTitleFocusNode,
    required this.taskDescriptionController,
    required this.taskDescriptionFocusNode,
    required this.noteController,
    required this.characterCountNotifier,
    required this.onImportantChanged,
    required this.onTaskChanged,
    required this.onCompletedChanged,
    required this.taskType,
    required this.taskColor,
    this.task,
    this.isImportant,
    this.isCompleted,
    this.onSave,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final GetStorage box = GetStorage();
  final String checkKey = 'isChecked';
  final String switchKey = 'isSwitched';
  late TaskModel? taskState;
  bool isChecked = false;
  bool isSwitched = false;
  DateTime? selectedDateTime;
  Color? selectedColor;

  bool get hasReminder => selectedDateTime != null;

  bool get hasCategory => taskState?.categoryColor != null && (taskState?.category?.isNotEmpty ?? false);
  Color get effectiveColor {
    final bool hasCategorySelected = taskState?.category?.isNotEmpty ?? false;

    return Color(taskState?.categoryColor ?? AppColors.darkSlate.toARGB32(),).withAlpha(((hasCategorySelected ? 0.3 : 0.6) * 255).toInt());
  }

  String get categoryLabel => hasCategory ? taskState!.category! : 'Без категории';

  @override
  void initState() {
    super.initState();
    taskState = widget.task ?? TaskModel(id: 0, title: '', description: '', createdAt: DateTime.now(), dueDate: null);
    isSwitched = widget.isImportant ?? widget.task?.isImportant ?? false;
    isChecked = widget.task?.isCompleted ?? false;
    widget.noteController.text = widget.task?.note ?? '';
    selectedDateTime = widget.task?.dueDate;
  }

  @override
  void didUpdateWidget(covariant TaskForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newImportant = widget.isImportant ?? widget.task?.isImportant;
    final oldImportant = oldWidget.isImportant ?? oldWidget.task?.isImportant;

    if (newImportant != oldImportant) {
      isSwitched = newImportant ?? false;
    }
  }

  void toggleCheck() {
    setState(() {
      isChecked = !isChecked;
    });

    widget.onCompletedChanged(isChecked);
  }

  @override
  Widget build(BuildContext context) {
    Color iconColor = isSwitched ? AppColors.red : AppColors.darkGrey;

    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.dragged)) {
            return AppColors.darkerGrey;
          }
          return AppColors.darkerGrey;
        }),
      ),
      child: Scrollbar(
        thickness: 4,
        thumbVisibility: false,
        radius: const Radius.circular(8),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Material(
                        color: AppColors.transparent,
                        child: Ink(
                          decoration: BoxDecoration(color: effectiveColor, borderRadius: BorderRadius.circular(25)),
                          child: InkWell(
                            splashFactory: NoSplash.splashFactory,
                            borderRadius: BorderRadius.circular(25),
                            onTap: () async {
                              final RenderBox button = context.findRenderObject() as RenderBox;
                              final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                              final Offset buttonPos = button.localToGlobal(Offset.zero, ancestor: overlay);
                              final Offset anchor = buttonPos + const Offset(10, 45);
                              final Rect rect = anchor & const Size(0, 0);
                              final position = RelativeRect.fromRect(rect, Offset.zero & overlay.size);
                              final result = await CategoryPopupMenu.show(context, position, taskState?.category);

                              if (result != null) {
                                setState(() {
                                  taskState = taskState?.copyWith(category: result['text'] as String, categoryColor: (result['color'] as Color).toARGB32());
                                });

                                widget.onTaskChanged(taskState!);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12, right: 8, top: 4, bottom: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(categoryLabel, style: TextStyle(fontSize: AppSizes.fontSizeSm, color: context.isDarkMode ? AppColors.darkGrey : AppColors.black)),
                                  const SizedBox(width: 4),
                                  Icon(Icons.arrow_drop_down_outlined, size: 20, color: context.isDarkMode ? AppColors.darkGrey : AppColors.black),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: context.isDarkMode? AppColors.greySlate : AppColors.softGrey, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: toggleCheck,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(BootstrapIcons.circle, color: isChecked ? AppColors.transparent : AppColors.darkGrey, size: 23),
                            if (isChecked)
                              Container(
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(color: isChecked ? AppColors.blue : AppColors.transparent, shape: BoxShape.circle),
                                child: Center(child: isChecked ? const Icon(Icons.check, color: AppColors.white, size: 20) : null),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextSelectionTheme(
                          data: TextSelectionThemeData(cursorColor: AppColors.blue, selectionColor: AppColors.blue.withAlpha((0.3 * 255).toInt()), selectionHandleColor: AppColors.blue),
                          child: TextField(
                            controller: widget.taskTitleController,
                            focusNode: widget.taskTitleFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Задача',
                              hintStyle: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w400, color: AppColors.darkGrey),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            style: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w400, color: isChecked ? AppColors.darkGrey : AppColors.white, decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ReminderCard(
                  hasReminder: taskState?.dueDate != null,
                  selectedDateTime: taskState?.dueDate,
                  repeatType: taskState?.repeatType ?? RepeatType.none,
                  onTap: () async {
                    final result = await showCustomCalendarDialog(context);

                    if (result != null) {
                      setState(() {
                        taskState = taskState?.copyWith(dueDate: result);
                      });

                      widget.onTaskChanged(taskState!);
                    }
                  },
                  onChanged: (date) {
                    setState(() {
                      taskState = taskState?.copyWith(dueDate: date);
                    });

                    widget.onTaskChanged(taskState!);
                  },
                  onRemove: () {
                    setState(() {
                      taskState = taskState?.copyWith(dueDate: null);
                    });

                    widget.onTaskChanged(taskState!);
                  },
                  onRepeatChanged: (RepeatType value) {
                    setState(() {
                      taskState = taskState?.copyWith(repeatType: value);
                    });

                    widget.onTaskChanged(taskState!);
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
                  decoration: BoxDecoration(color: context.isDarkMode ? AppColors.greySlate : AppColors.softGrey, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(BootstrapIcons.exclamation_lg, color: iconColor, size: 34),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Text('Отметить как важное', style: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w400)),
                        ],
                      ),
                      CustomSwitch(
                        value: isSwitched,
                        onChanged: (bool value) {
                          setState(() {
                            isSwitched = value;
                          });

                          widget.onImportantChanged(value);
                        },
                        switchWidth: 40, switchHeight: 24, thumbSize: 16, thumbPadding: 5
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: context.isDarkMode? AppColors.greySlate : AppColors.softGrey, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 9),
                              child: SvgPicture.asset(AppVectors.list, colorFilter: const ColorFilter.mode(AppColors.darkGrey, BlendMode.srcIn), width: 25, height: 25),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextSelectionTheme(
                          data: TextSelectionThemeData(cursorColor: AppColors.blue, selectionColor: AppColors.blue.withAlpha((0.3 * 255).toInt()), selectionHandleColor: AppColors.blue),
                          child: TextField(
                            controller: widget.noteController,
                            focusNode: widget.taskDescriptionFocusNode,
                            onChanged: (value) {
                              taskState = taskState?.copyWith(note: value);
                              widget.onTaskChanged(taskState!);
                            },
                            decoration: InputDecoration(
                              hintText: 'Примечание',
                              hintStyle: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w400, color: AppColors.darkGrey),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            style: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
