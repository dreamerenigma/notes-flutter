import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:get_storage/get_storage.dart';
import 'package:notes/utils/constants/app_sizes.dart';
import 'package:notes/features/utils/widgets/scrolls/no_glow_scroll_behavior.dart';
import 'package:provider/provider.dart';
import '../../../core/enums/folder_dialog_type.dart';
import '../../../core/states/app_state.dart';
import '../../../core/types/callbacks.dart';
import '../../../routes/custom_page_route.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/constants/app_vectors.dart';
import '../../../utils/extensions/color_extension.dart';
import '../../../utils/popups/dialogs.dart';
import '../../note/widgets/app_bars/note_app_bar.dart';
import '../../folders/widgets/popups/custom_folder_dialog.dart';
import '../utils/task_utils.dart';
import '../models/task_model.dart';
import '../widgets/groups/task_group_header.dart';
import '../widgets/items/category_items.dart';
import '../widgets/popups/select_notebook_bottom_sheet_dialog.dart';
import '../widgets/popups/tasks_popup_menu.dart';
import 'add_edit_task_screen.dart';
import '../../edit/widgets/popups/delete_dialog.dart';
import '../../note/screens/note_screen.dart';
import '../../note/widgets/nav_bar/bottom_nav_bar.dart';
import '../../note/widgets/nav_bar/select_bottom_nav_bar.dart';
import '../models/task_view_model.dart';
import '../widgets/lists/items/task_list_item.dart';
import '../widgets/popups/add_task_bottom_sheet_dialog.dart';
import '../../../core/enums/screen_type.dart';

class TaskScreen extends StatefulWidget {
  final TaskSelectionChangedCallback? onSelectionChanged;
  final ValueChanged<bool>? onFolderDialogChanged;
  final bool isFolderDialogOpen;

