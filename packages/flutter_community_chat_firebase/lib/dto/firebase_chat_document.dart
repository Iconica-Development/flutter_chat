import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_community_chat_firebase/dto/firebase_message_document.dart';

class FirebaseChatDocument {
  FirebaseChatDocument({
    required this.personal,
    this.users = const [],
    this.id,
    this.lastUsed,
    this.title,
    this.lastMessage,
  });

  final String? id;
  final String? title;
  final bool personal;
  final Timestamp? lastUsed;
  final List<String> users;
  final FirebaseMessageDocument? lastMessage;

  FirebaseChatDocument.fromJson(Map<String, dynamic> json, this.id)
      : title = json['title'],
        personal = json['personal'],
        lastUsed = json['last_used'],
        users = List<String>.from(json['users']),
        lastMessage = json['last_message'] == null
            ? null
            : FirebaseMessageDocument.fromJson(
                json['last_message'],
                null,
              );

  Map<String, dynamic> toJson() => {
        'title': title,
        'personal': personal,
        'last_used': lastUsed,
        'users': users,
      };
}
