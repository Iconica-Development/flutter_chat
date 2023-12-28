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

class FirebaseMessageService with ChangeNotifier implements MessageService {
  late final FirebaseFirestore _db;
  late final FirebaseStorage _storage;
  late final ChatUserService _userService;
  late FirebaseChatOptions _options;

  StreamController<List<ChatMessageModel>>? _controller;
  StreamSubscription<QuerySnapshot>? _subscription;
  DocumentSnapshot<Object>? lastMessage;
  List<ChatMessageModel> _cumulativeMessages = [];
  ChatModel? lastChat;
  int? chatPageSize;
  DateTime timestampToFilter = DateTime.now();

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

    var newMessage = await chatReference
        .collection(
          _options.messagesCollectionName,
        )
        .add(message);

    if (_cumulativeMessages.length == 1) {
      lastMessage = await chatReference
          .collection(
            _options.messagesCollectionName,
          )
          .doc(newMessage.id)
          .get();
    }

    var metadataReference = _db
        .collection(
          _options.chatsMetaDataCollectionName,
        )
        .doc(chat.id);

    await metadataReference.update({
      'last_used': DateTime.now(),
      'last_message': message,
    });

    if (_controller != null) {
      if (chat.id != null &&
          _controller!.hasListener &&
          (_subscription == null)) {
        _subscription = _startListeningForMessages(chat);
      }
    }

