// ignore_for_file: public_member_api_docs, sort_constructors_first
// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:flutter_chat_interface/src/model/chat_user.dart";

abstract class ChatMessageModelInterface {
  ChatUserModel get sender;
  DateTime get timestamp;
}

/// A concrete implementation of [ChatMessageModelInterface]
/// representing a chat message.
class ChatMessageModel implements ChatMessageModelInterface {
  /// Constructs a [ChatMessageModel] instance.
  ///
  /// [sender]: The sender of the message.
  ///
  /// [timestamp]: The timestamp when the message was sent.
  ChatMessageModel({
    required this.sender,
    required this.timestamp,
  });

  @override
  final ChatUserModel sender;

  @override
  final DateTime timestamp;
}
