import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/note_model.dart';
import '../models/note_view_model.dart';
import 'note_event.dart';
import 'note_state.dart';

class NoteCubit extends Bloc<NoteEvent, NoteState> {
  final NoteViewModel noteViewModel;

  NoteCubit(this.noteViewModel) : super(NoteInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<AddNote>(_onAddNote);
    on<DeleteNote>(_onDeleteNote);
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NoteState> emit) async {
    emit(NoteLoading());
    try {
      final notes = await noteViewModel.getAllNotes();
      emit(NoteLoaded(notes));
    } catch (e) {
      emit(const NoteError('Ошибка загрузки заметок'));
    }
  }

  Future<void> _onAddNote(AddNote event, Emitter<NoteState> emit) async {
    try {
      final note = NoteModel(id: 0, title: event.title, description: event.description, createdAt: DateTime.now());
      await noteViewModel.addNote(note);
      add(LoadNotes());
    } catch (e) {
      emit(const NoteError('Ошибка добавления заметки'));
    }
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<NoteState> emit) async {
    try {
      final noteToDelete = noteViewModel.allNotes.firstWhere((note) => note.id == event.noteId);
      await noteViewModel.deleteNote(noteToDelete);
      add(LoadNotes());
    } catch (e) {
      emit(const NoteError('Ошибка удаления заметки'));
    }
  }
}
