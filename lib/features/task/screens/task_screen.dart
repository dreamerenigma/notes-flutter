import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes/utils/constants/app_sizes.dart';
import 'package:notes/features/utils/widgets/no_glow_scroll_behavior.dart';
import 'package:provider/provider.dart';
import '../../../core/types/callbacks.dart';
import '../../../routes/custom_page_route.dart';
import '../../../utils/constants/app_colors.dart';
import '../../note/widgets/popups/custom_folder_dialog.dart';
import '../models/task_model.dart';
import '../widgets/popups/tasks_popup_menu.dart';
import 'add_edit_task_screen.dart';
import '../../edit/widgets/popups/delete_dialog.dart';
import '../../note/screens/note_screen.dart';
import '../../note/widgets/app_bar/note_app_bar.dart';
import '../../note/widgets/nav_bar/bottom_nav_bar.dart';
import '../../note/widgets/nav_bar/select_bottom_nav_bar.dart';
import '../models/task_view_model.dart';
import '../widgets/buttons/task_fab.dart';
import '../widgets/lists/items/task_list_item.dart';
import '../widgets/nav_bar/add_task_bottom_sheet_dialog.dart';

class TaskScreen extends StatefulWidget {
  final TaskSelectionChangedCallback? onSelectionChanged;

  const TaskScreen({
    super.key,
    this.onSelectionChanged,
  });

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late List<TaskModel> tasks;
  List<TaskModel> selectedTasks = [];
  List<TaskModel> allTasks = [];
  Set<String> expandedGroups = {};
  Set<int> selectedNotes = {};
  Set<int> allNotes = {};
  int selectedIndex = 1;
  int selectedTaskCount = 0;
  bool isExpanded = false;
  bool showCompleted = true;
  bool showCheckboxes = false;
  bool hasSelectedTasks = false;
  bool areAllTasksSelected = false;
  bool isWarningIconSelected = false;
  bool showSelectBottomNavBar = false;

