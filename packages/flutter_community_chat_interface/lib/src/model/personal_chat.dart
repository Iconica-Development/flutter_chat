// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';

class PersonalChatModel extends ChatModel {
  PersonalChatModel({
    required this.user,
    super.id,
    super.messages,
    super.unreadMessages,
    super.lastUsed,
    super.lastMessage,
  });

  final ChatUserModel user;

  PersonalChatModel copyWith({
    String? id,
    List<ChatMessageModel>? messages,
    int? unreadMessages,
    DateTime? lastUsed,
    ChatMessageModel? lastMessage,
    ChatUserModel? user,
  }) =>
      PersonalChatModel(
        id: id ?? this.id,
        messages: messages ?? this.messages,
        unreadMessages: unreadMessages ?? this.unreadMessages,
        lastUsed: lastUsed ?? this.lastUsed,
        lastMessage: lastMessage ?? this.lastMessage,
        user: user ?? this.user,
      );
}
