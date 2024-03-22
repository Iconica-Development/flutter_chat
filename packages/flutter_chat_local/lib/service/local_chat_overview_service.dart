import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_chat_interface/flutter_chat_interface.dart';

class LocalChatOverviewService
    with ChangeNotifier
    implements ChatOverviewService {
  final List<ChatModel> _chats = [];
  List<ChatModel> get chats => _chats;

  final StreamController<List<ChatModel>> _chatsController =
      StreamController<List<ChatModel>>.broadcast();

  Future<void> updateChat(ChatModel chat) {
    var index = _chats.indexWhere((element) => element.id == chat.id);
    _chats[index] = chat;
    _chatsController.addStream(Stream.value(_chats));
    notifyListeners();
    debugPrint('Chat updated: $chat');
    return Future.value();
  }

  @override
  Future<void> deleteChat(ChatModel chat) {
    _chats.removeWhere((element) => element.id == chat.id);
    _chatsController.add(_chats);
    notifyListeners();
    debugPrint('Chat deleted: $chat');
    return Future.value();
  }

  @override
  Future<ChatModel> getChatById(String id) {
    var chat = _chats.firstWhere((element) => element.id == id);
    debugPrint('Retrieved chat by ID: $chat');
    debugPrint('Messages are: ${chat.messages?.length}');
    return Future.value(chat);
  }

  @override
  Future<PersonalChatModel> getChatByUser(ChatUserModel user) async {
    PersonalChatModel? chat;
    try {
      chat = _chats
          .whereType<PersonalChatModel>()
          .firstWhere((element) => element.user.id == user.id);
      // ignore: avoid_catching_errors
    } on StateError {
      chat = PersonalChatModel(
        user: user,
        messages: [],
        id: '',
      );
      chat.id = chat.hashCode.toString();
      _chats.add(chat);
      debugPrint('New chat created: $chat');
    }

    _chatsController.add([..._chats]);
    notifyListeners();
    return chat;
  }

  @override
  Stream<List<ChatModel>> getChatsStream() => _chatsController.stream;

  @override
  Stream<int> getUnreadChatsCountStream() => Stream.value(0);

  @override
  Future<void> readChat(ChatModel chat) async => Future.value();

  @override
  Future<ChatModel> storeChatIfNot(ChatModel chat) {
    var chatExists = _chats.any((element) => element.id == chat.id);

    if (!chatExists) {
      _chats.add(chat);
      _chatsController.add([..._chats]);
      notifyListeners();
      debugPrint('Chat stored: $chat');
    } else {
      debugPrint('Chat already exists: $chat');
    }

    return Future.value(chat);
  }
}
