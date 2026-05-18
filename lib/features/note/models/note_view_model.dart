import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:notes/features/note/models/note_model.dart';
import '../../../database/database_helper.dart';

class NoteViewModel extends ChangeNotifier {
  final GetStorage storage = GetStorage();
  final Map<String, bool> _expandedGroups = {};
  Set<int> _selectedNotes = {};
  Set<int> get selectedNotes => _selectedNotes;
  Map<String, bool> get expandedGroups => _expandedGroups;
  List<NoteModel> _allNotes = [];
  List<NoteModel> get allNotes => _allNotes;
  int get noteCount => _allNotes.length;
  bool get hasSelectedItems => _selectedNotes.isNotEmpty;

  NoteViewModel() {
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    _allNotes = await fetchAllNotes();
    _initExpandedGroups();
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

  Map<String, List<NoteModel>> groupedNotes() {
    final grouped = <String, List<NoteModel>>{};

    for (final note in _allNotes) {
      final key = DateFormat('dd MMM yyyy').format(note.createdAt);
      grouped.putIfAbsent(key, () => []).add(note);
    }

    return grouped;
  }

  void _initExpandedGroups() {
    final grouped = groupedNotes();

    for (final key in grouped.keys) {
      _expandedGroups.putIfAbsent(key, () => true);
    }
  }

  void toggleGroup(String key) {
    _expandedGroups[key] = !(_expandedGroups[key] ?? true);
    notifyListeners();
  }

  void setSortType(int value) {
    storage.write('selectedSort', value);
    notifyListeners();
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

  List<NoteModel> get sortedNotes {
    final sortType = storage.read('selectedSort') ?? 1;
    final list = List<NoteModel>.from(_allNotes);

    switch (sortType) {
      case 1:
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case 2:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return list;
  }
}
