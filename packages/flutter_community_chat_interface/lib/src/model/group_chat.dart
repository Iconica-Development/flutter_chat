// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';

class GroupChatModel extends ChatModel {
  GroupChatModel({
    required this.title,
    required this.imageUrl,
    required this.users,
    super.id,
    super.messages,
    super.lastUsed,
    super.lastMessage,
    super.unreadMessages,
    super.canBeDeleted,
  });

  final String title;
  final String imageUrl;
  final List<ChatUserModel> users;

  GroupChatModel copyWith({
    String? id,
    List<ChatMessageModel>? messages,
    int? unreadMessages,
    DateTime? lastUsed,
    ChatMessageModel? lastMessage,
    String? title,
    String? imageUrl,
    List<ChatUserModel>? users,
    bool? canBeDeleted,
  }) =>
      GroupChatModel(
        id: id ?? this.id,
        messages: messages ?? this.messages,
        unreadMessages: unreadMessages ?? this.unreadMessages,
        lastUsed: lastUsed ?? this.lastUsed,
        lastMessage: lastMessage ?? this.lastMessage,
        title: title ?? this.title,
        imageUrl: imageUrl ?? this.imageUrl,
        users: users ?? this.users,
        canBeDeleted: canBeDeleted ?? this.canBeDeleted,
      );
}
