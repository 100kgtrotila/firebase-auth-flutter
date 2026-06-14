import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_flutter/features/notes/models/note.dart';

class NotesService {
  NotesService({FirebaseFirestore? firestore, FirebaseAuth? firebaseAuth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  CollectionReference<Map<String, dynamic>> _notesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('notes');
  }

  User _requireUser() {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw StateError('You must be logged in to manage notes.');
    }

    return user;
  }

  Stream<List<Note>> getNotes() {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _notesCollection(
      user.uid,
    ).orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Note.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> createNote({required String title, required String content}) {
    final user = _requireUser();

    return _notesCollection(user.uid).add({
      'title': title.trim(),
      'content': content.trim(),
      'userId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNote({
    required String noteId,
    required String title,
    required String content,
  }) {
    final user = _requireUser();

    return _notesCollection(user.uid).doc(noteId).update({
      'title': title.trim(),
      'content': content.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNote(String noteId) {
    final user = _requireUser();

    return _notesCollection(user.uid).doc(noteId).delete();
  }
}
