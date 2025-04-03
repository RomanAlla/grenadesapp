import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String text;
  final String authorId;
  final String authorEmail;
  final DateTime timestamp;

  CommentModel({
    required this.id,
    required this.text,
    required this.authorId,
    required this.authorEmail,
    required this.timestamp,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      authorId: json['authorId'] ?? '',
      authorEmail: json['authorEmail'] ?? '',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'authorId': authorId,
      'authorEmail': authorEmail,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
} 