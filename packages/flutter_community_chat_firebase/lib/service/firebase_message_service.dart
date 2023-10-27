// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_community_chat_firebase/config/firebase_chat_options.dart';
import 'package:flutter_community_chat_firebase/dto/firebase_message_document.dart';
import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';
import 'package:uuid/uuid.dart';

class FirebaseMessageService implements MessageService {
  late final FirebaseFirestore _db;
  late final FirebaseStorage _storage;
  late final ChatUserService _userService;
  late FirebaseChatOptions _options;

  late StreamController<List<ChatMessageModel>> _controller;
  StreamSubscription<QuerySnapshot>? _subscription;

  FirebaseMessageService({
    required ChatUserService userService,
    FirebaseApp? app,
    FirebaseChatOptions? options,
  }) {
    var appInstance = app ?? Firebase.app();

    _db = FirebaseFirestore.instanceFor(app: appInstance);
    _storage = FirebaseStorage.instanceFor(app: appInstance);
    _userService = userService;
    _options = options ?? const FirebaseChatOptions();
  }

  Future<void> _sendMessage(ChatModel chat, Map<String, dynamic> data) async {
    var currentUser = await _userService.getCurrentUser();

    if (chat.id == null || currentUser == null) {
      return;
    }

    var message = {
      'sender': currentUser.id,
      'timestamp': DateTime.now(),
      ...data
    };

    var chatReference = _db
        .collection(
          _options.chatsCollectionName,
        )
        .doc(chat.id);

    await chatReference
        .collection(
          _options.messagesCollectionName,
        )
        .add(message);

    await chatReference.update({
      'last_used': DateTime.now(),
      'last_message': message,
    });

    if (chat.id != null && _controller.hasListener && (_subscription == null)) {
      _subscription = _startListeningForMessages(chat);
    }

    // update the chat counter for the other users
    // get all users from the chat
    // there is a field in the chat document called users that has a list of user ids
    var fetchedChat = await chatReference.get();
    var chatUsers = fetchedChat.data()?['users'] as List<dynamic>;
    // for all users except the message sender update the unread counter
    for (var userId in chatUsers) {
      if (userId != currentUser.id) {
        var userReference = _db
            .collection(
              _options.usersCollectionName,
            )
            .doc(userId)
            .collection('chats')
            .doc(chat.id);

        await userReference.update({
          'amount_unread_messages': FieldValue.increment(1),
        });
      }
    }
  }

  @override
  Future<void> sendTextMessage({
    required String text,
    required ChatModel chat,
  }) =>
      _sendMessage(
        chat,
        {
          'text': text,
        },
      );

  @override
  Future<void> sendImageMessage({
    required ChatModel chat,
    required Uint8List image,
  }) async {
    if (chat.id == null) {
      return;
    }

    var ref = _storage
        .ref('${_options.chatsCollectionName}/${chat.id}/${const Uuid().v4()}');

    return ref.putData(image).then(
          (_) => ref.getDownloadURL().then(
            (url) {
              _sendMessage(
                chat,
                {
                  'image_url': url,
                },
              );
            },
          ),
        );
  }

  Query<FirebaseMessageDocument> _getMessagesQuery(ChatModel chat) => _db
      .collection(_options.chatsCollectionName)
      .doc(chat.id)
      .collection(_options.messagesCollectionName)
      .orderBy('timestamp', descending: false)
      .withConverter<FirebaseMessageDocument>(
        fromFirestore: (snapshot, _) =>
            FirebaseMessageDocument.fromJson(snapshot.data()!, snapshot.id),
        toFirestore: (user, _) => user.toJson(),
      );

  @override
  Stream<List<ChatMessageModel>> getMessagesStream(ChatModel chat) {
    _controller = StreamController<List<ChatMessageModel>>(
      onListen: () {
        if (chat.id != null) {
          _subscription = _startListeningForMessages(chat);
        }
      },
      onCancel: () {
        _subscription?.cancel();
        _subscription = null;
        debugPrint('Canceling messages stream');
      },
    );

    return _controller.stream;
  }

  StreamSubscription<QuerySnapshot> _startListeningForMessages(ChatModel chat) {
    debugPrint('Start listening for messages in chat ${chat.id}');

    var snapshots = _getMessagesQuery(chat).snapshots();

    return snapshots.listen(
      (snapshot) async {
        var messages = <ChatMessageModel>[];

        for (var messageDoc in snapshot.docs) {
          var messageData = messageDoc.data();

          var sender = await _userService.getUser(messageData.sender);

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
}
