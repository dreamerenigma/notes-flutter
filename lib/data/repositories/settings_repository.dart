import 'package:sqflite/sqflite.dart';
import '../../features/settings/models/settings_model.dart';
import '../database/database_helper.dart';

class SettingsRepository {
  final DatabaseHelper helper;

  SettingsRepository(this.helper);

  Future<Database> get _db async => await helper.database;

  Future<void> ensureSettingsExists(Database db) async {
    final res = await db.query('settings');

    if (res.isEmpty) {
      await db.insert('settings', {
        'id': 1,
        'theme': 'light',
        'language': 'ru',
        'default_category': null,
        'default_category_color': null,
        'password_enabled': 0,
        'week_start': 1,
        'watermark_text': null,
      });
    }
  }

  Future<void> updateSettings(SettingsModel settings) async {
    final db = await _db;

    await db.update('settings', settings.toMap(), where: 'id = ?', whereArgs: [settings.id]);
  }

  Future<SettingsModel?> getSettings() async {
    final db = await _db;

    await ensureSettingsExists(db);

    final result = await db.query('settings', where: 'id = ?', whereArgs: [1]);

    if (result.isEmpty) {
      return null;
    }

    final model = SettingsModel.fromMap(result.first);

    return model;
  }

  Future<void> updateLanguage(String lang) async {
    final db = await _db;

    await db.update('settings', {'language': lang}, where: 'id = ?', whereArgs: [1]);
  }

  Future<String> getLanguage() async {
    final db = await _db;
    final result = await db.query('settings', where: 'id = ?', whereArgs: [1]);

    return result.first['language'] as String? ?? 'ru';
  }

  Future<void> updateTheme(String theme) async {
    final db = await helper.database;

    await db.update('settings', {'theme': theme},where: 'id = ?', whereArgs: [1]);
  }

  Future<void> updateCategory(int category, int color) async {
    final db = await _db;

    await db.update('settings', { 'default_category': category, 'default_category_color': color }, where: 'id = ?', whereArgs: [1]);
  }
}
