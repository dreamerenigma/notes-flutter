import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notes/utils/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../core/types/callbacks.dart';
import '../../../routes/custom_page_route.dart';
import '../models/note_model.dart';
import 'add_edit_note_screen.dart';
import '../models/note_view_model.dart';
import '../widgets/lists/items/note_item_grid.dart';
import '../widgets/lists/items/note_item_list.dart';

class NoteContentScreen extends StatefulWidget {
  final NoteSelectionChangedCallback onSelectionChanged;
  final String searchQuery;
  final bool isGridView;
  final Set<int> selectedNotes;

  const NoteContentScreen({
    super.key,
    required this.onSelectionChanged,
    required this.searchQuery,
    required this.selectedNotes,
    this.isGridView = false,
  });

  @override
  State<NoteContentScreen> createState() => NoteContentScreenState();
}

class NoteContentScreenState extends State<NoteContentScreen> {
  late String searchQuery;
  late List<NoteModel> filteredNotes;
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  bool selectionMode = false;
  bool showCheckboxes = false;
  bool areAllNotesSelected = false;
  List<NoteModel> notes = [];
  List<NoteModel> allNotes = [];

  @override
  void initState() {
    super.initState();
    searchQuery = '';
    searchController.addListener(() {
      final query = searchController.text;
      setState(() {
        searchQuery = query;
        log("Search query updated: $searchQuery");
      });
    });
  }

  void updateFilteredNotes(List<NoteModel> notes, String query) {
    setState(() {
      filteredNotes = notes.where((note) {
        final title = note.title.toLowerCase();
        final desc = note.description.toLowerCase();
        final q = query.toLowerCase();

        return title.contains(q) || desc.contains(q);
      }).toList();
    });
  }

  void _updateSelection(Set<int> newSelection) {
    log("🔥 UPDATE SELECTION: $newSelection");
    widget.onSelectionChanged(newSelection.isNotEmpty, allNotes.where((n) => newSelection.contains(n.id)).toList());
    log("STATE AFTER SETSTATE: $widget.selectedNotes");
  }

  void toggleSelection(int id) {
    final newSet = Set<int>.from(widget.selectedNotes);

    if (newSet.contains(id)) {
      newSet.remove(id);
    } else {
      newSet.add(id);
    }

    widget.onSelectionChanged(newSet.isNotEmpty, allNotes.where((n) => newSet.contains(n.id)).toList());
  }

  void handleLongPress(int noteId) {
    setState(() {
      showCheckboxes = true;
      widget.selectedNotes.add(noteId);
      widget.onSelectionChanged(true, allNotes.where((note) => widget.selectedNotes.contains(note.id)).toList());
    });
  }

  void clearSelection() {
    setState(() {
      widget.selectedNotes.clear();
      showCheckboxes = false;
      selectionMode = false;
      areAllNotesSelected = false;
    });

    widget.onSelectionChanged(false, []);
  }

  void _handleNoteClick(NoteModel note) {
    if (showCheckboxes) {
      final id = note.id;
      if (id == null) return;

      toggleSelection(id);
    } else {
      Navigator.push(context, createPageRoute(AddEditNoteScreen(noteType: 'Edit', noteTitle: note.title, noteDescription: note.description, noteID: note.id, createdAt: note.createdAt)));
    }
  }

  void updateNoteSelection(List<NoteModel> notes) {
    setState(() {
      for (var note in notes) {
        final index = allNotes.indexWhere((n) => n.id == note.id);
        if (index != -1) {
          allNotes[index] = note;
        }
      }
    });
  }

  void selectAll(List<NoteModel> notes) {
    _updateSelection(notes.map((e) => e.id).whereType<int>().toSet(),
    );
  }

  void deselectAllNotes() {
    setState(() {
      allNotes = allNotes.map((note) => note.copyWith(isSelected: false)).toList();

      widget.onSelectionChanged(false, []);
    });
  }

  void enterSelectionMode() {
    setState(() {
      selectionMode = true;
      showCheckboxes = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<NoteViewModel>(context);
    final allNotes = viewModel.allNotes;
    final isGrid = widget.isGridView;

    final filteredNotes = allNotes.where((note) {
      final title = note.title.toLowerCase();
      final desc = note.description.toLowerCase();
      return title.contains(searchQuery.toLowerCase()) || desc.contains(searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        Expanded(
          child: isGrid ? ScrollbarTheme(
            data: ScrollbarThemeData(
              minThumbLength: 30,
              thickness: WidgetStateProperty.all(6),
              radius: const Radius.circular(10),
              thumbColor: WidgetStatePropertyAll(AppColors.darkerGrey),
            ),
            child: Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              child: MasonryGridView.count(
                controller: scrollController,
                crossAxisCount: 2,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                itemCount: filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = filteredNotes[index];

                  return NoteItemGrid(
                    key: ValueKey(note.id),
                    note: note,
                    onDelete: () {},
                    onSelectionChanged: (isSelected) {
                      final id = note.id;
                      if (id == null) return;

                      toggleSelection(id);
                    },
                    isSelected: widget.selectedNotes.contains(note.id),
                    showCheckboxes: showCheckboxes,
                    onLongPress: () {
                      final id = note.id;
                      if (id == null) return;
                      handleLongPress(id);
                    },
                    onClick: () => _handleNoteClick(note),
                    onNoteSelected: (note) {},
                    isLeftColumn: index % 2 == 0,
                  );
                },
              ),
            ),
          ) : ScrollbarTheme(
            data: ScrollbarThemeData(
              minThumbLength: 30,
              thickness: WidgetStateProperty.all(6),
              radius: const Radius.circular(10),
              thumbColor: WidgetStatePropertyAll(AppColors.darkerGrey),
            ),
            child: Scrollbar(
              controller: scrollController,
              child: ListView.builder(
                controller: scrollController,
                itemCount: filteredNotes.length,
                padding: const EdgeInsets.only(bottom: 70),
                itemBuilder: (context, index) {
                  final note = filteredNotes[index];

                  return NoteItemList(
                    key: ValueKey(note.id),
                    note: note,
                    onDelete: () {},
                    onClick: () => _handleNoteClick(note),
                    isSelected: widget.selectedNotes.contains(note.id),
                    onSelectionChanged: (isSelected) {
                      final id = note.id;
                      if (id == null) return;

                      toggleSelection(id);
                    },
                    showCheckboxes: showCheckboxes,
                    createdAt: note.createdAt,
                    onNoteSelected: (note) {},
                    onEnterSelectionMode: enterSelectionMode,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
