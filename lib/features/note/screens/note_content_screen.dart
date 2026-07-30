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
  bool areAllNotesSelected = false;
  bool get showCheckboxes => widget.selectedNotes.isNotEmpty;
  List<NoteModel> notes = [];

  @override
  void initState() {
    super.initState();
    searchQuery = '';
    searchController.addListener(() {
      final query = searchController.text;
      setState(() {
        searchQuery = query;
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
    final viewModel = Provider.of<NoteViewModel>(context, listen: false);
    final selected = viewModel.allNotes.where((n) => newSelection.contains(n.id)).toList();

    widget.onSelectionChanged(newSelection.isNotEmpty, selected);
  }

  void toggleSelection(int id) {
    final newSet = Set<int>.from(widget.selectedNotes);

    if (newSet.contains(id)) {
      newSet.remove(id);
    } else {
      newSet.add(id);
    }

    _updateSelection(newSet);
  }

  void clearSelection() {
    setState(() {
      widget.selectedNotes.clear();
      areAllNotesSelected = false;
    });

    widget.onSelectionChanged(false, []);
  }

  void _handleNoteClick(NoteModel note) {
    if (showCheckboxes) {
      final id = note.id;

      toggleSelection(id);
    } else {
      Navigator.push(context, createPageRoute(AddEditNoteScreen(noteType: 'Edit', note: note)));
    }
  }

  void updateNoteSelection(List<NoteModel> notes) {
    setState(() {
      for (var note in notes) {
        final index = notes.indexWhere((n) => n.id == note.id);
        if (index != -1) {
          notes[index] = note;
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
      widget.selectedNotes.clear();
      areAllNotesSelected = false;
    });

    widget.onSelectionChanged(false, []);
  }

  void handleLongPress(int id) {
    toggleSelection(id);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<NoteViewModel>(context);
    final notes = viewModel.filteredNotes;
    final isGrid = widget.isGridView;

    final filteredNotes = notes.where((note) {
      final title = note.title.toLowerCase();
      final desc = note.description.toLowerCase();
      final q = searchQuery.toLowerCase();

      return title.contains(q) || desc.contains(q);
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
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

                        toggleSelection(id);
                      },
                      isSelected: widget.selectedNotes.contains(note.id),
                      showCheckboxes: showCheckboxes,
                      onLongPress: () {
                        final id = note.id;

                        toggleSelection(id);
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

                        toggleSelection(id);
                      },
                      showCheckboxes: showCheckboxes,
                      createdAt: note.createdAt,
                      onNoteSelected: (note) {},
                      onLongPress: () {
                        final id = note.id;

                        handleLongPress(id);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