    // update the chat counter for the other users
    // get all users from the chat
    // there is a field in the chat document called users that has a list of user ids
    var fetchedChat = await metadataReference.get();
    var chatUsers = fetchedChat.data()?['users'] as List<dynamic>;
    // for all users except the message sender update the unread counter
    for (var userId in chatUsers) {
      if (userId != currentUser.id) {
        var userReference = _db
            .collection(
              _options.usersCollectionName,
            )
            .doc(userId)
            .collection(_options.userChatsCollectionName)
            .doc(chat.id);
        // what if the amount_unread_messages field does not exist?
        // it should be created when the chat is create
        if ((await userReference.get())
                .data()
                ?.containsKey('amount_unread_messages') ??
            false) {
          await userReference.update({
            'amount_unread_messages': FieldValue.increment(1),
          });
        } else {
          await userReference.set({
            'amount_unread_messages': 1,
          });
        }
      }
    }
  }

  @override
  Future<void> sendTextMessage({
    required String text,
    required ChatModel chat,
  }) {
    return _sendMessage(
      chat,
      {
        'text': text,
      },
    );
  }

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

  Query<FirebaseMessageDocument> _getMessagesQuery(ChatModel chat) {
    if (lastChat == null) {
      lastChat = chat;
    } else if (lastChat?.id != chat.id) {
      _cumulativeMessages = [];
      lastChat = chat;
      lastMessage = null;
    }

    var query = _db
        .collection(_options.chatsCollectionName)
        .doc(chat.id)
        .collection(_options.messagesCollectionName)
        .orderBy('timestamp', descending: true)
        .limit(chatPageSize!);

    if (lastMessage == null) {
      return query.withConverter<FirebaseMessageDocument>(
        fromFirestore: (snapshot, _) =>
            FirebaseMessageDocument.fromJson(snapshot.data()!, snapshot.id),
        toFirestore: (user, _) => user.toJson(),
      );
    }
    return query
        .startAfterDocument(lastMessage!)
        .withConverter<FirebaseMessageDocument>(
          fromFirestore: (snapshot, _) =>
              FirebaseMessageDocument.fromJson(snapshot.data()!, snapshot.id),
          toFirestore: (user, _) => user.toJson(),
        );
  }

  @override
  Stream<List<ChatMessageModel>> getMessagesStream(ChatModel chat) {
    _controller = StreamController<List<ChatMessageModel>>(
      onListen: () {
        var messagesCollection = _db
            .collection(_options.chatsCollectionName)
            .doc(chat.id)
            .collection(_options.messagesCollectionName)
            .withConverter<FirebaseMessageDocument>(
              fromFirestore: (snapshot, _) => FirebaseMessageDocument.fromJson(
                  snapshot.data()!, snapshot.id),
              toFirestore: (user, _) => user.toJson(),
            );
        var query = messagesCollection
            .where(
              'timestamp',
              isGreaterThan: timestampToFilter,
            )
            .withConverter<FirebaseMessageDocument>(
              fromFirestore: (snapshot, _) => FirebaseMessageDocument.fromJson(
                  snapshot.data()!, snapshot.id),
              toFirestore: (user, _) => user.toJson(),
            );

        var stream = query.snapshots();
        // Subscribe to the stream and process the updates
        _subscription = stream.listen((snapshot) async {
          var messages = <ChatMessageModel>[];

          for (var messageDoc in snapshot.docs) {
            var messageData = messageDoc.data();
            var timestamp = DateTime.fromMillisecondsSinceEpoch(
              (messageData.timestamp).millisecondsSinceEpoch,
            );

            // Check if the message is already in the list to avoid duplicates
            if (timestampToFilter.isBefore(timestamp)) {
              if (!messages.any((message) {
                var timestamp = DateTime.fromMillisecondsSinceEpoch(
                  (messageData.timestamp).millisecondsSinceEpoch,
                );
                return timestamp == message.timestamp;
              })) {
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
            }
          }

          // Add the filtered messages to the controller
          _controller?.add(messages);
          _cumulativeMessages = [
            ..._cumulativeMessages,
            ...messages,
          ];

          // remove all double elements
          List<ChatMessageModel> uniqueObjects =
              _cumulativeMessages.toSet().toList();
          _cumulativeMessages = uniqueObjects;
          _cumulativeMessages
              .sort((a, b) => a.timestamp.compareTo(b.timestamp));
          notifyListeners();
          timestampToFilter = DateTime.now();
        });
      },
      onCancel: () {
        _subscription?.cancel();
        _subscription = null;
        debugPrint('Canceling messages stream');
      },
    );
    return _controller!.stream;
  }

  StreamSubscription<QuerySnapshot> _startListeningForMessages(ChatModel chat) {
    debugPrint('Start listening for messages in chat ${chat.id}');
    var snapshots = _getMessagesQuery(chat).snapshots();
    return snapshots.listen(
      (snapshot) async {
        List<ChatMessageModel> messages =
            List<ChatMessageModel>.from(_cumulativeMessages);

        if (snapshot.docs.isNotEmpty) {
          lastMessage = snapshot.docs.last;

          for (var messageDoc in snapshot.docs) {
            var messageData = messageDoc.data();

            // Check if the message is already in the list to avoid duplicates
            if (!messages.any((message) {
              var timestamp = DateTime.fromMillisecondsSinceEpoch(
                (messageData.timestamp).millisecondsSinceEpoch,
              );
              return timestamp == message.timestamp;
            })) {
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
          }
        }

        _cumulativeMessages = messages;

        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        _controller?.add(messages);
        notifyListeners();
      },
    );
  }

  @override
  Future<void> fetchMoreMessage(int pageSize, ChatModel chat) async {
    if (lastChat == null) {
      lastChat = chat;
    } else if (lastChat?.id != chat.id) {
      _cumulativeMessages = [];
      lastChat = chat;
      lastMessage = null;
    }
    // get the x amount of last messages from the oldest message that is in cumulative messages and add that to the list
    List<ChatMessageModel> messages = [];
    QuerySnapshot<FirebaseMessageDocument>? messagesQuerySnapshot;
    var query = _db
        .collection(_options.chatsCollectionName)
        .doc(chat.id)
        .collection(_options.messagesCollectionName)
        .orderBy('timestamp', descending: true)
        .limit(pageSize);
    if (lastMessage == null) {
      messagesQuerySnapshot = await query
          .withConverter<FirebaseMessageDocument>(
            fromFirestore: (snapshot, _) =>
                FirebaseMessageDocument.fromJson(snapshot.data()!, snapshot.id),
            toFirestore: (user, _) => user.toJson(),
          )
          .get();
      if (messagesQuerySnapshot.docs.isNotEmpty) {
        lastMessage = messagesQuerySnapshot.docs.last;
      }
    } else {
      messagesQuerySnapshot = await query
          .startAfterDocument(lastMessage!)
          .withConverter<FirebaseMessageDocument>(
            fromFirestore: (snapshot, _) =>
                FirebaseMessageDocument.fromJson(snapshot.data()!, snapshot.id),
            toFirestore: (user, _) => user.toJson(),
          )
          .get();
      if (messagesQuerySnapshot.docs.isNotEmpty) {
        lastMessage = messagesQuerySnapshot.docs.last;
      }
    }

    List<FirebaseMessageDocument> messageDocuments = messagesQuerySnapshot.docs
        .map((QueryDocumentSnapshot<FirebaseMessageDocument> doc) => doc.data())
        .toList();

    for (var message in messageDocuments) {
      var sender = await _userService.getUser(message.sender);
      if (sender != null) {
        var timestamp = DateTime.fromMillisecondsSinceEpoch(
          (message.timestamp).millisecondsSinceEpoch,
        );

        messages.add(
          message.imageUrl != null
              ? ChatImageMessageModel(
                  sender: sender,
                  imageUrl: message.imageUrl!,
                  timestamp: timestamp,
                )
              : ChatTextMessageModel(
                  sender: sender,
                  text: message.text!,
                  timestamp: timestamp,
                ),
        );
      }
    }

    _cumulativeMessages = [
      ...messages,
      ..._cumulativeMessages,
    ];
    _cumulativeMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    notifyListeners();
  }

  @override
  List<ChatMessageModel> getMessages() {
    return _cumulativeMessages;
  }
}
