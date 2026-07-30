import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class AppState extends ChangeNotifier {
  final Map<String, String?> _titles = {};
  final Map<String, Color?> _colors = {};
  final Map<String, bool> _categoryColors = {};
  final box = GetStorage();

  String? getTitle(String key) => _titles[key];
  Color? getColor(String key) => _colors[key];
  Color? readColor(String key) {
    final c = box.read(key);
    if (c == null) return null;
    return Color(c);
  }

  bool isCategoryColor(String key) => _categoryColors[key] ?? false;

  void setFolder(String key, String title, Color? color, {bool isCategoryColor = false}) {
    _titles[key] = title;
    _colors[key] = isCategoryColor ? color : null;
    _categoryColors[key] = isCategoryColor;

    box.write('${key}_title', title);
    box.write('${key}_color', isCategoryColor ? color?.toARGB32() : null);
    box.write('${key}_isCategoryColor', isCategoryColor);

    notifyListeners();
  }

  void load() {
    _titles['notes'] = box.read('notes_title');
    _colors['notes'] = readColor('notes_color');
    _categoryColors['notes'] = box.read('notes_isCategoryColor') ?? false;

    _titles['tasks'] = box.read('tasks_title');
    _colors['tasks'] = readColor('tasks_color');
    _categoryColors['tasks'] = box.read('tasks_isCategoryColor') ?? false;

    notifyListeners();
  }
}
