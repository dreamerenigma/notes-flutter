import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:notes/features/task/widgets/popups/calendar_dialog.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../../../../utils/constants/app_vectors.dart';
import '../../../task/models/task_model.dart';
import '../../../task/widgets/buttons/custom_switch.dart';
import '../../../task/widgets/cards/reminder_card.dart';
import '../../../task/widgets/popups/category_popup_menu.dart';

class TaskForm extends StatefulWidget {
  final TaskModel? task;
  final TextEditingController taskTitleController;
  final FocusNode taskTitleFocusNode;
  final TextEditingController taskDescriptionController;
  final FocusNode taskDescriptionFocusNode;
  final ValueNotifier<int> characterCountNotifier;
  final String taskType;
  final Color taskColor;

  const TaskForm({super.key,
    required this.taskTitleController,
    required this.taskTitleFocusNode,
    required this.taskDescriptionController,
    required this.taskDescriptionFocusNode,
    required this.characterCountNotifier,
    required this.taskType,
    required this.taskColor,
    this.task
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final GetStorage box = GetStorage();
  final String checkKey = 'isChecked';
  final String switchKey = 'isSwitched';
  bool isChecked = false;
  bool isSwitched = false;
  DateTime? selectedDateTime;

  void toggleCheck() {
    setState(() {
      isChecked = box.read(checkKey) ?? false;
      isSwitched = widget.task?.isImportant ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    isSwitched = widget.task?.isImportant ?? false;
    isChecked = widget.task?.isCompleted ?? false;
  }

  @override
  Widget build(BuildContext context) {
    Color iconColor = isSwitched ? AppColors.red : AppColors.darkGrey;
    Color selectedColor = AppColors.darkSlate.withAlpha((0.6 * 255).toInt());
    String? selectedCategoryText;
    bool hasReminder = selectedDateTime != null;

    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.dragged)) {
              return AppColors.darkerGrey;
            }
            return AppColors.darkerGrey;
          },
        ),
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
                      InkWell(
                        borderRadius: BorderRadius.circular(AppSizes.spaceBtwInputFields),
                        onTap: () async {
                          final RenderBox button = context.findRenderObject() as RenderBox;
                          final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

                          final position = RelativeRect.fromRect(
                            Rect.fromPoints(button.localToGlobal(Offset.zero, ancestor: overlay), button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay)),
                            Offset.zero & overlay.size,
                          );

                          final result = await showDialog<Map<String, dynamic>>(
                            context: context,
                            barrierColor: AppColors.transparent,
                            builder: (BuildContext context) {
                              return const CategoryPopupMenu();
                            },
                          );

                          if (result != null) {
                            setState(() {
                              selectedCategoryText = result['text'] as String;
                              selectedColor = result['color'] as Color;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.only(left: 12, right: 8, top: 4, bottom: 4),
                          decoration: BoxDecoration(color: selectedColor, borderRadius: BorderRadius.circular(25)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                selectedCategoryText ?? 'Без категории',
                                style: TextStyle(fontSize: AppSizes.fontSizeSm, color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkGrey : AppColors.black),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_drop_down_outlined, size: 20, color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkGrey : AppColors.black),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? AppColors.greySlate : AppColors.softGrey, borderRadius: BorderRadius.circular(16)),
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
                  hasReminder: hasReminder,
                  selectedDateTime: selectedDateTime,
                  onTap: () async {
                    final result = await showCustomCalendarDialog(context);

                    if (result != null) {
                      setState(() {
                        selectedDateTime = result;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
                  decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? AppColors.greySlate : AppColors.softGrey, borderRadius: BorderRadius.circular(16)),
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
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? AppColors.greySlate : AppColors.softGrey, borderRadius: BorderRadius.circular(16)),
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
                            focusNode: widget.taskDescriptionFocusNode,
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
