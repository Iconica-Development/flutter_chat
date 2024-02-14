import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_chat_interface/flutter_chat_interface.dart';

class LocalChatOverviewService
    with ChangeNotifier
    implements ChatOverviewService {
  final List<PersonalChatModel> _chats = [];
  List<PersonalChatModel> get chats => _chats;

  final StreamController<List<ChatModel>> _chatsController =
      StreamController<List<ChatModel>>.broadcast();

  Future<void> updateChat(ChatModel chat) {
    var index = _chats.indexWhere((element) => element.id == chat.id);
    _chats[index] = chat as PersonalChatModel;
    _chatsController.addStream(Stream.value(_chats));
    notifyListeners();
    return Future.value();
  }

  @override
  Future<void> deleteChat(ChatModel chat) {
    _chats.removeWhere((element) => element.id == chat.id);
    _chatsController.add(_chats);
    notifyListeners();
    return Future.value();
  }

  @override
  Future<ChatModel> getChatById(String id) =>
      Future.value(_chats.firstWhere((element) => element.id == id));

  @override
  Future<ChatModel> getChatByUser(ChatUserModel user) {
    PersonalChatModel? chat;
    try {
      chat = _chats.firstWhere((element) => element.user.id == user.id);
    } on Exception catch (_) {
      chat = PersonalChatModel(
        user: user,
        messages: [],
        id: '',
      );
      chat.id = chat.hashCode.toString();
      _chats.add(chat);
    }

    _chatsController.add([..._chats]);
    notifyListeners();
    return Future.value(chat);
  }

  @override
  Stream<List<ChatModel>> getChatsStream() => _chatsController.stream;

  @override
  Stream<int> getUnreadChatsCountStream() => Stream.value(0);

  @override
  Future<void> readChat(ChatModel chat) async => Future.value();

  @override
  Future<ChatModel> storeChatIfNot(ChatModel chat) => Future.value(chat);
}
