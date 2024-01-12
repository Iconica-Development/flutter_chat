// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_firebase/dto/firebase_message_document.dart';

@immutable
class FirebaseChatDocument {
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

  final String? id;
  final String? title;
  final String? imageUrl;
  final bool personal;
  final bool canBeDeleted;
  final Timestamp? lastUsed;
  final List<String> users;
  final FirebaseMessageDocument? lastMessage;

  FirebaseChatDocument.fromJson(Map<String, dynamic> json, this.id)
      : title = json['title'],
        imageUrl = json['image_url'],
        personal = json['personal'],
        canBeDeleted = json['can_be_deleted'] ?? true,
        lastUsed = json['last_used'],
        users = json['users'] != null ? List<String>.from(json['users']) : [],
        lastMessage = json['last_message'] == null
            ? null
            : FirebaseMessageDocument.fromJson(
                json['last_message'],
                null,
              );

  Map<String, dynamic> toJson() => {
        'title': title,
        'image_url': imageUrl,
        'personal': personal,
        'last_used': lastUsed,
        'can_be_deleted': canBeDeleted,
        'users': users,
      };
}
