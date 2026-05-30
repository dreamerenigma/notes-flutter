import 'package:sqflite/sqflite.dart';
import '../../features/folders/models/folder_model.dart';
import '../database/database_helper.dart';

class FolderRepository {
  final DatabaseHelper helper;

  FolderRepository(this.helper);

  Future<int> insertFolder(FolderModel folder) async {
    final db = await helper.database;

    return await db.insert('folders', folder.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<FolderModel>> getFolders() async {
    final db = await helper.database;
    final result = await db.query('folders', orderBy: 'position ASC');

    return result.map((e) => FolderModel.fromMap(e)).toList();
  }

  Future<void> deleteFolder(int id) async {
    final db = await helper.database;

    await db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateFolder(FolderModel folder) async {
    final db = await helper.database;

    await db.update('folders', folder.toMap(), where: 'id = ?', whereArgs: [folder.id]);
  }
}
