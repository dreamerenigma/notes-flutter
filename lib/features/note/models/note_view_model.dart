import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:notes/features/note/models/note_model.dart';
import '../../../database/database_helper.dart';

class NoteViewModel extends ChangeNotifier {
  Set<int> _selectedNotes = {};
  Set<int> get selectedNotes => _selectedNotes;
  List<NoteModel> _allNotes = [];
  List<NoteModel> get allNotes => _allNotes;
  int get noteCount => _allNotes.length;
  bool get hasSelectedItems => _selectedNotes.isNotEmpty;

  NoteViewModel() {
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    _allNotes = await fetchAllNotes();
    notifyListeners();
  }

  Future<List<NoteModel>> getAllNotes() async {
    return await fetchAllNotes();
  }

  Future<void> addNote(NoteModel note) async {
    await DatabaseHelper().insertNote(note.toMap(includeId: false));
    await _loadNotes();
  }

  Future<void> updateNote(NoteModel note) async {
    await DatabaseHelper().updateNote(note);
    log('Note updated: ${note.title}');
    await _loadNotes();
  }

  Future<void> deleteNote(NoteModel note) async {
    log('Attempting to delete note: ${note.id}');
    await DatabaseHelper().deleteNote(note.id);
    log('Note deleted: ${note.id}');
    await _loadNotes();
  }

  Future<List<NoteModel>> fetchAllNotes() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('notes');

    return List.generate(maps.length, (i) {
      return NoteModel.fromMap(maps[i]);
    });
  }

  Future<void> toggleSelection(NoteModel note) async {
    if (_selectedNotes.contains(note.id)) {
      _selectedNotes.remove(note.id);
    } else {
      _selectedNotes.add(note.id);
    }
    notifyListeners();
  }

  Future<void> toggleSelectAll() async {
    if (_selectedNotes.length == _allNotes.length) {
      _selectedNotes.clear();
    } else {
      _selectedNotes = _allNotes.map((e) => e.id).toSet();
    }
    notifyListeners();
  }

  Future<void> clearSelection() async {
    _selectedNotes.clear();
    notifyListeners();
  }
}
