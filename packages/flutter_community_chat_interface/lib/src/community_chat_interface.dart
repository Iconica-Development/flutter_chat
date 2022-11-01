// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:typed_data';

import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';
import 'package:flutter_data_interface/flutter_data_interface.dart';

abstract class CommunityChatInterface extends DataInterface {
  CommunityChatInterface() : super(token: _token);

  static final Object _token = Object();

  Future<void> createChat(ChatModel chat);
  Future<void> sendTextMessage(ChatModel chat, String text);
  Future<void> sendImageMessage(ChatModel chat, Uint8List image);
  Stream<List<ChatMessageModel>> getMessagesStream(ChatModel chat);
  Stream<List<ChatModel>> getChatsStream();
  Future<List<ChatUserModel>> getChatUsers();
}
