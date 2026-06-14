import 'package:firebase_auth_flutter/core/utils/auth_error_mapper.dart';
import 'package:firebase_auth_flutter/core/utils/validators.dart';
import 'package:firebase_auth_flutter/features/notes/models/note.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    test('validates email', () {
      expect(Validators.validateEmail('student@example.com'), isNull);
      expect(Validators.validateEmail('student'), isNotNull);
    });

    test('validates matching passwords', () {
      expect(Validators.validateConfirmPassword('123456', '123456'), isNull);
      expect(Validators.validateConfirmPassword('123456', '654321'), isNotNull);
    });

    test('validates note fields', () {
      expect(Validators.validateNoteTitle('Lab note'), isNull);
      expect(Validators.validateNoteTitle('A'), isNotNull);
      expect(Validators.validateNoteContent('Firestore content'), isNull);
      expect(Validators.validateNoteContent('Hi'), isNotNull);
    });
  });

  test('maps Firebase auth errors', () {
    expect(
      AuthErrorMapper.messageFromCode('invalid-credential'),
      'Invalid email or password.',
    );
  });

  test('copies note values', () {
    final now = DateTime(2026, 6, 14, 12, 30);
    final note = Note(
      id: 'note-1',
      title: 'Title',
      content: 'Content',
      createdAt: now,
      updatedAt: now,
      userId: 'user-1',
    );

    final updatedNote = note.copyWith(title: 'Updated title');

    expect(updatedNote.id, 'note-1');
    expect(updatedNote.title, 'Updated title');
    expect(updatedNote.content, 'Content');
    expect(updatedNote.userId, 'user-1');
  });
}
