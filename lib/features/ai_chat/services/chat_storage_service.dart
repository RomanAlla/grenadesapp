import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


class ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    role: json['role'],
    content: json['content'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class ChatStorageService {
  static const String _key = 'chat_messages';
  
  Future<void> saveMessages(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = messages.map((msg) => msg.toJson()).toList();
    await prefs.setString(_key, jsonEncode(messagesJson));
  }

  Future<List<ChatMessage>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesString = prefs.getString(_key);
    if (messagesString == null) return [];

    final messagesJson = jsonDecode(messagesString) as List;
    return messagesJson
        .map((msg) => ChatMessage.fromJson(msg))
        .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> clearMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
} 