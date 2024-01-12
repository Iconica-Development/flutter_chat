// ignore_for_file: public_member_api_docs, sort_constructors_first
// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter_chat_interface/src/model/chat_user.dart';

abstract class ChatMessageModelInterface {
  ChatUserModel get sender;
  DateTime get timestamp;
}

class ChatMessageModel implements ChatMessageModelInterface {
  ChatMessageModel({
    required this.sender,
    required this.timestamp,
  });

  @override
  final ChatUserModel sender;
  @override
  final DateTime timestamp;
}
