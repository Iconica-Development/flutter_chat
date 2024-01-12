// ignore_for_file: public_member_api_docs, sort_constructors_first
// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter_chat_interface/flutter_chat_interface.dart';

abstract class PersonalChatModelInterface extends ChatModel {
  PersonalChatModelInterface({
    super.id,
    super.messages,
    super.unreadMessages,
    super.lastUsed,
    super.lastMessage,
    super.canBeDeleted,
  });

  ChatUserModel get user;

  PersonalChatModel copyWith({
    String? id,
    List<ChatMessageModel>? messages,
    int? unreadMessages,
    DateTime? lastUsed,
    ChatMessageModel? lastMessage,
    ChatUserModel? user,
    bool? canBeDeleted,
  });
}

class PersonalChatModel implements PersonalChatModelInterface {
  PersonalChatModel({
    this.id,
    this.messages = const [],
    this.unreadMessages,
    this.lastUsed,
    this.lastMessage,
    this.canBeDeleted = true,
    required this.user,
  });

  @override
  String? id;
  @override
  final List<ChatMessageModel>? messages;
  @override
  final int? unreadMessages;
  @override
  final DateTime? lastUsed;
  @override
  final ChatMessageModel? lastMessage;
  @override
  final bool canBeDeleted;

  @override
  final ChatUserModel user;

  @override
  PersonalChatModel copyWith({
    String? id,
    List<ChatMessageModel>? messages,
    int? unreadMessages,
    DateTime? lastUsed,
    ChatMessageModel? lastMessage,
    bool? canBeDeleted,
    ChatUserModel? user,
  }) {
    return PersonalChatModel(
      id: id ?? this.id,
      messages: messages ?? this.messages,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      lastUsed: lastUsed ?? this.lastUsed,
      lastMessage: lastMessage ?? this.lastMessage,
      user: user ?? this.user,
      canBeDeleted: canBeDeleted ?? this.canBeDeleted,
    );
  }
}
