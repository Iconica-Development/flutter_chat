// ignore_for_file: public_member_api_docs, sort_constructors_first
// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter_chat_interface/flutter_chat_interface.dart';

abstract class ChatModelInterface {
  ChatModelInterface copyWith();
  String? get id;
  List<ChatMessageModel>? get messages;
  int? get unreadMessages;
  DateTime? get lastUsed;
  ChatMessageModel? get lastMessage;
  bool get canBeDeleted;
}

class ChatModel implements ChatModelInterface {
  ChatModel({
    this.id,
    this.messages = const [],
    this.unreadMessages,
    this.lastUsed,
    this.lastMessage,
    this.canBeDeleted = true,
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
  ChatModel copyWith({
    String? id,
    List<ChatMessageModel>? messages,
    int? unreadMessages,
    DateTime? lastUsed,
    ChatMessageModel? lastMessage,
    bool? canBeDeleted,
  }) =>
      ChatModel(
        id: id ?? this.id,
        messages: messages ?? this.messages,
        unreadMessages: unreadMessages ?? this.unreadMessages,
        lastUsed: lastUsed ?? this.lastUsed,
        lastMessage: lastMessage ?? this.lastMessage,
        canBeDeleted: canBeDeleted ?? this.canBeDeleted,
      );
}
