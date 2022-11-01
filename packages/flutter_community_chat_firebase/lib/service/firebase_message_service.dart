// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_community_chat_firebase/config/firebase_chat_options.dart';
import 'package:flutter_community_chat_firebase/dto/firebase_message_document.dart';
import 'package:flutter_community_chat_firebase/service/firebase_user_service.dart';
import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';
import 'package:uuid/uuid.dart';

class FirebaseMessageService {
  FirebaseMessageService({
    required this.db,
    required this.storage,
    required this.userService,
    required this.options,
  });

  final FirebaseFirestore db;
  final FirebaseStorage storage;
  final FirebaseUserService userService;
  FirebaseChatOptoons options;

  Future<void> sendTextMessage(ChatModel chat, String text) =>
      _sendMessage(chat, {'text': text});

  Future<void> sendImageMessage(ChatModel chat, Uint8List image) async {
    var ref = storage
        .ref('${options.chatsCollectionName}/${chat.id}/${const Uuid().v4()}');

    return ref.putData(image).then(
          (_) => ref.getDownloadURL().then(
            (url) {
              _sendMessage(chat, {'image_url': url});
            },
          ),
        );
  }

  Future<void> _sendMessage(
    ChatModel chat,
    Map<String, dynamic> data,
  ) async {
    var currentUser = await userService.getCurrentUser();

    if (currentUser == null) {
      return;
    }

    var message = {
      'sender': currentUser.id,
      'timestamp': DateTime.now(),
      ...data
    };

    var chatReference = db.collection(options.chatsCollectionName).doc(chat.id);

    await chatReference.collection(options.messagesCollectionName).add(message);

    await chatReference.update({
      'last_used': DateTime.now(),
      'last_message': message,
    });
  }

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

  Stream<List<ChatMessageModel>> getMessagesStream(ChatModel chat) {
    late StreamController<List<ChatMessageModel>> controller;
    StreamSubscription<QuerySnapshot>? subscription;
    controller = StreamController<List<ChatMessageModel>>(
      onListen: () {
        var snapshots = _getMessagesQuery(chat.id!).snapshots();

        subscription = snapshots.listen(
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

            controller.add(messages);
          },
        );
      },
      onCancel: () => subscription?.cancel(),
    );
    return controller.stream;
  }
}
