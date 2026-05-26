import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class AppState extends ChangeNotifier {
  final Map<String, String?> _titles = {};
  final Map<String, Color?> _colors = {};
  final box = GetStorage();

  String? getTitle(String key) => _titles[key];
  Color? getColor(String key) => _colors[key];
  Color? readColor(String key) {
    final c = box.read(key);
    if (c == null) return null;
    return Color(c);
  }

  void setFolder(String key, String title, Color color) {
    _titles[key] = title;
    _colors[key] = color;

    box.write('${key}_title', title);
    box.write('${key}_color', color.toARGB32());

    notifyListeners();
  }

  void load() {
    _titles['notes'] = box.read('notes_title');
    _colors['notes'] = readColor('notes_color');

    _titles['tasks'] = box.read('tasks_title');
    _colors['tasks'] = readColor('tasks_color');

    notifyListeners();
  }
}
