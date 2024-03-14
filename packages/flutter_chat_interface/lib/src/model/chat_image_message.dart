// ignore_for_file: public_member_api_docs, sort_constructors_first
// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter_chat_interface/flutter_chat_interface.dart';

/// An abstract class defining the interface for an image message in a chat.
abstract class ChatImageMessageModelInterface extends ChatMessageModel {
  /// Constructs a [ChatImageMessageModelInterface] instance.
  ///
  /// [sender]: The sender of the message.
  ///
  /// [timestamp]: The timestamp when the message was sent.
  ChatImageMessageModelInterface({
    required super.sender,
    required super.timestamp,
  });

  /// Returns the URL of the image associated with the message.
  String get imageUrl;
}

/// A concrete implementation of [ChatImageMessageModelInterface]
/// representing an image message in a chat.
class ChatImageMessageModel implements ChatImageMessageModelInterface {
  /// Constructs a [ChatImageMessageModel] instance.
  ///
  /// [sender]: The sender of the message.
  ///
  /// [timestamp]: The timestamp when the message was sent.
  ///
  /// [imageUrl]: The URL of the image associated with the message.
  ChatImageMessageModel({
    required this.sender,
    required this.timestamp,
    required this.imageUrl,
  });

  @override
  final ChatUserModel sender;

  @override
  final DateTime timestamp;

  @override
  final String imageUrl;
}
