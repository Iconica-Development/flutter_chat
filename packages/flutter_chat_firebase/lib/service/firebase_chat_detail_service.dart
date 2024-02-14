// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_firebase/config/firebase_chat_options.dart';
import 'package:flutter_chat_firebase/dto/firebase_message_document.dart';
import 'package:flutter_chat_interface/flutter_chat_interface.dart';
import 'package:uuid/uuid.dart';

class FirebaseChatDetailService
    with ChangeNotifier
    implements ChatDetailService {
  FirebaseChatDetailService({
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
  late final FirebaseFirestore _db;
  late final FirebaseStorage _storage;
  late final ChatUserService _userService;
  late FirebaseChatOptions _options;

  StreamController<List<ChatMessageModel>>? _controller;
  StreamSubscription<QuerySnapshot>? _subscription;
  DocumentSnapshot<Object>? lastMessage;
  List<ChatMessageModel> _cumulativeMessages = [];
  String? lastChat;
  int? chatPageSize;
  DateTime timestampToFilter = DateTime.now();

  Future<void> _sendMessage(String chatId, Map<String, dynamic> data) async {
    var currentUser = await _userService.getCurrentUser();

    if (currentUser == null) {
      return;
    }

    var message = {
      'sender': currentUser.id,
      'timestamp': DateTime.now(),
      ...data,
    };

    var chatReference = _db
        .collection(
          _options.chatsCollectionName,
        )
        .doc(chatId);

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
        .doc(chatId);

    await metadataReference.update({
      'last_used': DateTime.now(),
      'last_message': message,
    });

    // update the chat counter for the other users
    // get all users from the chat
    // there is a field in the chat document called users that has a
    // list of user ids
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
            .doc(chatId);
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
          await userReference.set(
            {
              'amount_unread_messages': 1,
            },
            SetOptions(merge: true),
          );
        }
      }
    }
  }

  @override
  Future<void> sendTextMessage({
    required String text,
    required String chatId,
  }) =>
      _sendMessage(
        chatId,
        {
          'text': text,
        },
      );

  @override
  Future<void> sendImageMessage({
    required String chatId,
    required Uint8List image,
  }) async {
    var ref = _storage
        .ref('${_options.chatsCollectionName}/$chatId/${const Uuid().v4()}');

    return ref.putData(image).then(
          (_) => ref.getDownloadURL().then(
            (url) {
              _sendMessage(
                chatId,
                {
                  'image_url': url,
                },
              );
            },
          ),
        );
  }

  @override
  Stream<List<ChatMessageModel>> getMessagesStream(String chatId) {
    timestampToFilter = DateTime.now();
    var messages = <ChatMessageModel>[];
    _controller = StreamController<List<ChatMessageModel>>(
      onListen: () {
        var messagesCollection = _db
            .collection(_options.chatsCollectionName)
            .doc(chatId)
            .collection(_options.messagesCollectionName)
            .where(
              'timestamp',
              isGreaterThan: timestampToFilter,
            )
            .withConverter<FirebaseMessageDocument>(
              fromFirestore: (snapshot, _) => FirebaseMessageDocument.fromJson(
                snapshot.data()!,
                snapshot.id,
              ),
              toFirestore: (user, _) => user.toJson(),
            )
            .snapshots();

        _subscription = messagesCollection.listen((event) async {
          for (var message in event.docChanges) {
            var data = message.doc.data();
            var sender = await _userService.getUser(data!.sender);
            var timestamp = DateTime.fromMillisecondsSinceEpoch(
              data.timestamp.millisecondsSinceEpoch,
            );

            if (timestamp.isBefore(timestampToFilter)) {
              return;
            }
            messages.add(
              data.imageUrl != null
                  ? ChatImageMessageModel(
                      sender: sender!,
                      imageUrl: data.imageUrl!,
                      timestamp: timestamp,
                    )
                  : ChatTextMessageModel(
                      sender: sender!,
                      text: data.text!,
                      timestamp: timestamp,
                    ),
            );
            timestampToFilter = DateTime.now();
          }
          _cumulativeMessages = [
            ..._cumulativeMessages,
            ...messages,
          ];
          var uniqueObjects = _cumulativeMessages.toSet().toList();
          _cumulativeMessages = uniqueObjects;
          _cumulativeMessages
              .sort((a, b) => a.timestamp.compareTo(b.timestamp));
          notifyListeners();
        });
      },
      onCancel: () async {
        await _subscription?.cancel();
        _subscription = null;
        debugPrint('Canceling messages stream');
      },
    );

    return _controller!.stream;
  }

  @override
  Future<void> stopListeningForMessages() async {
    await _subscription?.cancel();
    _subscription = null;
    await _controller?.close();
    _controller = null;
  }

  @override
  Future<void> fetchMoreMessage(int pageSize, String chatId) async {
    if (lastChat == null) {
      lastChat = chatId;
    } else if (lastChat != chatId) {
      _cumulativeMessages = [];
      lastChat = chatId;
      lastMessage = null;
    }
    // get the x amount of last messages from the oldest message that is in
    // cumulative messages and add that to the list
    var messages = <ChatMessageModel>[];
    QuerySnapshot<FirebaseMessageDocument>? messagesQuerySnapshot;
    var query = _db
        .collection(_options.chatsCollectionName)
        .doc(chatId)
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

    var messageDocuments = messagesQuerySnapshot.docs
        .map((QueryDocumentSnapshot<FirebaseMessageDocument> doc) => doc.data())
        .toList();
    for (var message in messageDocuments) {
      var sender = await _userService.getUser(message.sender);
      if (sender != null) {
        var timestamp = DateTime.fromMillisecondsSinceEpoch(
          message.timestamp.millisecondsSinceEpoch,
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
  List<ChatMessageModel> getMessages() => _cumulativeMessages;
}
