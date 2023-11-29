// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter_community_chat_interface/src/model/chat_message.dart';

abstract class ChatModel {
  ChatModel({
    this.id,
    this.messages = const [],
    this.unreadMessages,
    this.lastUsed,
    this.lastMessage,
    this.canBeDeleted = true,
  });

  String? id;
  List<ChatMessageModel>? messages;
  int? unreadMessages;
  DateTime? lastUsed;
  ChatMessageModel? lastMessage;
  bool canBeDeleted;
}
