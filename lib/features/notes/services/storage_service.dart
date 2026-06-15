import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class UploadedNoteImage {
  const UploadedNoteImage({
    required this.downloadUrl,
    required this.storagePath,
    required this.size,
    required this.contentType,
  });

  final String downloadUrl;
  final String storagePath;
  final int size;
  final String contentType;
}

class StorageService {
  StorageService({FirebaseStorage? storage, FirebaseAuth? firebaseAuth})
    : _storage = storage ?? FirebaseStorage.instance,
      _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseStorage _storage;
  final FirebaseAuth _firebaseAuth;

  User _requireUser() {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw StateError('You must be logged in to manage notes.');
    }

    return user;
  }

  Future<UploadedNoteImage> uploadNoteImage({
    required XFile imageFile,
    required String noteId,
    required void Function(double progress) onProgress,
  }) async {
    final user = _requireUser();
    final fileSize = await imageFile.length();
    final imageBytes = await imageFile.readAsBytes();
    final contentType = _contentTypeFromPath(imageFile.name);
    final extension = contentType == 'image/png' ? 'png' : 'jpg';
    final fileName =
        'image_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final storagePath = 'users/${user.uid}/notes/$noteId/$fileName';
    final ref = _storage.ref().child(storagePath);

    final metadata = SettableMetadata(
      contentType: contentType,
      customMetadata: {
        'userId': user.uid,
        'noteId': noteId,
        'uploadedAt': DateTime.now().toIso8601String(),
        'size': fileSize.toString(),
      },
    );

    final uploadTask = ref.putData(imageBytes, metadata);
    final subscription = uploadTask.snapshotEvents.listen((snapshot) {
      final totalBytes = snapshot.totalBytes;
      if (totalBytes <= 0) {
        onProgress(0);
        return;
      }

      onProgress(snapshot.bytesTransferred / totalBytes);
    }, onError: (_) {});

    final taskSnapshot = await uploadTask.whenComplete(subscription.cancel);
    final downloadUrl = await taskSnapshot.ref.getDownloadURL();

    return UploadedNoteImage(
      downloadUrl: downloadUrl,
      storagePath: storagePath,
      size: fileSize,
      contentType: contentType,
    );
  }

  Future<void> deleteNoteImageByPath(String imagePath) async {
    try {
      await _storage.ref().child(imagePath).delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') {
        rethrow;
      }
    }
  }

  Future<void> deleteNoteImageByUrl(String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') {
        rethrow;
      }
    }
  }

  String _contentTypeFromPath(String path) {
    return path.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
  }
}