  String getElementSuffix(int count) {
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) {
      return 'а';
    } else {
      return 'ов';
    }
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void toggleExpand() async {
    if (!isExpanded) {
      setState(() {
        isExpanded = true;
        animationController.forward();
      });

      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        barrierColor: AppColors.transparent,
        builder: (BuildContext context) {
          return const CustomFolderDialog();
        },
      );

      if (result != null) {
        setState(() {
        });
      }
      setState(() {
        isExpanded = false;
        animationController.reverse();
      });
    } else {
      setState(() {
        isExpanded = false;
        animationController.reverse();
      });
      Navigator.of(context).pop();
    }
  }

  void toggleSelection(TaskModel task) {
    setState(() {
      if (selectedTasks.contains(task)) {
        selectedTasks.remove(task);
      } else {
        selectedTasks.add(task);
      }

      selectedTaskCount = selectedTasks.length;
      hasSelectedTasks = selectedTasks.isNotEmpty;

      widget.onSelectionChanged?.call(selectedTasks.isNotEmpty, selectedTasks);
    });
  }

  void handleLongPress(TaskModel task) {
    setState(() {
      showSelectBottomNavBar = true;
      showCheckboxes = true;

      if (!selectedTasks.contains(task)) {
        selectedTasks.add(task);
      }

      selectedTaskCount = selectedTasks.length;
      hasSelectedTasks = selectedTasks.isNotEmpty;
      widget.onSelectionChanged?.call(true, selectedTasks);
    });
  }

  void clearSelection() {
    setState(() {
      selectedTasks.clear();
      showCheckboxes = false;
      showSelectBottomNavBar = false;
      widget.onSelectionChanged?.call(false, []);
    });
  }

  void handleTaskClick(TaskModel task) {
    if (showCheckboxes) {
      toggleSelection(task);
    } else {
      Navigator.push(context, createPageRoute(AddEditTaskScreen(taskType: 'Edit', taskTitle: task.title, taskDescription: task.description, taskId: task.id, time: task.createdAt)));
    }
  }

  void selectAllTasks() {
    setState(() {
      if (areAllTasksSelected) {
        selectedTasks.clear();
        selectedTaskCount = 0;
        hasSelectedTasks = false;
      } else {
        selectedTasks = List.from(tasks);
        selectedTaskCount = selectedTasks.length;
        hasSelectedTasks = selectedTasks.isNotEmpty;
      }
      areAllTasksSelected = !areAllTasksSelected;
    });
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, createPageRoute(const NoteScreen()));
        break;
      default:
        break;
    }
  }

  void showAddTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return AddTaskBottomSheet(
          onTime: () {},
          onWarning: (value) {
            setState(() {
              isWarningIconSelected = value;
            });
          },
          task: null,
        );
      },
    );
  }

  void clearTaskSelection() {
    clearSelection();
    setState(() {
      hasSelectedTasks = false;
      selectedTasks = [];
      selectedTaskCount = 0;
    });
  }

  void deleteSelectedTasks(BuildContext context, List<TaskModel> selectedTasks, TaskViewModel? taskViewModel) {
    if (selectedTasks.isNotEmpty) {
      showDeleteDialog(
        context,
            () async {
          for (var task in selectedTasks) {
            await taskViewModel?.deleteTask(task);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${selectedTasks.length} задач удалено", style: const TextStyle(color: AppColors.white)),
              duration: const Duration(seconds: 2),
              backgroundColor: AppColors.darkGrey.withAlpha((0.6 * 255).toInt()),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        },
        selectedCount: selectedNotes.length,
        allCount: allNotes.length,
        type: 'task',
      );
    }
  }

  Map<String, List<TaskModel>> groupTasks(List<TaskModel> tasks, bool showCompleted) {
    final Map<String, List<TaskModel>> grouped = {};
    final now = DateTime.now();

    for (var task in tasks) {
      if (!showCompleted && task.isCompleted) {
        continue;
      }

      String key;

      if (task.isCompleted) {
        key = 'ВЫПОЛНЕНО';
      } else if (task.createdAt == null) {
        key = 'НЕТ ДАТЫ';
      } else if (task.createdAt!.isBefore(now)) {
        key = 'ИСТЁК СРОК';
      } else if (isToday(task.createdAt!)) {
        key = 'СЕГОДНЯ';
      } else {
        key = 'ДРУГОЕ';
      }

      grouped.putIfAbsent(key, () => []).add(task);
    }

    return grouped;
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    Widget popupMenu = const SizedBox();

    return Consumer<TaskViewModel>(
      builder: (context, viewModel, child) {
        tasks = viewModel.allTasks;

        final taskViewModel = Provider.of<TaskViewModel>(context, listen: false);
        final groupedTasks = groupTasks(tasks, showCompleted);

        popupMenu = TasksPopupMenu(
          showCompleted: showCompleted,
          onShowCompletedChanged: (value) {
            setState(() {
              showCompleted = value;
            });
          },
        );
        Widget bottomNavBar = showSelectBottomNavBar ? SelectBottomNavBar(
          onMove: () {},
          onDelete: () {
            deleteSelectedTasks(context, selectedTasks, taskViewModel);
          },
          showShare: false,
          onSelectAll: selectAllTasks,
          selectedTasks: selectedTasks,
          taskViewModel: viewModel,
          areAllSelected: selectedNotes.length == allTasks.length,
        )
            : BottomNavBar(selectedIndex: selectedIndex, onItemTapped: onItemTapped,
        );

        return ScrollbarTheme(
          data: ScrollbarThemeData(
            thumbColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.dragged)) {
                  return Theme.of(context).brightness == Brightness.dark ? AppColors.darkerGrey : AppColors.darkGrey;
                }
                return Theme.of(context).brightness == Brightness.dark ? AppColors.darkerGrey : AppColors.darkGrey;
              },
            ),
          ),
          child: ScrollConfiguration(
            behavior: NoGlowScrollBehavior(),
            child: Scrollbar(
              thickness: 4,
              thumbVisibility: false,
              radius: const Radius.circular(6),
              child: Scaffold(
                appBar: NoteAppBar(hasSelectedTasks: hasSelectedTasks, clearTaskSelection: clearTaskSelection, popupMenu: popupMenu, showAppBar: selectedIndex == 1),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: toggleExpand,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              !hasSelectedTasks
                                ? 'Все задачи'
                                : selectedTaskCount == 0
                                  ? 'Не выбрано'
                                  : selectedTaskCount == 1
                                    ? 'Выбран $selectedTaskCount элемент'
                                    : 'Выбрано $selectedTaskCount элемент${getElementSuffix(selectedTaskCount)}',
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 4),
                            if (!hasSelectedTasks)
                            AnimatedBuilder(
                              animation: animationController,
                              builder: (context, child) {
                                return Transform.rotate(angle: animationController.value * 3.14, child: const Icon(Icons.arrow_drop_down_rounded, size: 35));
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('${tasks.length} задачи', style: TextStyle(color: AppColors.darkGrey, fontSize: AppSizes.fontSizeSm)),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: NoGlowScrollBehavior(),
                        child: Scrollbar(
                          thickness: 4,
                          radius: const Radius.circular(6),
                          thumbVisibility: false,
                          child: ListView(
                            children: groupedTasks.entries.map((entry) {
                              final groupTitle = entry.key;
                              final groupItems = entry.value.where((task) {
                                if (showCompleted) return true;
                                return !task.isCompleted;
                              }).toList();

                              final canCollapse = groupItems.length >= 3;
                              final isExpanded = !canCollapse || expandedGroups.contains(groupTitle);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Material(
                                    color: AppColors.transparent,
                                    child: InkWell(
                                      onTap: canCollapse
                                        ? () {
                                            setState(() {
                                              if (expandedGroups.contains(groupTitle)) {
                                                expandedGroups.remove(groupTitle);
                                              } else {
                                                expandedGroups.add(groupTitle);
                                              }
                                            });
                                          }
                                        : null,
                                      splashFactory: NoSplash.splashFactory,
                                      splashColor: AppColors.transparent,
                                      highlightColor: AppColors.transparent,
                                      hoverColor: AppColors.transparent,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        child: Row(
                                          children: [
                                            Text(groupTitle, style: TextStyle(fontSize: AppSizes.fontSizeLg, color: context.isDarkMode ? AppColors.white : AppColors.black, fontWeight: FontWeight.w400)),
                                            const Spacer(),
                                            if (canCollapse)
                                              AnimatedRotation(
                                                turns: expandedGroups.contains(groupTitle) ? 0.5 : 0.0,
                                                duration: const Duration(milliseconds: 400),
                                                curve: Curves.easeInOutCubicEmphasized,
                                                child: const Icon(Icons.keyboard_arrow_down_rounded, size: 25, color: AppColors.steelGrey),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (isExpanded) ...[
                                    ...groupItems.map((task) {
                                      return TaskListItem(
                                        task: task,
                                        time: task.createdAt,
                                        onDelete: () {},
                                        onSelectionChanged: (isSelected) {
                                          toggleSelection(task);
                                        },
                                        isSelected: selectedTasks.contains(task),
                                        showCheckboxes: showCheckboxes,
                                        onLongPress: () => handleLongPress(task),
                                        onClick: () => handleTaskClick(task),
                                        onTaskSelected: (task) {},
                                      );
                                    }),
                                  ],
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                floatingActionButton: TaskFAB(onPressed: () {
                  showAddTaskBottomSheet();
                }),
                bottomNavigationBar: bottomNavBar,
              ),
            ),
          ),
        );
      },
    );
  }
}
