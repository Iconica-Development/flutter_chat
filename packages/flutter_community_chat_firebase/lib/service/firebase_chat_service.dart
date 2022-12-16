// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_community_chat_firebase/config/firebase_chat_options.dart';
import 'package:flutter_community_chat_firebase/dto/firebase_chat_document.dart';
import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';

class FirebaseChatService implements ChatService {
  late FirebaseFirestore _db;
  late FirebaseStorage _storage;
  late ChatUserService _userService;
  late FirebaseChatOptions _options;

  FirebaseChatService({
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

  StreamSubscription<QuerySnapshot> _addChatSubscription(
    List<String> chatIds,
    Function(List<PersonalChatModel>) onReceivedChats,
  ) {
    var snapshots = _db
        .collection(_options.chatsCollectionName)
        .where(
          FieldPath.documentId,
          whereIn: chatIds,
        )
        .withConverter(
          fromFirestore: (snapshot, _) =>
              FirebaseChatDocument.fromJson(snapshot.data()!, snapshot.id),
          toFirestore: (chat, _) => chat.toJson(),
        )
        .snapshots();

    return snapshots.listen((snapshot) async {
      var currentUser = await _userService.getCurrentUser();
      List<PersonalChatModel> chats = [];

      for (var chatDoc in snapshot.docs) {
        var chatData = chatDoc.data();

        List<ChatMessageModel> messages = [];

        if (chatData.lastMessage != null) {
          var messageData = chatData.lastMessage!;
          var sender = await _userService.getUser(messageData.sender);

          if (sender != null) {
            var timestamp = DateTime.fromMillisecondsSinceEpoch(
              messageData.timestamp.millisecondsSinceEpoch,
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

        var otherUserId = List<String>.from(chatData.users).firstWhere(
          (element) => element != currentUser?.id,
        );
        var otherUser = await _userService.getUser(otherUserId);

        if (otherUser != null) {
          chats.add(
            PersonalChatModel(
              id: chatDoc.id,
              user: otherUser,
              lastMessage: messages.isNotEmpty ? messages.last : null,
              messages: messages,
              lastUsed: chatData.lastUsed == null
                  ? null
                  : DateTime.fromMillisecondsSinceEpoch(
                      chatData.lastUsed!.millisecondsSinceEpoch,
                    ),
            ),
          );
        }
      }

      onReceivedChats(chats);
    });
  }

  List<List<String>> _splitChatIds({
    required List<String> chatIds,
    int chunkSize = 10,
  }) {
    var result = <List<String>>[];
    var length = chatIds.length;

    for (var i = 0; i < length; i += chunkSize) {
      var lastIndex = i + chunkSize;
      result.add(
        chatIds.sublist(i, lastIndex > length ? length : lastIndex),
      );
    }

    return result;
  }

  Stream<List<PersonalChatModel>> _getSpecificChatsStream(
      List<String> chatIds) {
    late StreamController<List<PersonalChatModel>> controller;
    List<StreamSubscription<QuerySnapshot>> subscriptions = [];
    var splittedChatIds = _splitChatIds(chatIds: chatIds);

    controller = StreamController<List<PersonalChatModel>>(
      onListen: () {
        var chats = <int, List<PersonalChatModel>>{};

        for (var chatIdPair in splittedChatIds.asMap().entries) {
          subscriptions.add(
            _addChatSubscription(
              chatIdPair.value,
              (data) {
                chats[chatIdPair.key] = data;

                List<PersonalChatModel> mergedChats = [];

                mergedChats.addAll(
                  chats.values.expand((element) => element),
                );

                mergedChats.sort(
                  (a, b) => (b.lastUsed ?? DateTime.now()).compareTo(
                    a.lastUsed ?? DateTime.now(),
                  ),
                );

                controller.add(mergedChats);
              },
            ),
          );
        }
      },
      onCancel: () {
        for (var subscription in subscriptions) {
          subscription.cancel();
        }
      },
    );
    return controller.stream;
  }

  @override
  Stream<List<PersonalChatModel>> getChatsStream() {
    late StreamController<List<PersonalChatModel>> controller;
    StreamSubscription? userChatsSubscription;
    StreamSubscription? chatsSubscription;
    controller = StreamController(
      onListen: () async {
        debugPrint('Start listening to chats');
        var currentUser = await _userService.getCurrentUser();
        userChatsSubscription = _db
            .collection(_options.usersCollectionName)
            .doc(currentUser?.id)
            .collection('chats')
            .snapshots()
            .listen((snapshot) {
          List<String> chatIds = snapshot.docs.map((chat) => chat.id).toList();

          if (chatIds.isNotEmpty) {
            chatsSubscription = _getSpecificChatsStream(chatIds).listen(
              (event) => controller.add(event),
            );
          }
        });
      },
      onCancel: () {
        chatsSubscription?.cancel();
        userChatsSubscription?.cancel();
        debugPrint('Stop listening to chats');
      },
    );
    return controller.stream;
  }

  @override
  Future<PersonalChatModel> getOrCreateChatByUser(ChatUserModel user) async {
    var currentUser = await _userService.getCurrentUser();
    var collection = await _db
        .collection(_options.usersCollectionName)
        .doc(currentUser?.id)
        .collection('chats')
        .where('users', arrayContains: user.id)
        .get();

    var doc = collection.docs.isNotEmpty ? collection.docs.first : null;

    return PersonalChatModel(
      id: doc?.id,
      user: user,
    );
  }

  @override
  Future<void> deleteChat(ChatModel chat) async {
    var chatCollection = await _db
        .collection(_options.chatsCollectionName)
        .doc(chat.id)
        .withConverter(
          fromFirestore: (snapshot, _) =>
              FirebaseChatDocument.fromJson(snapshot.data()!, snapshot.id),
          toFirestore: (chat, _) => chat.toJson(),
        )
        .get();

    var chatData = chatCollection.data();

    if (chatData != null) {
      for (var userId in chatData.users) {
        _db
            .collection(_options.usersCollectionName)
            .doc(userId)
            .collection('chats')
            .doc(chat.id)
            .delete();
      }

      if (chat.id != null) {
        await _db
            .collection(_options.chatsCollectionName)
            .doc(chat.id)
            .delete();
        await _storage
            .ref(_options.chatsCollectionName)
            .child(chat.id!)
            .listAll()
            .then((value) {
          for (var element in value.items) {
            element.delete();
          }
        });
      }
    }
  }

  @override
  Future<PersonalChatModel> storeChatIfNot(PersonalChatModel chat) async {
    if (chat.id == null) {
      var currentUser = await _userService.getCurrentUser();

      if (currentUser?.id == null || chat.user.id == null) {
        return chat;
      }

      List<String> userIds = [
        currentUser!.id!,
        chat.user.id!,
      ];

      var reference = await _db
          .collection(_options.chatsCollectionName)
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
        await _db
            .collection(_options.usersCollectionName)
            .doc(userId)
            .collection('chats')
            .doc(reference.id)
            .set({'users': userIds});
      }

      chat.id = reference.id;
    }

    return chat;
  }
}
