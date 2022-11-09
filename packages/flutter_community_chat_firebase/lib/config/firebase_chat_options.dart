// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

class FirebaseChatOptoons {
  const FirebaseChatOptoons({
    this.chatsCollectionName = 'chats',
    this.messagesCollectionName = 'messages',
    this.usersCollectionName = 'users',
    this.userFilter,
  });

  final String chatsCollectionName;
  final String messagesCollectionName;
  final String usersCollectionName;

  final FirebaseUserFilter? userFilter;
}

class FirebaseUserFilter {
  const FirebaseUserFilter({
    required this.field,
    required this.expectedValue,
  });

  final String field;
  final Object expectedValue;
}
