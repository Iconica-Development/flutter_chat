import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_chat_interface/flutter_chat_interface.dart';
import 'package:flutter_chat_local/local_chat_service.dart';

class LocalChatDetailService with ChangeNotifier implements ChatDetailService {
  final ChatOverviewService chatOverviewService;

  LocalChatDetailService({required this.chatOverviewService});
  final List<ChatMessageModel> _cumulativeMessages = [];
  final StreamController<List<ChatMessageModel>> _controller =
      StreamController<List<ChatMessageModel>>.broadcast();
  late StreamSubscription? _subscription;

  @override
  Future<void> fetchMoreMessage(int pageSize, String chatId) async {
    await chatOverviewService.getChatById(chatId).then((value) {
      _cumulativeMessages.clear();
      _cumulativeMessages.addAll(value.messages!);
      _controller.add(_cumulativeMessages);
    });
    notifyListeners();
    return Future.value();
  }

  @override
  List<ChatMessageModel> getMessages() {
    return _cumulativeMessages;
  }

  @override
  Stream<List<ChatMessageModel>> getMessagesStream(String chatId) {
    _controller.onListen = () {
      _subscription =
          chatOverviewService.getChatById(chatId).asStream().listen((event) {
        _cumulativeMessages.clear();
        _cumulativeMessages.addAll(event.messages!);
        _controller.add(_cumulativeMessages);
      });
    };

    return _controller.stream;
  }

  @override
  Future<void> sendImageMessage(
      {required String chatId, required Uint8List image}) async {
    var chat = (chatOverviewService as LocalChatOverviewService)
        .chats
        .firstWhere((element) => element.id == chatId);
    var message = ChatImageMessageModel(
      sender: ChatUserModel(
        id: "3",
        firstName: "ico",
        lastName: "nica",
        imageUrl: "https://picsum.photos/100/200",
      ),
      timestamp: DateTime.now(),
      imageUrl: "https://picsum.photos/200/300",
    );

    await (chatOverviewService as LocalChatOverviewService).updateChat(
      chat.copyWith(
        messages: [...chat.messages!, message],
        lastMessage: message,
        lastUsed: DateTime.now(),
      ),
    );
    chat.messages?.add(message);
    _cumulativeMessages.add(message);
    notifyListeners();

    return Future.value();
  }

  @override
  Future<void> sendTextMessage(
      {required String chatId, required String text}) async {
    var chat = (chatOverviewService as LocalChatOverviewService)
        .chats
        .firstWhere((element) => element.id == chatId);
    var message = ChatTextMessageModel(
      sender: ChatUserModel(
        id: "3",
        firstName: "ico",
        lastName: "nica",
        imageUrl: "https://picsum.photos/100/200",
      ),
      timestamp: DateTime.now(),
      text: text,
    );
    await (chatOverviewService as LocalChatOverviewService).updateChat(
      chat.copyWith(
        messages: [...chat.messages!, message],
        lastMessage: message,
        lastUsed: DateTime.now(),
      ),
    );

    chat.messages?.add(message);
    _cumulativeMessages.add(message);
    notifyListeners();

    return Future.value();
  }

  @override
  void stopListeningForMessages() {
    _subscription?.cancel();
    _subscription = null;
  }
}
