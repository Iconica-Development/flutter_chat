// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_community_chat_firebase/config/firebase_chat_options.dart';
import 'package:flutter_community_chat_firebase/dto/firebase_chat_document.dart';
import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';

import 'firebase_user_service.dart';

class FirebaseChatService {
  FirebaseChatService({
    required this.db,
    required this.userService,
    required this.options,
  });

  FirebaseFirestore db;
  FirebaseUserService userService;
  FirebaseChatOptoons options;

  StreamSubscription<QuerySnapshot> _addChatSubscription(
    List<String> chatIds,
    Function(List<ChatModel>) onReceivedChats,
  ) {
    var snapshots = db
        .collection(options.chatsCollectionName)
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
      var currentUser = await userService.getCurrentUser();
      List<ChatModel> chats = [];

      for (var chatDoc in snapshot.docs) {
        var chatData = chatDoc.data();

        List<ChatMessageModel> messages = [];

        if (chatData.lastMessage != null) {
          var messageData = chatData.lastMessage!;
          var sender = await userService.getUser(messageData.sender);

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
        var otherUser = await userService.getUser(otherUserId);

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

  Stream<List<ChatModel>> _getSpecificChatsStream(List<String> chatIds) {
    late StreamController<List<ChatModel>> controller;
    List<StreamSubscription<QuerySnapshot>> subscriptions = [];
    var splittedChatIds = _splitChatIds(chatIds: chatIds);

    controller = StreamController<List<ChatModel>>(
      onListen: () {
        var chats = <int, List<ChatModel>>{};

        for (var chatIdPair in splittedChatIds.asMap().entries) {
          subscriptions.add(
            _addChatSubscription(
              chatIdPair.value,
              (data) {
                chats[chatIdPair.key] = data;

                List<ChatModel> mergedChats = [];

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

  Stream<List<ChatModel>> getChatsStream() {
    late StreamController<List<ChatModel>> controller;
    StreamSubscription? userChatsSubscription;
    StreamSubscription? chatsSubscription;
    controller = StreamController(
      onListen: () async {
        var currentUser = await userService.getCurrentUser();
        userChatsSubscription = db
            .collection(options.usersCollectionName)
            .doc(currentUser?.id)
            .collection('chats')
            .snapshots()
            .listen((snapshot) {
          List<String> chatIds = [];

          for (var chatDoc in snapshot.docs) {
            var chatData = chatDoc.data();

            if (chatData['id'] != null) {
              chatIds.add(chatData['id']);
            }
          }

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
      },
    );
    return controller.stream;
  }

  Future<ChatModel?> getChatByUser(ChatUserModel user) async {
    var currentUser = await userService.getCurrentUser();
    var chatCollection = await db
        .collection(options.usersCollectionName)
        .doc(currentUser?.id)
        .collection('chats')
        .get();

    for (var element in chatCollection.docs) {
      var data = element.data();
      if (data.containsKey('id') &&
          data.containsKey('users') &&
          data['users'] is List) {
        if (data['users'].contains(user.id)) {
          return PersonalChatModel(
            id: data['id'],
            user: user,
          );
        }
      }
    }

    return null;
  }
}
