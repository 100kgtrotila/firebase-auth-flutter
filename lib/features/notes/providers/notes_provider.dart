import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_flutter/features/notes/models/note.dart';
import 'package:firebase_auth_flutter/features/notes/services/notes_service.dart';
import 'package:firebase_auth_flutter/features/notes/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NotesProvider extends ChangeNotifier {
  final NotesService _notesService = NotesService();
  final StorageService _storageService = StorageService();

  static const int maxImageSizeBytes = 5 * 1024 * 1024;

  bool _isLoading = false;
  double _uploadProgress = 0;

  bool get isLoading => _isLoading;
  double get uploadProgress => _uploadProgress;

  Stream<List<Note>> get notesStream => _notesService.getNotes();

  Future<String?> createNote({
    required String title,
    required String content,
    XFile? imageFile,
    void Function(double progress)? onProgress,
  }) async {
    _setLoading(true);
    var isUploadingImage = false;

    try {
      final validationError = await _validateImageFile(imageFile);
      if (validationError != null) {
        return validationError;
      }

      final noteId = await _notesService.createNote(
        title: title,
        content: content,
      );

      if (imageFile != null) {
        isUploadingImage = true;
        final uploadedImage = await _uploadImage(
          imageFile: imageFile,
          noteId: noteId,
          onProgress: onProgress,
        );

        await _notesService.updateNoteImage(
          noteId: noteId,
          imageUrl: uploadedImage.downloadUrl,
          imagePath: uploadedImage.storagePath,
          imageSize: uploadedImage.size,
          imageContentType: uploadedImage.contentType,
        );
      }

      return null;
    } on StateError {
      return 'You must be logged in to manage notes.';
    } on FirebaseException {
      return isUploadingImage
          ? 'Failed to upload image. Please try again.'
          : 'Failed to create note. Please try again.';
    } catch (_) {
      return isUploadingImage
          ? 'Failed to upload image. Please try again.'
          : 'Failed to create note. Please try again.';
    } finally {
      _setUploadProgress(0);
      _setLoading(false);
    }
  }

  Future<String?> updateNote({
    required Note note,
    required String title,
    required String content,
    XFile? newImageFile,
    bool removeCurrentImage = false,
    void Function(double progress)? onProgress,
  }) async {
    _setLoading(true);
    var isUploadingImage = false;

    try {
      final validationError = await _validateImageFile(newImageFile);
      if (validationError != null) {
        return validationError;
      }

      await _notesService.updateNote(
        noteId: note.id,
        title: title,
        content: content,
      );

      final shouldDeleteCurrentImage =
          removeCurrentImage || newImageFile != null;

      if (shouldDeleteCurrentImage) {
        await _deleteExistingImage(note);
      }

      if (removeCurrentImage && newImageFile == null) {
        await _notesService.removeNoteImage(noteId: note.id);
      }

      if (newImageFile != null) {
        isUploadingImage = true;
        final uploadedImage = await _uploadImage(
          imageFile: newImageFile,
          noteId: note.id,
          onProgress: onProgress,
        );

        await _notesService.updateNoteImage(
          noteId: note.id,
          imageUrl: uploadedImage.downloadUrl,
          imagePath: uploadedImage.storagePath,
          imageSize: uploadedImage.size,
          imageContentType: uploadedImage.contentType,
        );
      }

      return null;
    } on StateError {
      return 'You must be logged in to manage notes.';
    } on FirebaseException {
      return isUploadingImage
          ? 'Failed to upload image. Please try again.'
          : 'Failed to update note. Please try again.';
    } catch (_) {
      return isUploadingImage
          ? 'Failed to upload image. Please try again.'
          : 'Failed to update note. Please try again.';
    } finally {
      _setUploadProgress(0);
      _setLoading(false);
    }
  }

  Future<String?> deleteNote(Note note) async {
    _setLoading(true);

    try {
      await _deleteExistingImage(note);
      await _notesService.deleteNote(note.id);
      return null;
    } on StateError {
      return 'You must be logged in to manage notes.';
    } on FirebaseException {
      return 'Failed to delete note. Please try again.';
    } catch (_) {
      return 'Failed to delete note. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  Future<UploadedNoteImage> _uploadImage({
    required XFile imageFile,
    required String noteId,
    void Function(double progress)? onProgress,
  }) {
    return _storageService.uploadNoteImage(
      imageFile: imageFile,
      noteId: noteId,
      onProgress: (progress) {
        _setUploadProgress(progress);
        onProgress?.call(progress);
      },
    );
  }

  Future<void> _deleteExistingImage(Note note) async {
    final imagePath = note.imagePath;
    final imageUrl = note.imageUrl;

    if (imagePath != null && imagePath.isNotEmpty) {
      await _storageService.deleteNoteImageByPath(imagePath);
      return;
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      await _storageService.deleteNoteImageByUrl(imageUrl);
    }
  }

  Future<String?> _validateImageFile(XFile? imageFile) async {
    if (imageFile == null) {
      return null;
    }

    final fileSize = await imageFile.length();

    if (fileSize > maxImageSizeBytes) {
      return 'Image is too large. Maximum size is 5MB.';
    }

    return null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setUploadProgress(double value) {
    _uploadProgress = value;
    notifyListeners();
  }
}
