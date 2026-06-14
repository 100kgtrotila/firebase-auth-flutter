import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }
}
