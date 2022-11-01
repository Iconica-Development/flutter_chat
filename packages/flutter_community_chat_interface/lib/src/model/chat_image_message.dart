// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter_community_chat_interface/src/model/chat_message.dart';

class ChatImageMessageModel extends ChatMessageModel {
  ChatImageMessageModel({
    required super.sender,
    required super.timestamp,
    required this.imageUrl,
  });

  final String imageUrl;
}
