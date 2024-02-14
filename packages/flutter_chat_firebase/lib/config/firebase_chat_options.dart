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
    this.chatsMetaDataCollectionName = 'chat_metadata',
    this.userChatsCollectionName = 'chats',
  });

  final String groupChatsCollectionName;
  final String chatsCollectionName;
  final String messagesCollectionName;
  final String usersCollectionName;
  final String chatsMetaDataCollectionName;

  ///This is the collection inside the user document.
  final String userChatsCollectionName;

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
