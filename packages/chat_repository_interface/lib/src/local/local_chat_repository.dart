import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:chat_repository_interface/chat_repository_interface.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

class LocalChatRepository implements ChatRepositoryInterface {
  LocalChatRepository() {
    var messages = <MessageModel>[];

    for (var i = 0; i < 50; i++) {
      var rnd = Random().nextInt(2);

      messages.add(MessageModel(
        id: i.toString(),
        text: 'Message $i',
        senderId: rnd == 0 ? '1' : '2',
        timestamp: DateTime.now().add(Duration(seconds: i)),
        imageUrl: null,
      ));
    }

    _chats = [
      ChatModel(
        id: '1',
        users: [UserModel(id: '1'), UserModel(id: '2')],
        messages: messages,
        lastMessage: messages.last,
        unreadMessageCount: 50,
      ),
    ];
  }

  StreamController<List<ChatModel>> chatsController =
      BehaviorSubject<List<ChatModel>>();

  StreamController<ChatModel> chatController = BehaviorSubject<ChatModel>();

  StreamController<List<MessageModel>> messageController =
      BehaviorSubject<List<MessageModel>>();

  List<ChatModel> _chats = [];

  @override
  String createChat(
      {required List<UserModel> users,
      String? chatName,
      String? description,
      String? imageUrl,
      List<MessageModel>? messages}) {
    var chat = ChatModel(
      id: DateTime.now().toString(),
      users: users,
      messages: messages ?? [],
      chatName: chatName,
      description: description,
      imageUrl: imageUrl,
    );

    _chats.add(chat);
    chatsController.add(_chats);

    return chat.id;
  }

  @override
  Stream<ChatModel> updateChat({required ChatModel chat}) {
    var index = _chats.indexWhere((e) => e.id == chat.id);

    if (index != -1) {
      _chats[index] = chat;
      chatsController.add(_chats);
    }

    return chatController.stream.where((e) => e.id == chat.id);
  }

  @override
  bool deleteChat({required String chatId}) {
    try {
      _chats.removeWhere((e) => e.id == chatId);
      chatsController.add(_chats);

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<ChatModel> getChat({required String chatId}) {
    var chat = _chats.firstWhereOrNull((e) => e.id == chatId);

    if (chat != null) {
      chatController.add(chat);

      if (chat.imageUrl != null && chat.imageUrl!.isNotEmpty) {
        chat.copyWith(imageUrl: 'https://picsum.photos/200/300');
      }
    }

    return chatController.stream;
  }

  @override
  Stream<List<ChatModel>?> getChats({required String userId}) {
    chatsController.add(_chats);

    return chatsController.stream;
  }

  @override
  Stream<List<MessageModel>?> getMessages({
    required String chatId,
    required String userId,
    required int pageSize,
    required int page,
  }) {
    ChatModel? chat;

    chat = _chats.firstWhereOrNull((e) => e.id == chatId);

    if (chat != null) {
      var messages = List<MessageModel>.from(chat.messages);

      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      messageController.stream.first
          .timeout(
        const Duration(seconds: 1),
      )
          .then((oldMessages) {
        var newMessages = messages.reversed
            .skip(page * pageSize)
            .take(pageSize)
            .toList(growable: false)
            .reversed
            .toList();

        if (newMessages.isEmpty) return;

        var allMessages = [...oldMessages, ...newMessages];

        allMessages = allMessages
            .toSet()
            .toList()
            .cast<MessageModel>()
            .toList(growable: false);

        allMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        messageController.add(allMessages);
      }).onError((error, stackTrace) {
        messageController.add(messages.reversed
            .skip(page * pageSize)
            .take(pageSize)
            .toList(growable: false)
            .reversed
            .toList());
      });
    }

    return messageController.stream;
  }

  @override
  bool sendMessage(
      {required String chatId,
      required String senderId,
      String? text,
      String? imageUrl}) {
    var message = MessageModel(
      id: DateTime.now().toString(),
      timestamp: DateTime.now(),
      text: text,
      senderId: senderId,
      imageUrl: imageUrl,
    );

    var chat = _chats.firstWhereOrNull((e) => e.id == chatId);

    if (chat == null) return false;

    chat.messages.add(message);
    messageController.add(chat.messages);

    return true;
  }

  @override
  Stream<int> getUnreadMessagesCount({required String userId, String? chatId}) {
    return chatsController.stream.map((chats) {
      var count = 0;

      for (var chat in chats) {
        if (chat.users.any((e) => e.id == userId)) {
          count += chat.unreadMessageCount;
        }
      }

      return count;
    });
  }

  @override
  Future<String> uploadImage({
    required String path,
    required Uint8List image,
  }) {
    return Future.value('https://picsum.photos/200/300');
  }
}
