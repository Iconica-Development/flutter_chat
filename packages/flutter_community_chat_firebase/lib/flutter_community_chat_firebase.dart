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
  final FirebaseChatOptoons firebaseChatOptoons;

  FirebaseCommunityChatDataProvider({
    this.firebaseChatOptoons = const FirebaseChatOptoons(),
    FirebaseApp? app,
  }) {
    var appInstance = app ?? Firebase.app();

    var db = FirebaseFirestore.instanceFor(app: appInstance);
    var storage = FirebaseStorage.instanceFor(app: appInstance);
    var auth = FirebaseAuth.instanceFor(app: appInstance);

    _userService = FirebaseUserService(
      db: db,
      auth: auth,
      options: firebaseChatOptoons,
    );

    _messageService = FirebaseMessageService(
      db: db,
      storage: storage,
      userService: _userService,
      options: firebaseChatOptoons,
    );

    _chatService = FirebaseChatService(
      db: db,
      userService: _userService,
      options: firebaseChatOptoons,
    );
  }

  @override
  Stream<List<ChatMessageModel>> getMessagesStream(ChatModel chat) =>
      _messageService.getMessagesStream(chat);

  @override
  Future<List<ChatUserModel>> getChatUsers() => _userService.getNewUsers();

  @override
  Stream<List<ChatModel>> getChatsStream() => _chatService.getChatsStream();

  @override
  Future<void> createChat(ChatModel chat) => _chatService.createChat(chat);

  @override
  Future<void> sendTextMessage(ChatModel chat, String text) =>
      _messageService.sendTextMessage(chat, text);

  @override
  Future<void> sendImageMessage(ChatModel chat, Uint8List image) =>
      _messageService.sendImageMessage(chat, image);
}
