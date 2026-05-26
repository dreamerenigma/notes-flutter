import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import '../../../core/enums/folder_dialog_type.dart';
import '../../../core/enums/screen_type.dart';
import '../../../core/states/app_state.dart';
import '../../../routes/custom_page_route.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/constants/app_images.dart';
import '../../../utils/constants/app_sizes.dart';
import '../../../utils/constants/app_vectors.dart';
import '../../../utils/extensions/color_extension.dart';
import '../../task/utils/task_utils.dart';
import '../../task/widgets/items/category_items.dart';
import '../../task/widgets/popups/add_task_bottom_sheet_dialog.dart';
import '../../task/widgets/popups/select_notebook_bottom_sheet_dialog.dart';
import '../../utils/widgets/buttons/app_fab.dart';
import '../../utils/widgets/scrolls/no_glow_scroll_behavior.dart';
import '../models/note_model.dart';
import '../../task/models/task_model.dart';
import '../../edit/widgets/popups/delete_dialog.dart';
import '../models/note_view_model.dart';
import '../widgets/app_bars/note_app_bar.dart';
import '../widgets/inputs/notes_search_field.dart';
import '../widgets/nav_bar/bottom_nav_bar.dart';
import '../widgets/nav_bar/select_bottom_nav_bar.dart';
import '../../folders/widgets/popups/custom_folder_dialog.dart';
import '../widgets/popups/custom_snack_bar_dialog.dart';
import '../widgets/popups/note_popup_menu.dart';
import 'add_edit_note_screen.dart';
import 'note_content_screen.dart';
import '../../task/screens/task_screen.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => NoteScreenState();
}

class NoteScreenState extends State<NoteScreen> with SingleTickerProviderStateMixin {
  final GetStorage box = GetStorage();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<NoteContentScreenState> noteContentScreenKey = GlobalKey<NoteContentScreenState>();
  final TextEditingController searchController = TextEditingController();
  late final AnimationController animationController;
  late Animation<double> rotationAnimation;
  int noteCount = 0;
  int selectedIndex = 0;
  int selectedNoteCount = 0;
  bool isAddingTask = false;
  bool isGridView = false;
  bool isExpanded = false;
  bool showAppBar = true;
  bool isFocused = false;
  bool showCheckboxes = false;
  bool isFolderDialogOpen = false;
  bool areAllNotesSelected = false;
  String searchQuery = '';
  String taskText = '';
  Set<int> selectedNotes = {};
  List<TaskModel> selectedTasks = [];
  ValueNotifier<int> noteCountNotifier = ValueNotifier(0);

  bool get selectionMode => selectedNotes.isNotEmpty || selectedTasks.isNotEmpty;

