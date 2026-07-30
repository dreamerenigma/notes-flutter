import '../../features/note/models/note_model.dart';
import '../datasource/note_local_datasource.dart';

class NoteRepository {
  final NoteLocalDataSource local;

  NoteRepository(this.local);

  Future<int> addNote(NoteModel note) async {
    final id = await local.insert(note.toMap());

    return id;
  }

  Future<List<NoteModel>> getNotes() async {
    final maps = await local.getAll();

    return maps.map((e) => NoteModel.fromMap(e)).toList();
  }

  Future<void> updateNote(NoteModel note) async {
    await local.update(note);
  }

  Future<void> deleteNote(int id) async {
    await local.delete(id);
  }
}
