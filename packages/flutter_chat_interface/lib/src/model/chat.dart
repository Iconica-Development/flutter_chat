// ignore_for_file: public_member_api_docs, sort_constructors_first
// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter_chat_interface/flutter_chat_interface.dart';

abstract class ChatModelInterface {
  String? get id;
  List<ChatMessageModel>? get messages;
  int? get unreadMessages;
  DateTime? get lastUsed;
  ChatMessageModel? get lastMessage;
  bool get canBeDeleted;
}

/// A concrete implementation of [ChatModelInterface] representing a chat.
class ChatModel implements ChatModelInterface {
  /// Constructs a [ChatModel] instance.
  ///
  /// [id]: The ID of the chat.
  ///
  /// [messages]: The list of messages in the chat.
  ///
  /// [unreadMessages]: The number of unread messages in the chat.
  ///
  /// [lastUsed]: The timestamp when the chat was last used.
  ///
  /// [lastMessage]: The last message sent in the chat.
  ///
  /// [canBeDeleted]: Indicates whether the chat can be deleted.
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
}
