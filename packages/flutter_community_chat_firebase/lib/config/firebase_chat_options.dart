// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';

@immutable
class FirebaseChatOptions {
  const FirebaseChatOptions({
    this.groupChatsCollectionName = 'group_chats',
    this.chatsCollectionName = 'chats',
    this.messagesCollectionName = 'messages',
    this.usersCollectionName = 'users',
  });

  final String groupChatsCollectionName;
  final String chatsCollectionName;
  final String messagesCollectionName;
  final String usersCollectionName;

  FirebaseChatOptions copyWith({
    String? groupChatsCollectionName,
    String? chatsCollectionName,
    String? messagesCollectionName,
    String? usersCollectionName,
  }) {
    return FirebaseChatOptions(
      groupChatsCollectionName:
          groupChatsCollectionName ?? this.groupChatsCollectionName,
      chatsCollectionName: chatsCollectionName ?? this.chatsCollectionName,
      messagesCollectionName:
          messagesCollectionName ?? this.messagesCollectionName,
      usersCollectionName: usersCollectionName ?? this.usersCollectionName,
    );
  }
}
