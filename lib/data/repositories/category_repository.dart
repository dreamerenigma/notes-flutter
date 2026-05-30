import 'package:sqflite/sqflite.dart';
import '../../features/note/models/category_model.dart';
import '../database/database_helper.dart';

class CategoryRepository {
  final DatabaseHelper helper;

  CategoryRepository(this.helper);

  Future<int> insertCategory(CategoryModel category) async {
    final db = await helper.database;

    return await db.insert('categories', category.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CategoryModel>> getCategories() async {
    final db = await helper.database;
    final result = await db.query('categories', orderBy: 'position ASC');

    return result.map((e) => CategoryModel.fromMap(e)).toList();
  }

  Future<void> updateCategory(CategoryModel category) async {
    final db = await helper.database;

    await db.update('categories', category.toMap(), where: 'id = ?', whereArgs: [category.id]);
  }

  Future<void> deleteCategory(int id) async {
    final db = await helper.database;

    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCategoriesByFolderId(int folderId) async {
    final db = await helper.database;

    return await db.delete('categories', where: 'folder_id = ?', whereArgs: [folderId]);
  }
}
