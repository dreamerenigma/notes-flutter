import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../routes/custom_page_route.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/constants/app_sizes.dart';
import '../../utils/widgets/no_glow_scroll_behavior.dart';
import '../models/note_model.dart';
import '../../task/models/task_model.dart';
import '../../edit/widgets/popups/delete_dialog.dart';
import '../models/note_view_model.dart';
import '../widgets/app_bar/note_app_bar.dart';
import '../widgets/buttons/note_fab.dart';
import '../widgets/inputs/notes_search_field.dart';
import '../widgets/nav_bar/bottom_nav_bar.dart';
import '../widgets/nav_bar/select_bottom_nav_bar.dart';
import '../widgets/popups/custom_folder_dialog.dart';
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
  final FocusNode _focusNode = FocusNode();
  int noteCount = 0;
  int selectedIndex = 0;
  int selectedNoteCount = 0;
  bool hasSelectedNotes = false;
  bool hasSelectedTasks = false;
  bool isAddingTask = false;
  bool isExpanded = false;
  bool showBottomNavBar = true;
  bool showButtonFab = true;
  bool showAppBar = true;
  bool isGridView = false;
  bool areAllNotesSelected = false;
  bool isFocused = false;
  bool selectionMode = false;
  bool showCheckboxes = false;
  String searchQuery = '';
  String taskText = '';
  Set<int> selectedNotes = {};
  List<TaskModel> selectedTasks = [];
  ValueNotifier<int> noteCountNotifier = ValueNotifier(0);
  final GlobalKey<NoteContentScreenState> noteContentScreenKey = GlobalKey<NoteContentScreenState>();
  final TextEditingController searchController = TextEditingController();
  late final AnimationController animationController;

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

  String get _title {
    final count = selectedNotes.length;

    if (!selectionMode) return 'Все заметки';
    if (count == 0) return 'Не выбрано';
    if (count == 1) return 'Выбран 1 элемент';

    return 'Выбрано $count элементов';
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
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
        setState(() {});
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
      updateBottomNavBarVisibility(index == 1 ? '/tasks' : '/notes');
      updateButtonFabVisibility(index == 1 ? '/tasks' : '/notes');
      updateAppBarVisibility(index == 1 ? '/tasks' : '/notes');
    });
    if (selectedIndex == 0) {
      BottomNavBar(selectedIndex: selectedIndex, onItemTapped: onItemTapped);
    } else if (selectedIndex == 1) {
      BottomNavBar(selectedIndex: selectedIndex, onItemTapped: onItemTapped);
    }
  }

  void clearNoteSelection() {
    noteContentScreenKey.currentState?.clearSelection();

    setState(() {
      selectedNotes.clear();
      selectedNoteCount = 0;
      hasSelectedNotes = false;
      selectionMode = false;
    });
  }

  void selectAllNotes() {
    final allNotes = context.read<NoteViewModel>().allNotes;

    setState(() {
      final isAllSelected = selectedNotes.length == allNotes.length;

      if (isAllSelected) {
        selectedNotes.clear();
        hasSelectedNotes = false;
        areAllNotesSelected = false;
      } else {
        showCheckboxes = true;
        selectedNotes = allNotes.map((e) => e.id).toSet();
        hasSelectedNotes = true;
        areAllNotesSelected = true;
      }

      selectedNoteCount = selectedNotes.length;

      log("🟢 SELECT ALL:");
      log("selectedNotes: $selectedNotes");
    });
  }

  void updateBottomNavBarVisibility(String routeName) {
    setState(() {
      showBottomNavBar = routeName != '/tasks';
    });
  }

  void updateButtonFabVisibility(String routeName) {
    setState(() {
      showButtonFab = routeName != '/tasks';
    });
  }

  void updateAppBarVisibility(String routeName) {
    setState(() {
      showButtonFab = routeName != '/tasks';
    });
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

  @override
  Widget build(BuildContext context) {
    final noteViewModel = Provider.of<NoteViewModel>(context, listen: false);
    final allNotes = context.watch<NoteViewModel>().allNotes;

    return Scaffold(
      appBar: NoteAppBar(
        hasSelectedNotes: hasSelectedNotes,
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
                        Text(_title, style: const TextStyle(fontSize: 32)),
                      ],
                    ),
                    const SizedBox(width: 4),
                    if (!selectionMode)
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
          if (selectedIndex == 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: selectionMode ? const SizedBox(height: 20) : Consumer<NoteViewModel>(
              builder: (context, vm, _) {
                final count = vm.noteCount;

                return Text('$count ${getNoteCountText(count)}', style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.darkGrey));
              },
            ),
          ),
          if (selectedIndex == 0) const SizedBox(height: 20),
          if (selectedIndex == 0)
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
          Expanded(child: ScrollConfiguration(behavior: NoGlowScrollBehavior(), child: _buildPages())),
        ],
      ),
      floatingActionButton: (showButtonFab && !hasSelectedNotes) ? _buildFAB() : null,
      bottomNavigationBar: _buildBottomNavBar(allNotes, noteViewModel),
    );
  }

  Widget _buildPopupMenu() {
    if (selectedIndex != 0) return const SizedBox();

    return NotePopupMenu(
      onGridViewChanged: (isGrid) {
        setState(() => isGridView = isGrid);
      },
    );
  }

  Widget? _buildFAB() {
    if (selectedIndex != 0) return null;

    return NoteFAB(
      onPressed: () {
        Navigator.push(context, createPageRoute(AddEditNoteScreen(createdAt: DateTime.now())));
      },
    );
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
              selectedNotes = selected.map((e) => e.id).toSet();
              selectedNoteCount = selected.length;
              selectionMode = true;
              hasSelectedNotes = selected.isNotEmpty;
            });
          },
        ),
        TaskScreen(
          onSelectionChanged: (hasSelected, selected) {
            setState(() {
              hasSelectedTasks = hasSelected;
              selectedTasks = selected;
            });
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(List<NoteModel> allNotes, NoteViewModel vm) {
    if (!showBottomNavBar) return const SizedBox();

    if (selectionMode) {
      final selected = allNotes.where((n) => selectedNotes.contains(n.id)).toList();

      return SelectBottomNavBar(
        onShare: () {},
        onMove: () {},
        onDelete: () => deleteSelectedNotes(context, selected, allNotes, vm),
        onSelectAll: selectAllNotes,
        selectedNotes: selected,
        noteViewModel: vm,
        areAllSelected: selectedNotes.length == allNotes.length,
      );
    }

    return BottomNavBar(selectedIndex: selectedIndex, onItemTapped: onItemTapped);
  }
}
