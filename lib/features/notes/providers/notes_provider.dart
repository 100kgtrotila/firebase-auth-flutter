import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_flutter/features/notes/models/note.dart';
import 'package:firebase_auth_flutter/features/notes/services/notes_service.dart';
import 'package:flutter/material.dart';

class NotesProvider extends ChangeNotifier {
  final NotesService _notesService = NotesService();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Stream<List<Note>> get notesStream => _notesService.getNotes();

  Future<String?> createNote({required String title, required String content}) {
    return _runNotesAction(
      () => _notesService.createNote(title: title, content: content),
      'Failed to create note. Please try again.',
    );
  }

  Future<String?> updateNote({
    required String noteId,
    required String title,
    required String content,
  }) {
    return _runNotesAction(
      () => _notesService.updateNote(
        noteId: noteId,
        title: title,
        content: content,
      ),
      'Failed to update note. Please try again.',
    );
  }

  Future<String?> deleteNote(String noteId) {
    return _runNotesAction(
      () => _notesService.deleteNote(noteId),
      'Failed to delete note. Please try again.',
    );
  }

  Future<String?> _runNotesAction(
    Future<void> Function() action,
    String fallbackMessage,
  ) async {
    _setLoading(true);

    try {
      await action();
      return null;
    } on StateError {
      return 'You must be logged in to manage notes.';
    } on FirebaseException {
      return fallbackMessage;
    } catch (_) {
      return fallbackMessage;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
