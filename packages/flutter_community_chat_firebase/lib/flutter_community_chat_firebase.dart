// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

library flutter_community_chat_firebase;

import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_community_chat_firebase/config/firebase_chat_options.dart';
import 'package:flutter_community_chat_firebase/service/firebase_chat_service.dart';
import 'package:flutter_community_chat_firebase/service/firebase_message_service.dart';
import 'package:flutter_community_chat_firebase/service/firebase_user_service.dart';
import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';

class FirebaseCommunityChatDataProvider extends CommunityChatInterface {
  late final FirebaseUserService _userService;
  late final FirebaseMessageService _messageService;
  late final FirebaseChatService _chatService;
  final FirebaseChatOptions firebaseChatOptions;

  FirebaseCommunityChatDataProvider({
    this.firebaseChatOptions = const FirebaseChatOptions(),
    FirebaseApp? app,
  }) {
    var appInstance = app ?? Firebase.app();

    var db = FirebaseFirestore.instanceFor(app: appInstance);
    var storage = FirebaseStorage.instanceFor(app: appInstance);
    var auth = FirebaseAuth.instanceFor(app: appInstance);

    _userService = FirebaseUserService(
      db: db,
      auth: auth,
      options: firebaseChatOptions,
    );

    _chatService = FirebaseChatService(
      db: db,
      storage: storage,
      userService: _userService,
      options: firebaseChatOptions,
    );

    _messageService = FirebaseMessageService(
      db: db,
      storage: storage,
      userService: _userService,
      chatService: _chatService,
      options: firebaseChatOptions,
    );
  }

  @override
  Stream<List<ChatMessageModel>> getMessagesStream() =>
      _messageService.getMessagesStream();

  @override
  Future<List<ChatUserModel>> getChatUsers() => _userService.getAllUsers();

  @override
  Stream<List<ChatModel>> getChatsStream() => _chatService.getChatsStream();

  @override
  Future<void> sendTextMessage(String text) =>
      _messageService.sendTextMessage(text);

  @override
  Future<void> sendImageMessage(Uint8List image) =>
      _messageService.sendImageMessage(image);

  @override
  Future<void> setChat(ChatModel chat) async =>
      await _messageService.setChat(chat);

  @override
  Future<void> deleteChat(ChatModel chat) async =>
      await _chatService.deleteChat(chat);
}
