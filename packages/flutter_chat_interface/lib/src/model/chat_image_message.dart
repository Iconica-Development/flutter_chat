// ignore_for_file: public_member_api_docs, sort_constructors_first
// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter_chat_interface/flutter_chat_interface.dart';

abstract class ChatImageMessageModelInterface extends ChatMessageModel {
  ChatImageMessageModelInterface({
    required super.sender,
    required super.timestamp,
  });

  String get imageUrl;
}

class ChatImageMessageModel implements ChatImageMessageModelInterface {
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
