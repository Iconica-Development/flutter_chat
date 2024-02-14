// ignore_for_file: public_member_api_docs, sort_constructors_first
// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chat_firebase/config/firebase_chat_options.dart';
import 'package:flutter_chat_firebase/dto/firebase_chat_document.dart';
import 'package:flutter_chat_interface/flutter_chat_interface.dart';

class FirebaseChatOverviewService implements ChatOverviewService {
  late FirebaseFirestore _db;
  late FirebaseStorage _storage;
  late ChatUserService _userService;
  late FirebaseChatOptions _options;

  FirebaseChatOverviewService({
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

  Future<int?> _addUnreadChatSubscription(
    String chatId,
    String userId,
  ) async {
    var snapshots = await _db
        .collection(_options.usersCollectionName)
        .doc(userId)
        .collection(_options.userChatsCollectionName)
        .doc(chatId)
        .get();

    return snapshots.data()?['amount_unread_messages'];
  }

  @override
  Stream<List<ChatModel>> getChatsStream() {
    StreamSubscription? chatSubscription;
    // ignore: close_sinks
    late StreamController<List<ChatModel>> controller;
    controller = StreamController(
      onListen: () async {
        var currentUser = await _userService.getCurrentUser();
        var userSnapshot = _db
            .collection(_options.usersCollectionName)
            .doc(currentUser?.id)
            .collection(_options.userChatsCollectionName)
            .snapshots();

        userSnapshot.listen((event) {
          var chatIds = event.docs.map((e) => e.id).toList();
          var chatSnapshot = _db
              .collection(_options.chatsMetaDataCollectionName)
              .where(
                FieldPath.documentId,
                whereIn: chatIds,
              )
              .withConverter(
                fromFirestore: (snapshot, _) => FirebaseChatDocument.fromJson(
                  snapshot.data()!,
                  snapshot.id,
                ),
                toFirestore: (chat, _) => chat.toJson(),
              )
              .snapshots();
          var chats = <ChatModel>[];
          ChatModel? chatModel;

          chatSubscription = chatSnapshot.listen((event) async {
            for (var element in event.docChanges) {
              var chat = element.doc.data();
              if (chat == null) return;
              var otherUser = await _userService.getUser(
                chat.users.firstWhere(
                  (element) => element != currentUser?.id,
                ),
              );
              var unread =
                  await _addUnreadChatSubscription(chat.id!, currentUser!.id!);

              if (chat.personal) {
                chatModel = PersonalChatModel(
                  id: chat.id,
                  user: otherUser!,
                  unreadMessages: unread,
                  lastUsed: chat.lastUsed == null
                      ? null
                      : DateTime.fromMillisecondsSinceEpoch(
                          chat.lastUsed!.millisecondsSinceEpoch,
                        ),
                  lastMessage: chat.lastMessage != null &&
                          chat.lastMessage!.imageUrl != null
                      ? ChatImageMessageModel(
                          sender: otherUser,
                          imageUrl: chat.lastMessage!.imageUrl!,
                          timestamp: DateTime.fromMillisecondsSinceEpoch(
                            chat.lastMessage!.timestamp.millisecondsSinceEpoch,
                          ),
                        )
                      : chat.lastMessage != null
                          ? ChatTextMessageModel(
                              sender: otherUser,
                              text: chat.lastMessage!.text!,
                              timestamp: DateTime.fromMillisecondsSinceEpoch(
                                chat.lastMessage!.timestamp
                                    .millisecondsSinceEpoch,
                              ),
                            )
                          : null,
                );
              } else {
                var users = <ChatUserModel>[];
                for (var userId in chat.users) {
                  var user = await _userService.getUser(userId);
                  if (user != null) {
                    users.add(user);
                  }
                }
                chatModel = GroupChatModel(
                  id: chat.id,
                  title: chat.title ?? '',
                  imageUrl: chat.imageUrl ?? '',
                  unreadMessages: unread,
                  users: users,
                  lastMessage: chat.lastMessage != null &&
                          chat.lastMessage!.imageUrl == null
                      ? ChatTextMessageModel(
                          sender: otherUser!,
                          text: chat.lastMessage!.text!,
                          timestamp: DateTime.fromMillisecondsSinceEpoch(
                            chat.lastMessage!.timestamp.millisecondsSinceEpoch,
                          ),
                        )
                      : ChatImageMessageModel(
                          sender: otherUser!,
                          imageUrl: chat.lastMessage!.imageUrl!,
                          timestamp: DateTime.fromMillisecondsSinceEpoch(
                            chat.lastMessage!.timestamp.millisecondsSinceEpoch,
                          ),
                        ),
                  canBeDeleted: chat.canBeDeleted,
                  lastUsed: chat.lastUsed == null
                      ? null
                      : DateTime.fromMillisecondsSinceEpoch(
                          chat.lastUsed!.millisecondsSinceEpoch,
                        ),
                );
              }
              chats.add(chatModel!);
            }
            var uniqueIds = <String>{};
            var uniqueChatModels = <ChatModel>[];

            for (var chatModel in chats) {
              if (uniqueIds.add(chatModel.id!)) {
                uniqueChatModels.add(chatModel);
              } else {
                var index = uniqueChatModels.indexWhere(
                  (element) => element.id == chatModel.id,
                );
                if (index != -1) {
                  if (chatModel.lastUsed != null &&
                      uniqueChatModels[index].lastUsed != null) {
                    if (chatModel.lastUsed!
                        .isAfter(uniqueChatModels[index].lastUsed!)) {
                      uniqueChatModels[index] = chatModel;
                    }
                  }
                }
              }
            }

            uniqueChatModels.sort(
              (a, b) => (b.lastUsed ?? DateTime.now()).compareTo(
                a.lastUsed ?? DateTime.now(),
              ),
            );

            controller.add(uniqueChatModels);
          });
        });
      },
      onCancel: () async {
        await chatSubscription?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<ChatModel> getChatByUser(ChatUserModel user) async {
    var currentUser = await _userService.getCurrentUser();
    var collection = await _db
        .collection(_options.usersCollectionName)
        .doc(currentUser?.id)
        .collection(_options.userChatsCollectionName)
        .where('users', arrayContains: user.id)
        .get();

    var doc = collection.docs.isNotEmpty ? collection.docs.first : null;

    return PersonalChatModel(
      id: doc?.id,
      user: user,
    );
  }

  @override
  Future<ChatModel> getChatById(String chatId) async {
    var currentUser = await _userService.getCurrentUser();
    var chatCollection = await _db
        .collection(_options.usersCollectionName)
        .doc(currentUser?.id)
        .collection(_options.userChatsCollectionName)
        .doc(chatId)
        .get();

    if (chatCollection.exists && chatCollection.data()?['users'] != null) {
      // ignore: avoid_dynamic_calls
      var otherUser = chatCollection.data()?['users'].firstWhere(
            (element) => element != currentUser?.id,
          );
      var user = await _userService.getUser(otherUser);
      return PersonalChatModel(
        id: chatId,
        user: user!,
        canBeDeleted: chatCollection.data()?['can_be_deleted'] ?? true,
      );
    } else {
      var groupChatCollection = await _db
          .collection(_options.chatsMetaDataCollectionName)
          .doc(chatId)
          .withConverter(
            fromFirestore: (snapshot, _) =>
                FirebaseChatDocument.fromJson(snapshot.data()!, snapshot.id),
            toFirestore: (chat, _) => chat.toJson(),
          )
          .get();
      var chat = groupChatCollection.data();
      var users = <ChatUserModel>[];
      for (var userId in chat?.users ?? []) {
        var user = await _userService.getUser(userId);
        if (user != null) {
          users.add(user);
        }
      }
      return GroupChatModel(
        id: chat?.id ?? chatId,
        title: chat?.title ?? '',
        imageUrl: chat?.imageUrl ?? '',
        users: users,
        canBeDeleted: chat?.canBeDeleted ?? true,
      );
    }
  }

  @override
  Future<void> deleteChat(ChatModel chat) async {
    var chatCollection = await _db
        .collection(_options.chatsMetaDataCollectionName)
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
        await _db
            .collection(_options.usersCollectionName)
            .doc(userId)
            .collection(_options.userChatsCollectionName)
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
  Future<ChatModel> storeChatIfNot(ChatModel chat) async {
    if (chat.id == null) {
      var currentUser = await _userService.getCurrentUser();
      if (chat is PersonalChatModel) {
        if (currentUser?.id == null || chat.user.id == null) {
          return chat;
        }

        var userIds = <String>[
          currentUser!.id!,
          chat.user.id!,
        ];

        var reference = await _db
            .collection(_options.chatsMetaDataCollectionName)
            .withConverter(
              fromFirestore: (snapshot, _) =>
                  FirebaseChatDocument.fromJson(snapshot.data()!, snapshot.id),
              toFirestore: (chat, _) => chat.toJson(),
            )
            .add(
              FirebaseChatDocument(
                personal: true,
                canBeDeleted: chat.canBeDeleted,
                users: userIds,
                lastUsed: Timestamp.now(),
              ),
            );

        for (var userId in userIds) {
          await _db
              .collection(_options.usersCollectionName)
              .doc(userId)
              .collection(_options.userChatsCollectionName)
              .doc(reference.id)
              .set({'users': userIds}, SetOptions(merge: true));
        }

        chat.id = reference.id;
      } else if (chat is GroupChatModel) {
        if (currentUser?.id == null) {
          return chat;
        }

        var userIds = <String>[
          currentUser!.id!,
          ...chat.users.map((e) => e.id!),
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
                personal: false,
                canBeDeleted: chat.canBeDeleted,
                users: userIds,
                lastUsed: Timestamp.now(),
              ),
            );

        for (var userId in userIds) {
          await _db
              .collection(_options.usersCollectionName)
              .doc(userId)
              .collection(_options.groupChatsCollectionName)
              .doc(reference.id)
              .set({'users': userIds}, SetOptions(merge: true));
        }

        chat.id = reference.id;
      } else {
        throw Exception('Chat type not supported for firebase');
      }
    }

    return chat;
  }

  @override
  Stream<int> getUnreadChatsCountStream() {
    // open a stream to the user's chats collection and listen to changes in
    // this collection we will also add the amount of read chats
    StreamSubscription? unreadChatSubscription;
    // ignore: close_sinks
    late StreamController<int> controller;
    controller = StreamController(
      onListen: () async {
        var currentUser = await _userService.getCurrentUser();
        var userSnapshot = _db
            .collection(_options.usersCollectionName)
            .doc(currentUser?.id)
            .collection(_options.userChatsCollectionName)
            .snapshots();

        unreadChatSubscription = userSnapshot.listen((event) {
          // every chat has a field called amount_unread_messages, combine all
          // of these fields to get the total amount of unread messages
          var unreadChats = event.docs
              .map((chat) => chat.data()['amount_unread_messages'] ?? 0)
              .toList();
          var totalUnreadChats = unreadChats.fold<int>(
            0,
            (previousValue, element) => previousValue + (element as int),
          );
          controller.add(totalUnreadChats);
        });
      },
      onCancel: () async {
        await unreadChatSubscription?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<void> readChat(ChatModel chat) async {
    // set the amount of read chats to the amount of messages in the chat
    var currentUser = await _userService.getCurrentUser();
    if (currentUser?.id == null || chat.id == null) {
      return;
    }
    // set the amount of unread messages to 0
    await _db
        .collection(_options.usersCollectionName)
        .doc(currentUser!.id)
        .collection(_options.userChatsCollectionName)
        .doc(chat.id)
        .set({'amount_unread_messages': 0}, SetOptions(merge: true));
  }
}
