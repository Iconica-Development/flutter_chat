// ignore_for_file: public_member_api_docs, sort_constructors_first
// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter_chat_interface/flutter_chat_interface.dart';

abstract class ChatTextMessageModelInterface extends ChatMessageModel {
  ChatTextMessageModelInterface({
    required super.sender,
    required super.timestamp,
  });

  String get text;
}

/// A concrete implementation of [ChatTextMessageModelInterface]
/// representing a text message in a chat.
class ChatTextMessageModel implements ChatTextMessageModelInterface {
  /// Constructs a [ChatTextMessageModel] instance.
  ///
  /// [sender]: The sender of the message.
  ///
  /// [timestamp]: The timestamp when the message was sent.
  ///
  /// [text]: The text content of the message.
  ChatTextMessageModel({
    required this.sender,
    required this.timestamp,
    required this.text,
  });

  @override
  final ChatUserModel sender;

  @override
  final DateTime timestamp;

  @override
  final String text;
}
