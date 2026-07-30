import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:notes/features/note/models/note_model.dart';
import '../../../data/database/database_helper.dart';
import '../../../data/repositories/note_repository.dart';

class NoteViewModel extends ChangeNotifier {
  final NoteRepository repository;

  String selectedCategory = 'Все заметки';

  NoteViewModel(this.repository) {
    _loadNotes();
  }

  final GetStorage storage = GetStorage();
  final Map<String, bool> _expandedGroups = {};
  Set<int> _selectedNotes = {};
  Set<int> get selectedNotes => _selectedNotes;
  Map<String, bool> get expandedGroups => _expandedGroups;
  List<NoteModel> _allNotes = [];
  List<NoteModel> get allNotes => _allNotes;
  int get noteCount => _allNotes.length;
  bool get hasSelectedItems => _selectedNotes.isNotEmpty;

  Future<void> _loadNotes() async {
    _allNotes = await fetchAllNotes();
    _initExpandedGroups();
    notifyListeners();
  }

  Future<List<NoteModel>> getAllNotes() async {
    return await fetchAllNotes();
  }

  Future<NoteModel> addNote(NoteModel note) async {
    final id = await repository.addNote(note);
    final savedNote = note.copyWith(id: id);

    await _loadNotes();

    return savedNote;
  }

  Future<void> updateNote(NoteModel note) async {
    await repository.updateNote(note);
    await _loadNotes();
  }

  Future<void> deleteNote(NoteModel note) async {
    final id = note.id;

    await repository.deleteNote(id);
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
    final id = note.id;

    if (_selectedNotes.contains(id)) {
      _selectedNotes.remove(id);
    } else {
      _selectedNotes.add(id);
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

  void setCategoryFilter(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  List<NoteModel> get filteredNotes {
    switch (selectedCategory) {
      case 'Все заметки':
        return allNotes.where((note) => !note.isDeleted).toList();
      case 'Избранное':
        return allNotes.where((note) => note.isFavorite && !note.isDeleted).toList();
      case 'Без категории':
        return allNotes.where((note) => (note.category == null || note.category!.isEmpty) && !note.isDeleted).toList();
      case 'Недавно удаленное':
        return allNotes.where((note) => note.isDeleted).toList();
      default:
        return allNotes.where((note) => note.category == selectedCategory && !note.isDeleted).toList();
    }
  }
}