  String getNoteCountText(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'заметка';
    } else if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) {
      return 'заметки';
    } else {
      return 'заметок';
    }
  }

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
    isGridView = box.read('isGridView') ?? false;
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    rotationAnimation = Tween<double>(begin: 0.0, end: 1).animate(CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn, reverseCurve: Curves.fastOutSlowIn));
    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });
    updateNoteCount();
  }

  @override
  void dispose() {
    animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void setGridView(bool value) {
    setState(() {
      isGridView = value;
    });
  }

  Future<void> toggleExpand() async {
    if (isExpanded) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      isExpanded = true;
      isFolderDialogOpen = true;
    });

    animationController.forward();

    await WidgetsBinding.instance.endOfFrame;
    final color = context.read<AppState>().getColor('notes');

    final result = await showDialog<Map<String, dynamic>>(context: context, barrierColor: AppColors.transparent, builder: (_) => CustomFolderDialog(type: FolderDialogType.notes, backgroundColor: (color ?? AppColors.black).getBackgroundColor()));

    if (!mounted) return;

    if (result != null) {
      final title = result['text'] as String?;
      final color = result['color'];

      context.read<AppState>().setFolder('notes', title ?? 'Все заметки', color ?? AppColors.transparent);
    }

    setState(() {
      isExpanded = false;
      isFolderDialogOpen = false;
    });

    animationController.reverse();
  }

  void toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void updateNoteCount() {
    final noteContentScreenState = noteContentScreenKey.currentState;
    if (noteContentScreenState != null) {
      setState(() {
        noteCount = noteContentScreenState.allNotes.length;
      });
    }
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void clearNoteSelection() {
    noteContentScreenKey.currentState?.clearSelection();

    setState(() {
      selectedNotes.clear();
      selectedNoteCount = 0;
    });
  }

  void selectAllNotes() {
    final allNotes = context.read<NoteViewModel>().allNotes;

    setState(() {
      final isAllSelected = selectedNotes.length == allNotes.length;

      if (isAllSelected) {
        selectedNotes.clear();
        areAllNotesSelected = false;
      } else {
        showCheckboxes = true;
        selectedNotes = allNotes.map((e) => e.id).whereType<int>().toSet();
        areAllNotesSelected = true;
      }

      selectedNoteCount = selectedNotes.length;

      log("🟢 SELECT ALL:");
      log("selectedNotes: $selectedNotes");
    });
  }

  static void moveNotes(BuildContext context, List<NoteModel> notes) {
    selectNotebookBottomSheetDialog(context: context, categories: CategoryItems.categories, selected: null);
  }

  void deleteSelectedNotes(BuildContext context, List<NoteModel> selectedNotes, List<NoteModel> allNotes, NoteViewModel? noteViewModel) {
    if (selectedNotes.isNotEmpty) {
      showDeleteDialog(
        context,
            () async {
          for (var note in selectedNotes) {
            await noteViewModel?.deleteNote(note);
          }
          showCustomDialog(context, selectedNotes);
        },
        selectedCount: selectedNotes.length,
        allCount: allNotes.length,
        type: 'note',
      );
    }
  }

  void showAddTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: false,
      backgroundColor: context.isDarkMode ? AppColors.greySlate : AppColors.white,
      builder: (BuildContext context) {
        return AddTaskBottomSheet(task: null, onTime: (value) {}, onWarning: (value) {}, taskType: 'Add');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteViewModel = Provider.of<NoteViewModel>(context, listen: false);
    final allNotes = context.watch<NoteViewModel>().sortedNotes;
    final hasNotes = allNotes.isNotEmpty;
    final title = context.watch<AppState>().getTitle('notes');
    final color = context.watch<AppState>().getColor('notes');
    final baseColor = color ?? (context.isDarkMode ? AppColors.black : AppColors.softGrey).getBackgroundColor();

    return Scaffold(
      backgroundColor: baseColor,
      appBar: NoteAppBar(
        hasSelectedNotes: selectedNotes.isNotEmpty,
        isSelectionMode: selectionMode,
        noteContentScreenKey: noteContentScreenKey,
        clearNoteSelection: clearNoteSelection,
        popupMenu: _buildPopupMenu(),
        showAppBar: selectedIndex == 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedIndex == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: toggleExpand,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title ?? TaskUtils.getTitleText(selectionMode: selectionMode, selectedCount: selectedTasks.length, type: ScreenType.notes), style: const TextStyle(fontSize: 32)),
                      ],
                    ),
                    const SizedBox(width: 4),
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
          if (selectedIndex == 0 && hasNotes)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: selectionMode ? const SizedBox(height: 20) : Consumer<NoteViewModel>(
                builder: (context, vm, _) {
                  final count = vm.noteCount;

                  return Text('$count ${getNoteCountText(count)}', style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.darkGrey));
                },
              ),
            ),
          if (selectedIndex == 0 && hasNotes) const SizedBox(height: 20),
          if (selectedIndex == 0 && hasNotes)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Stack(
                children: [
                  NotesSearchField(
                    controller: searchController,
                    focusNode: _focusNode,
                    selectionMode: selectionMode,
                    isFocused: isFocused,
                    onChanged: (query) {
                      setState(() {
                        searchQuery = query;
                      });

                      final state = noteContentScreenKey.currentState;
                      state?.updateFilteredNotes(state.allNotes, query);
                    },
                    onClear: () {
                      searchController.clear();

                      setState(() {
                        searchQuery = '';
                      });

                      final state = noteContentScreenKey.currentState;
                      state?.updateFilteredNotes(state.allNotes, '');
                    },
                  ),
                  Positioned.fill(
                    child: selectionMode
                      ? const SizedBox()
                      : Material(
                          color: AppColors.transparent,
                          child: InkWell(
                            splashFactory: NoSplash.splashFactory,
                            borderRadius: BorderRadius.circular(30),
                            splashColor: AppColors.darkerGrey.withAlpha((0.2 * 255).toInt()),
                            highlightColor: AppColors.darkGrey.withAlpha((0.2 * 255).toInt()),
                            onTap: () {
                              FocusScope.of(context).requestFocus(_focusNode);
                            },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: selectedIndex == 0
              ? (allNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(AppImages.noNotes, width: 120, height: 120),
                        const SizedBox(height: 8),
                        Text('Нет заметок', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: context.isDarkMode ? AppColors.darkGrey : AppColors.softGrey)),
                      ],
                    ),
                  )
                : ScrollConfiguration(behavior: NoGlowScrollBehavior(), child: _buildPages()))
              : ScrollConfiguration(behavior: NoGlowScrollBehavior(), child: _buildPages()),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavBar(allNotes, noteViewModel, color),
    );
  }

  Widget? _buildPopupMenu() {
    if (selectedIndex != 0) return const SizedBox();

    return NotePopupMenu(
      onGridViewChanged: (isGrid) {
        setState(() => isGridView = isGrid);
        box.write('isGridView', isGrid);
      },
      isFolderDialogOpen: isFolderDialogOpen,
    );
  }

  Widget? _buildFAB() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const bottomNavHeight = 55;
    final totalBottomOffset = bottomNavHeight + bottomPadding;
    final isSelectionActive = selectionMode;

    if (isSelectionActive || isFolderDialogOpen) return null;

    if (selectedIndex == 0) {
      return Padding(
        padding: EdgeInsets.only(bottom: bottomPadding + 16),
        child: AppFAB(
          heroTag: 'note',
          onPressed: () {
            Navigator.push(context, createPageRoute(AddEditNoteScreen(createdAt: DateTime.now())));
          },
        ),
      );
    }

    if (selectedIndex == 1) {
      return Padding(
        padding: EdgeInsets.only(bottom: totalBottomOffset + 16),
        child: AppFAB(
          heroTag: 'task',
          onPressed: () {
            showAddTaskBottomSheet(context);
          },
        ),
      );
    }

    return null;
  }

  Widget _buildPages() {
    return IndexedStack(
      index: selectedIndex,
      children: [
        NoteContentScreen(
          key: noteContentScreenKey,
          searchQuery: searchQuery,
          isGridView: isGridView,
          selectedNotes: selectedNotes,
          onSelectionChanged: (hasSelected, selected) {
            setState(() {
              selectedNotes = selected.map((e) => e.id).whereType<int>().toSet();
              selectedNoteCount = selected.length;
            });
          },
        ),
        TaskScreen(
          onSelectionChanged: (hasSelected, selected) {
            setState(() {
              selectedTasks = selected;
            });
          },
          onFolderDialogChanged: (isOpen) {
            setState(() {
              isFolderDialogOpen = isOpen;
            });
          },
          isFolderDialogOpen: isFolderDialogOpen,
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(List<NoteModel> allNotes, NoteViewModel vm, Color? color) {
    if (selectedIndex != 0) {
      return const SizedBox();
    }

    if (selectionMode) {
      final selected = allNotes.where((n) => selectedNotes.contains(n.id)).toList();

      return SelectBottomNavBar(
        onShare: () {},
        onMove: () => moveNotes(context, selected),
        onDelete: () => deleteSelectedNotes(context, selected, allNotes, vm),
        onSelectAll: selectAllNotes,
        selectedNotes: selected,
        noteViewModel: vm,
        areAllSelected: selectedNotes.length == allNotes.length,
      );
    }

    return BottomNavBar(selectedIndex: selectedIndex, onItemTapped: onItemTapped, color: color);
  }
}
