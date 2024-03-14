// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';

/// Options for Firebase chat configuration.
@immutable
class FirebaseChatOptions {
  /// Creates a new instance of `FirebaseChatOptions`.
  const FirebaseChatOptions({
    this.groupChatsCollectionName = 'group_chats',
    this.chatsCollectionName = 'chats',
    this.messagesCollectionName = 'messages',
    this.usersCollectionName = 'users',
    this.chatsMetaDataCollectionName = 'chat_metadata',
    this.userChatsCollectionName = 'chats',
  });

  /// The collection name for group chats.
  final String groupChatsCollectionName;

  /// The collection name for chats.
  final String chatsCollectionName;

  /// The collection name for messages.
  final String messagesCollectionName;

  /// The collection name for users.
  final String usersCollectionName;

  /// The collection name for chat metadata.
  final String chatsMetaDataCollectionName;

  /// The collection name for user chats.
  final String userChatsCollectionName;

  /// Creates a copy of this FirebaseChatOptions but with the given fields
  /// replaced with the new values.
  FirebaseChatOptions copyWith({
    String? groupChatsCollectionName,
    String? chatsCollectionName,
    String? messagesCollectionName,
    String? usersCollectionName,
    String? chatsMetaDataCollectionName,
    String? userChatsCollectionName,
  }) =>
      FirebaseChatOptions(
        groupChatsCollectionName:
            groupChatsCollectionName ?? this.groupChatsCollectionName,
        chatsCollectionName: chatsCollectionName ?? this.chatsCollectionName,
        messagesCollectionName:
            messagesCollectionName ?? this.messagesCollectionName,
        usersCollectionName: usersCollectionName ?? this.usersCollectionName,
        chatsMetaDataCollectionName:
            chatsMetaDataCollectionName ?? this.chatsMetaDataCollectionName,
        userChatsCollectionName:
            userChatsCollectionName ?? this.userChatsCollectionName,
      );
}
