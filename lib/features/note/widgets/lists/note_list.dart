import 'dart:developer';
import 'package:flutter/material.dart';
import 'items/note_item_list.dart';
import 'package:notes/features/note/models/note_model.dart';

class NoteList extends StatefulWidget {
  final Function(NoteModel) onNoteSelected;
  final Function(bool) onSelectionChanged;
  final List<NoteModel> notes;
  final bool showCheckboxes;
  final Set<int> selectedNoteIds;

  const NoteList({
    super.key,
    required this.notes,
    required this.onNoteSelected,
    required this.onSelectionChanged,
    required this.showCheckboxes,
    required this.selectedNoteIds,
  });

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  void toggleSelection(int id) {
    setState(() {
      if (widget.selectedNoteIds.contains(id)) {
        widget.selectedNoteIds.remove(id);
      } else {
        widget.selectedNoteIds.add(id);
      }
    });
  }

  void enterSelectionMode(int id) {
    widget.onSelectionChanged(true);
    toggleSelection(id);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.notes.length,
      itemBuilder: (context, index) {
        final note = widget.notes[index];


        log("SELECTED: ${widget.selectedNoteIds}");
        log("SHOW CHECKBOXES: ${widget.showCheckboxes}");

        return NoteItemList(
          note: note,
          onDelete: () {},
          onClick: () {},
          isSelected: widget.selectedNoteIds.contains(note.id),
          onSelectionChanged: toggleSelection,
          showCheckboxes: widget.showCheckboxes,
          createdAt: note.createdAt,
          onNoteSelected: (selectedNote) {
            widget.onNoteSelected(selectedNote);
          },
          onEnterSelectionMode: () {
            enterSelectionMode(note.id);
          },
        );
      },
    );
  }
}
