// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_community_chat_firebase/config/firebase_chat_options.dart';
import 'package:flutter_community_chat_firebase/dto/firebase_chat_document.dart';
import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';

class FirebaseChatService implements ChatService {
  late FirebaseFirestore _db;
  late FirebaseStorage _storage;
  late ChatUserService _userService;
  late FirebaseChatOptions _options;
  DocumentSnapshot<Object?>? lastUserDocument;
  String? lastGroupId;
  List<String> chatIds = [];
  int pageNumber = 1;

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

  StreamSubscription<DocumentSnapshot> _addUnreadChatSubscription(
    String chatId,
    String userId,
    Function(int) onUnreadChatsUpdated,
  ) {
    var snapshots = _db
        .collection(_options.usersCollectionName)
        .doc(userId)
        .collection(_options.userChatsCollectionName)
        .doc(chatId)
        .snapshots();

    return snapshots.listen((snapshot) {
      var data = snapshot.data();
      onUnreadChatsUpdated(data?['amount_unread_messages'] ?? 0);
    });
  }

  StreamSubscription<QuerySnapshot> _addChatSubscription(
    List<String> chatIds,
    Function(List<ChatModel>) onReceivedChats,
  ) {
    var snapshots = _db
        .collection(_options.chatsMetaDataCollectionName)
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
      var chats = <ChatModel>[];

      for (var chatDoc in snapshot.docs) {
        var chatData = chatDoc.data();

        var messages = <ChatMessageModel>[];

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
        ChatModel? chatModel;

        if (chatData.personal) {
          var otherUserId = List<String>.from(chatData.users).firstWhere(
            (element) => element != currentUser?.id,
          );
          var otherUser = await _userService.getUser(otherUserId);

          if (otherUser != null) {
            chatModel = PersonalChatModel(
              id: chatDoc.id,
              user: otherUser,
              lastMessage: messages.isNotEmpty ? messages.last : null,
              messages: messages,
              canBeDeleted: chatData.canBeDeleted,
              lastUsed: chatData.lastUsed == null
                  ? null
                  : DateTime.fromMillisecondsSinceEpoch(
                      chatData.lastUsed!.millisecondsSinceEpoch,
                    ),
            );
          }
        } else {
          // group chat
          var users = <ChatUserModel>[];
          for (var userId in chatData.users) {
            var user = await _userService.getUser(userId);
            if (user != null) {
              users.add(user);
            }
          }
          chatModel = GroupChatModel(
            id: chatDoc.id,
            title: chatData.title ?? '',
            imageUrl: chatData.imageUrl ?? '',
            lastMessage: messages.isNotEmpty ? messages.last : null,
            messages: messages,
            users: users,
            canBeDeleted: chatData.canBeDeleted,
            lastUsed: chatData.lastUsed == null
                ? null
                : DateTime.fromMillisecondsSinceEpoch(
                    chatData.lastUsed!.millisecondsSinceEpoch,
                  ),
          );
        }
        if (chatModel != null) {
          _addUnreadChatSubscription(chatModel.id ?? '', currentUser?.id ?? '',
              (unreadMessages) {
            // the chatmodel should be updated to reflect the amount of unread messages
            if (chatModel is PersonalChatModel) {
              chatModel = (chatModel as PersonalChatModel)
                  .copyWith(unreadMessages: unreadMessages);
            } else if (chatModel is GroupChatModel) {
              chatModel = (chatModel as GroupChatModel)
                  .copyWith(unreadMessages: unreadMessages);
            }

            chats = chats
                .map((chat) => chat.id == chatModel?.id ? chatModel! : chat)
                .toList();
            onReceivedChats(chats);
          });
          chats.add(chatModel!);
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

                var mergedChats = <ChatModel>[];

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
  Stream<List<ChatModel>> getChatsStream(int pageSize) {
    late StreamController<List<ChatModel>> controller;
    StreamSubscription? chatsSubscription;
    controller = StreamController(
      onListen: () async {
        QuerySnapshot<Map<String, dynamic>> userSnapshot;
        List<String> userChatIds;
        var currentUser = await _userService.getCurrentUser();

        var userQuery = _db
            .collection(_options.usersCollectionName)
            .doc(currentUser?.id)
            .collection(_options.userChatsCollectionName);
        if (lastUserDocument == null) {
          userSnapshot = await userQuery.limit(pageSize).get();
          userChatIds = userSnapshot.docs.map((chat) => chat.id).toList();
        } else {
          userSnapshot = await userQuery
              .limit(pageSize)
              .startAfterDocument(lastUserDocument!)
              .get();
          userChatIds = userSnapshot.docs.map((chat) => chat.id).toList();
        }

        var userGroupChatIds = await _db
            .collection(_options.usersCollectionName)
            .doc(currentUser?.id)
            .get()
            .then((userCollection) =>
                userCollection.data()?[_options.groupChatsCollectionName])
            .then((groupChatLabels) => groupChatLabels?.cast<String>())
            .then((groupChatIds) {
          var startIndex = (pageNumber - 1) * pageSize;
          var endIndex = startIndex + pageSize;

          if (groupChatIds != null) {
            if (startIndex >= groupChatIds.length) {
              return [];
            }
            var groupIds = groupChatIds.sublist(
                startIndex, endIndex.clamp(0, groupChatIds.length));
            lastGroupId = groupIds.last;
            return groupIds;
          }
          return [];
        });

        if (userSnapshot.docs.isNotEmpty) {
          lastUserDocument = userSnapshot.docs.last;
        }

        pageNumber++;
        chatIds.addAll([...userChatIds, ...userGroupChatIds]);
        var chatsStream = _getSpecificChatsStream(chatIds);

        chatsSubscription = chatsStream.listen((event) {
          controller.add(event);
        });
      },
      onCancel: () {
        chatsSubscription?.cancel();
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
          .collection(_options.chatsCollectionName)
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
        _db
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
              .set({'users': userIds});
        }

        chat.id = reference.id;
        chatIds.add(chat.id!);
      } else if (chat is GroupChatModel) {
        if (currentUser?.id == null) {
          return chat;
        }

        List<String> userIds = [
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
              .set({'users': userIds});
        }

        chat.id = reference.id;
        chatIds.add(chat.id!);
      } else {
        throw Exception('Chat type not supported for firebase');
      }
    }

    return chat;
  }

  @override
  Stream<int> getUnreadChatsCountStream() {
    // open a stream to the user's chats collection and listen to changes in this collection we will also add the amount of read chats
    StreamSubscription? unreadChatSubscription;
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
          // every chat has a field called amount_unread_messages, combine all of these fields to get the total amount of unread messages
          var unreadChats = event.docs
              .map((chat) => chat.data()['amount_unread_messages'] ?? 0)
              .toList();
          var totalUnreadChats = unreadChats.fold<int>(
              0, (previousValue, element) => previousValue + (element as int));
          controller.add(totalUnreadChats);
        });
      },
      onCancel: () {
        unreadChatSubscription?.cancel();
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
        .doc(currentUser!.id!)
        .collection(_options.userChatsCollectionName)
        .doc(chat.id)
        .set({'amount_unread_messages': 0}, SetOptions(merge: true));
  }
}
