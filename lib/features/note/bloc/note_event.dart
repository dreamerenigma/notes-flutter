import 'package:equatable/equatable.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object> get props => [];
}

class LoadNotes extends NoteEvent {}

class AddNote extends NoteEvent {
  final String title;
  final String description;
  final String? imagePath;

  const AddNote({
    required this.title,
    required this.description,
    this.imagePath,
  });

  @override
  List<Object> get props => [title, description];
}

class DeleteNote extends NoteEvent {
  final int noteId;

  const DeleteNote(this.noteId);

  @override
  List<Object> get props => [noteId];
}
