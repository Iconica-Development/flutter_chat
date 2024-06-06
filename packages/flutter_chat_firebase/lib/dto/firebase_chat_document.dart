// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter_chat_firebase/dto/firebase_message_document.dart";

/// Represents a chat document in Firebase.
@immutable
class FirebaseChatDocument {
  /// Creates a new instance of `FirebaseChatDocument`.
  const FirebaseChatDocument({
    required this.personal,
    required this.canBeDeleted,
    this.users = const [],
    this.id,
    this.lastUsed,
    this.title,
    this.imageUrl,
    this.lastMessage,
  });

  /// Constructs a FirebaseChatDocument from JSON.
  FirebaseChatDocument.fromJson(Map<String, dynamic> json, this.id)
      : title = json["title"],
        imageUrl = json["image_url"],
        personal = json["personal"],
        canBeDeleted = json["can_be_deleted"] ?? true,
        lastUsed = json["last_used"],
        users = json["users"] != null ? List<String>.from(json["users"]) : [],
        lastMessage = json["last_message"] == null
            ? null
            : FirebaseMessageDocument.fromJson(
                json["last_message"],
                null,
              );

  /// The unique identifier of the chat document.
  final String? id;

  /// The title of the chat.
  final String? title;

  /// The image URL of the chat.
  final String? imageUrl;

  /// Indicates if the chat is personal.
  final bool personal;

  /// Indicates if the chat can be deleted.
  final bool canBeDeleted;

  /// The timestamp of when the chat was last used.
  final Timestamp? lastUsed;

  /// The list of users participating in the chat.
  final List<String> users;

  /// The last message in the chat.
  final FirebaseMessageDocument? lastMessage;

  /// Converts the FirebaseChatDocument to JSON format.
  Map<String, dynamic> toJson() => {
        "title": title,
        "image_url": imageUrl,
        "personal": personal,
        "last_used": lastUsed,
        "can_be_deleted": canBeDeleted,
        "users": users,
      };
}
