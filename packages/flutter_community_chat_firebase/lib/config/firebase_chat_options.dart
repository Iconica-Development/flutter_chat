// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

class FirebaseChatOptions {
  const FirebaseChatOptions({
    this.chatsCollectionName = 'chats',
    this.messagesCollectionName = 'messages',
    this.usersCollectionName = 'users',
  });

  final String chatsCollectionName;
  final String messagesCollectionName;
  final String usersCollectionName;
}
