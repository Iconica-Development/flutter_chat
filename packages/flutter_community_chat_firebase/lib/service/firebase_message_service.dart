// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_community_chat_firebase/config/firebase_chat_options.dart';
import 'package:flutter_community_chat_firebase/dto/firebase_chat_document.dart';
import 'package:flutter_community_chat_firebase/dto/firebase_message_document.dart';
import 'package:flutter_community_chat_firebase/service/firebase_chat_service.dart';
import 'package:flutter_community_chat_firebase/service/firebase_user_service.dart';
import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';
import 'package:uuid/uuid.dart';

class FirebaseMessageService {
  FirebaseMessageService({
    required this.db,
    required this.storage,
    required this.userService,
    required this.chatService,
    required this.options,
  });

  final FirebaseFirestore db;
  final FirebaseStorage storage;
  final FirebaseUserService userService;
  final FirebaseChatService chatService;
  FirebaseChatOptoons options;
  late StreamController<List<ChatMessageModel>> _controller;
  StreamSubscription<QuerySnapshot>? _subscription;
  ChatModel? _chat;

  Future<void> setChat(ChatModel chat) async {
    if (chat.id == null && chat is PersonalChatModel) {
      var chatWithUser = await chatService.getChatByUser(chat.user);

      if (chatWithUser != null) {
        _chat = chatWithUser;
        return;
      }
    }

    _chat = chat;
  }

  Future<void> _beforeSendMessage() async {
    if (_chat != null) {
      _chat = await createChatIfNotExists(_chat!);
    }
  }

  Future<void> _sendMessage(Map<String, dynamic> data) async {
    var currentUser = await userService.getCurrentUser();

    if (_chat?.id == null || currentUser == null) {
      return;
    }

    var message = {
      'sender': currentUser.id,
      'timestamp': DateTime.now(),
      ...data
    };

    var chatReference = db
        .collection(
          options.chatsCollectionName,
        )
        .doc(_chat!.id);

    await chatReference
        .collection(
          options.messagesCollectionName,
        )
        .add(message);

    await chatReference.update({
      'last_used': DateTime.now(),
      'last_message': message,
    });
  }

  Future<void> sendTextMessage(String text) => _beforeSendMessage().then(
        (_) => _sendMessage({'text': text}),
      );

  Future<void> sendImageMessage(Uint8List image) => _beforeSendMessage().then(
        (_) {
          if (_chat?.id == null) {
            return null;
          }

          var ref = storage.ref(
              '${options.chatsCollectionName}/${_chat!.id}/${const Uuid().v4()}');

          return ref.putData(image).then(
                (_) => ref.getDownloadURL().then(
                  (url) {
                    _sendMessage({'image_url': url});
                  },
                ),
              );
        },
      );

  Query<FirebaseMessageDocument> _getMessagesQuery(String chatId) => db
      .collection(options.chatsCollectionName)
      .doc(chatId)
      .collection(options.messagesCollectionName)
      .orderBy('timestamp', descending: false)
      .withConverter<FirebaseMessageDocument>(
        fromFirestore: (snapshot, _) =>
            FirebaseMessageDocument.fromJson(snapshot.data()!, snapshot.id),
        toFirestore: (user, _) => user.toJson(),
      );

  Stream<List<ChatMessageModel>> getMessagesStream() {
    _controller = StreamController<List<ChatMessageModel>>(
      onListen: () {
        if (_chat?.id != null) {
          _subscription = _startListeningForMessages(_chat!);
        }
      },
      onCancel: () {
        _subscription?.cancel();
      },
    );

    return _controller.stream;
  }

  StreamSubscription<QuerySnapshot> _startListeningForMessages(ChatModel chat) {
    var snapshots = _getMessagesQuery(chat.id!).snapshots();

    return snapshots.listen(
      (snapshot) async {
        List<ChatMessageModel> messages = [];

        for (var messageDoc in snapshot.docs) {
          var messageData = messageDoc.data();

          var sender = await userService.getUser(messageData.sender);

          if (sender != null) {
            var timestamp = DateTime.fromMillisecondsSinceEpoch(
              (messageData.timestamp).millisecondsSinceEpoch,
            );

            messages.add(
              messageData.imageUrl != null
                  ? ChatImageMessageModel(
                      sender: sender,
                      imageUrl: messageData.imageUrl!,
                      timestamp: timestamp,
                    )
                  : ChatTextMessageModel(
                      sender: sender,
                      text: messageData.text!,
                      timestamp: timestamp,
                    ),
            );
          }
        }

        _controller.add(messages);
      },
    );
  }

  Future<ChatModel?> createChatIfNotExists(ChatModel chat) async {
    if (chat.id == null) {
      if (chat is! PersonalChatModel) {
        return null;
      }

      var currentUser = await userService.getCurrentUser();

      if (currentUser?.id == null || chat.user.id == null) {
        return null;
      }

      List<String> userIds = [
        currentUser!.id!,
        chat.user.id!,
      ];

      var reference = await db
          .collection(options.chatsCollectionName)
          .withConverter(
            fromFirestore: (snapshot, _) =>
                FirebaseChatDocument.fromJson(snapshot.data()!, snapshot.id),
            toFirestore: (chat, _) => chat.toJson(),
          )
          .add(
            FirebaseChatDocument(
              personal: true,
              users: userIds,
              lastUsed: Timestamp.now(),
            ),
          );

      for (var userId in userIds) {
        await db
            .collection(options.usersCollectionName)
            .doc(userId)
            .collection('chats')
            .doc(reference.id)
            .set({'users': userIds});
      }

      chat.id = reference.id;

      _subscription?.cancel();
      _subscription = _startListeningForMessages(chat);
    }

    return chat;
  }
}