  const TaskScreen({super.key, this.onSelectionChanged, this.onFolderDialogChanged, this.isFolderDialogOpen = false});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with SingleTickerProviderStateMixin {
  final GetStorage box = GetStorage();
  late final AnimationController animationController;
  late Animation<double> rotationAnimation;
  List<TaskModel> selectedTasks = [];
  List<TaskModel> allTasks = [];
  Set<String> expandedGroups = {};
  Set<int> selectedNotes = {};
  Set<int> allNotes = {};
  int selectedIndex = 1;
  int selectedTaskCount = 0;
  bool isExpanded = false;
  bool showCompleted = true;
  bool selectionMode = false;
  bool groupsInitialized = false;
  bool areAllTasksSelected = false;
  bool isWarningIconSelected = false;
  bool userHasInteractedWithGroups = false;

  String? selectedFolderTitle;
  Color? selectedFolderColor;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    rotationAnimation = Tween<double>(begin: 0.0, end: 1).animate(CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn, reverseCurve: Curves.fastOutSlowIn));
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final viewModel = Provider.of<TaskViewModel>(context);
    final grouped = TaskUtils.groupTasks(viewModel.allTasks, showCompleted);
    initExpandedGroups(grouped);
  }

  Future<void> toggleExpand() async {
    if (!isExpanded) {
      setState(() {
        isExpanded = true;
      });

      animationController.forward();
      widget.onFolderDialogChanged?.call(true);

      final color = context.read<AppState>().getColor('tasks');
      final result = await showDialog<Map<String, dynamic>>(context: context, barrierColor: AppColors.transparent, builder: (_) => CustomFolderDialog(type: FolderDialogType.tasks, backgroundColor: (color ?? AppColors.black).getBackgroundColor()));

      if (!mounted) return;

      if (result != null) {
        final title = result['text'] as String?;
        final color = result['color'];

        context.read<AppState>().setFolder('tasks', title ?? 'Все задачи', color ?? AppColors.transparent);
      }

      if (result != null) {
        setState(() {});
      }

      setState(() {
        isExpanded = false;
      });

      widget.onFolderDialogChanged?.call(false);
      animationController.reverse();
    } else {
      setState(() {
        isExpanded = false;
      });
      widget.onFolderDialogChanged?.call(false);
      animationController.reverse();
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
    });
  }

  void toggleGroup(String groupTitle) {
    setState(() {
      userHasInteractedWithGroups = true;
      groupsInitialized = true;

      if (expandedGroups.contains(groupTitle)) {
        expandedGroups.remove(groupTitle);
      } else {
        expandedGroups.add(groupTitle);
      }
    });
  }

  void initExpandedGroups(Map<String, List<TaskModel>> groupedTasks) {
    for (final key in groupedTasks.keys) {
      expandedGroups.add(key);
    }
  }

  void handleLongPress(TaskModel task) {
    setState(() {
      selectionMode = true;

      if (!selectedTasks.contains(task)) {
        selectedTasks.add(task);
      }
    });
  }

  void clearSelection() {
    setState(() {
      selectionMode = false;
      selectedTasks.clear();
      widget.onSelectionChanged?.call(false, []);
    });
  }

  void handleTaskClick(TaskModel task) {
    if (selectionMode) {
      toggleSelection(task);
    } else {
      Navigator.push(context, createPageRoute(AddEditTaskScreen(taskType: 'Edit', task: task, taskTitle: task.title, taskDescription: task.description, taskId: task.id, time: task.createdAt)));
    }
  }

  void selectAllTasks(List<TaskModel> allTasks) {
    setState(() {
      final allSelected = selectedTasks.length == allTasks.length;

      if (allSelected) {
        selectedTasks.clear();
      } else {
        selectedTasks = List.from(allTasks);
      }

      areAllTasksSelected = selectedTasks.length == allTasks.length;
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
      showDragHandle: false,
      backgroundColor: context.isDarkMode ? AppColors.greySlate : AppColors.white,
      builder: (BuildContext context) {
        return AddTaskBottomSheet(
          onTime: (value) {},
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
      selectedTasks = [];
      selectedTaskCount = 0;
    });
  }

  void moveTasks(BuildContext context, List<TaskModel> tasks) async {
    final viewModel = Provider.of<TaskViewModel>(context, listen: false);
    final sameCategory = tasks.every((t) => t.category == tasks.first.category,);
    final selected = sameCategory ? CategoryItems.categories.firstWhere((c) => c.title == tasks.first.category, orElse: () => CategoryItems.categories.last) : null;
    final category = await selectNotebookBottomSheetDialog(context: context, categories: CategoryItems.categories, selected: selected);

    if (category == null) return;

    final updated = tasks.map((task) {
      return task.copyWith(category: category.title, categoryColor: category.id);
    }).toList();

    await viewModel.updateTasks(updated);

    setState(() {
      selectedTasks = updated;
    });
  }

  void deleteSelectedTasks(BuildContext context, List<TaskModel> selectedTasks, TaskViewModel? taskViewModel) {
    if (selectedTasks.isNotEmpty) {
      showDeleteDialog(
        context,
        () async {
          final deletedCount = selectedTasks.length;

          for (var task in selectedTasks) {
            await taskViewModel?.deleteTask(task);
          }

          clearSelection();

          CustomIconSnackBar.showAnimatedSnackBar(context, '$deletedCount задач удалено', icon: const Icon(Icons.check_circle, color: AppColors.success), backgroundColor: AppColors.darkerGrey.withAlpha((0.3 * 255).toInt()));
        },
        selectedCount: selectedTasks.length,
        allCount: taskViewModel?.allTasks.length ?? 0,
        type: 'task',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Consumer<TaskViewModel>(
        builder: (context, viewModel, child) {
          final tasks = viewModel.allTasks;
          final groupedTasks = TaskUtils.groupTasks(tasks, showCompleted);
          final title = context.watch<AppState>().getTitle('tasks');
          final color = context.watch<AppState>().getColor('tasks');
          final baseColor = color ?? (context.isDarkMode ? AppColors.black : AppColors.softGrey).getBackgroundColor();

          return ScrollbarTheme(
            data: ScrollbarThemeData(
              thumbColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.dragged)) {
                    return context.isDarkMode ? AppColors.darkerGrey : AppColors.darkGrey;
                  }
                  return context.isDarkMode ? AppColors.darkerGrey : AppColors.darkGrey;
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
                  backgroundColor: baseColor,
                  appBar: NoteAppBar(hasSelectedTasks: selectionMode, clearTaskSelection: clearTaskSelection, popupMenu: _buildPopupMenu(), showAppBar: selectedIndex == 1),
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: selectionMode ? null : toggleExpand,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(title ?? TaskUtils.getTitleText(selectionMode: selectionMode, selectedCount: selectedTasks.length, type: ScreenType.tasks), style: const TextStyle(fontSize: 32)),
                              const SizedBox(width: 8),
                              if (!selectionMode)
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Center(
                                    child: AnimatedBuilder(
                                      animation: rotationAnimation,
                                      builder: (context, child) {
                                        return Transform.rotate(angle: rotationAnimation.value * math.pi, alignment: const Alignment(0, -0.8), child: child);
                                      },
                                      child: SvgPicture.asset(AppVectors.arrowDropDown, width: 14, height: 14, colorFilter: ColorFilter.mode(context.isDarkMode ? AppColors.white : AppColors.black, BlendMode.srcIn)),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (selectedIndex == 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: selectionMode ? const SizedBox(height: 20) : Consumer<TaskViewModel>(
                            builder: (context, vm, _) {
                              final count = vm.taskCount;

                              if (count == 0) {
                                return const SizedBox.shrink();
                              }

                              return Text(TaskUtils.getTasksText(count), style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.darkGrey));
                            },
                            child: Text(TaskUtils.getTasksText(tasks.length), style: TextStyle(color: AppColors.darkGrey, fontSize: AppSizes.fontSizeSm)),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: tasks.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(AppVectors.noTasks, width: 120, height: 120),
                                  const SizedBox(height: 8),
                                  Text('Нет задач', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: context.isDarkMode ? AppColors.darkGrey : AppColors.softGrey)),
                                ],
                              ),
                            )
                          : ScrollConfiguration(
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
                                        TaskGroupHeader(title: groupTitle, isExpanded: isExpanded, canCollapse: canCollapse, onTap: () => toggleGroup(groupTitle)),
                                        if (isExpanded) ...[
                                          ...groupItems.map((task) {
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 12),
                                              child: Slidable(
                                                key: ValueKey(task.id),
                                                startActionPane: ActionPane(motion: const ScrollMotion(), children: []),
                                                endActionPane: ActionPane(
                                                  motion: const ScrollMotion(),
                                                  children: [
                                                    CustomSlidableAction(
                                                      onPressed: (_) {},
                                                      backgroundColor: AppColors.accent,
                                                      borderRadius: BorderRadius.circular(40),
                                                      child: Container(
                                                        width: 44,
                                                        height: 44,
                                                        decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                                                        child: Center(
                                                          child: SvgPicture.asset(AppVectors.moveFolder, width: 20, height: 20, colorFilter: const ColorFilter.mode(AppColors.black, BlendMode.srcIn)),
                                                        ),
                                                      ),
                                                    ),
                                                    CustomSlidableAction(
                                                      onPressed: (_) {},
                                                      backgroundColor: AppColors.red,
                                                      borderRadius: BorderRadius.circular(40),
                                                      child: Container(
                                                        width: 44,
                                                        height: 44,
                                                        decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                                                        child: Center(
                                                          child: SvgPicture.asset(AppVectors.delete, width: 20, height: 20, colorFilter: const ColorFilter.mode(AppColors.black, BlendMode.srcIn)),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: TaskListItem(
                                                  task: task,
                                                  onDelete: () {},
                                                  onSelectionChanged: (isSelected) {
                                                    toggleSelection(task);
                                                  },
                                                  isSelected: selectedTasks.contains(task),
                                                  showCheckboxes: selectionMode,
                                                  onLongPress: () => handleLongPress(task),
                                                  onClick: () => handleTaskClick(task),
                                                  onTaskSelected: (task) {},
                                                ),
                                              ),
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
                  bottomNavigationBar: _buildBottomNavBar(context, viewModel, tasks, color),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, TaskViewModel viewModel, List<TaskModel> tasks, Color? color) {
    return selectionMode
      ? SelectBottomNavBar(
          onMove: () => moveTasks(context, selectedTasks),
          onDelete: () => deleteSelectedTasks(context, selectedTasks, viewModel),
          showShare: false,
          onSelectAll: () => selectAllTasks(tasks),
          selectedTasks: selectedTasks,
          taskViewModel: viewModel,
          areAllSelected: selectedTasks.length == allTasks.length,
        )
      : BottomNavBar(selectedIndex: selectedIndex, onItemTapped: onItemTapped, color: color);
  }

  Widget _buildPopupMenu() {
    return TasksPopupMenu(
      showCompleted: showCompleted,
      onShowCompletedChanged: (value) {
        setState(() {
          showCompleted = value;
        });
      },
      isFolderDialogOpen: widget.isFolderDialogOpen,
    );
  }
}
