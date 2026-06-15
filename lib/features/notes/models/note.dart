import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.imageUrl,
    this.imagePath,
    this.imageSize,
    this.imageContentType,
  });

  static const Object _unset = Object();

  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final String? imageUrl;
  final String? imagePath;
  final int? imageSize;
  final String? imageContentType;

  factory Note.fromJson(Map<String, dynamic> json, String id) {
    final createdAtTimestamp = json['createdAt'];
    final updatedAtTimestamp = json['updatedAt'];

    return Note(
      id: id,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: createdAtTimestamp is Timestamp
          ? createdAtTimestamp.toDate()
          : DateTime.now(),
      updatedAt: updatedAtTimestamp is Timestamp
          ? updatedAtTimestamp.toDate()
          : DateTime.now(),
      userId: json['userId'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      imagePath: json['imagePath'] as String?,
      imageSize: json['imageSize'] is num
          ? (json['imageSize'] as num).toInt()
          : null,
      imageContentType: json['imageContentType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'imageSize': imageSize,
      'imageContentType': imageContentType,
    };
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    Object? imageUrl = _unset,
    Object? imagePath = _unset,
    Object? imageSize = _unset,
    Object? imageContentType = _unset,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      imageUrl: imageUrl == _unset ? this.imageUrl : imageUrl as String?,
      imagePath: imagePath == _unset ? this.imagePath : imagePath as String?,
      imageSize: imageSize == _unset ? this.imageSize : imageSize as int?,
      imageContentType: imageContentType == _unset
          ? this.imageContentType
          : imageContentType as String?,
    );
  }
}
