import "dart:async";
import "dart:typed_data";

import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:collection/collection.dart";
import "package:rxdart/rxdart.dart";

/// The local chat repository
class LocalChatRepository implements ChatRepositoryInterface {
  /// The local chat repository constructor
  LocalChatRepository();

  final StreamController<List<ChatModel>> _chatsController =
      BehaviorSubject<List<ChatModel>>();

  final StreamController<ChatModel> _chatController =
      BehaviorSubject<ChatModel>();

  final StreamController<List<MessageModel>> _messageController =
      BehaviorSubject<List<MessageModel>>();

  final List<ChatModel> _chats = [];
  final Map<String, List<MessageModel>> _messages = {};

  @override
  Future<void> createChat({
    required List<String> users,
    required bool isGroupChat,
    String? chatName,
    String? description,
    String? imageUrl,
    List<MessageModel>? messages,
  }) async {
    var chat = ChatModel(
      id: DateTime.now().toString(),
      isGroupChat: isGroupChat,
      users: users,
      chatName: chatName,
      description: description,
      imageUrl: imageUrl,
    );

    _chats.add(chat);
    _chatsController.add(_chats);

    if (messages != null) {
      for (var message in messages) {
        await sendMessage(
          messageId: message.id,
          chatId: chat.id,
          senderId: message.senderId,
          text: message.text,
          messageType: message.messageType,
          imageUrl: message.imageUrl,
          timestamp: message.timestamp,
        );
      }
    }
  }

  @override
  Future<void> updateChat({
    required ChatModel chat,
  }) async {
    var index = _chats.indexWhere((e) => e.id == chat.id);

    if (index != -1) {
      _chats[index] = chat;
      _chatsController.add(_chats);
    }
  }

  @override
  Future<void> deleteChat({
    required String chatId,
  }) async {
    try {
      _chats.removeWhere((e) => e.id == chatId);
      _chatsController.add(_chats);
    } on Exception catch (_) {
      rethrow;
    }
  }

  @override
  Stream<ChatModel> getChat({
    required String chatId,
  }) {
    var chat = _chats.firstWhereOrNull((e) => e.id == chatId);

    if (chat != null) {
      _chatController.add(chat);

      if (chat.imageUrl?.isNotEmpty ?? false) {
        chat.copyWith(imageUrl: "https://picsum.photos/200/300");
      }
    }

    return _chatController.stream;
  }

  @override
  Stream<List<ChatModel>?> getChats({
    required String userId,
  }) {
    _chatsController.add(_chats);

    return _chatsController.stream;
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
      var messages = List<MessageModel>.from(_messages[chatId] ?? []);

      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      unawaited(
        _messageController.stream.first
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

          _messageController.add(allMessages);
        }).onError((error, stackTrace) {
          _messageController.add(
            messages.reversed
                .skip(page * pageSize)
                .take(pageSize)
                .toList(growable: false)
                .reversed
                .toList(),
          );
        }),
      );
    }

    return _messageController.stream;
  }

  @override
  Stream<MessageModel?> getMessage({
    required String chatId,
    required String messageId,
  }) {
    var message = _messages[chatId]?.firstWhereOrNull((e) => e.id == messageId);

    return Stream.value(message);
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String messageId,
    String? text,
    String? imageUrl,
    String? messageType,
    DateTime? timestamp,
  }) async {
    var message = MessageModel(
      chatId: chatId,
      id: messageId,
      timestamp: timestamp ?? DateTime.now(),
      text: text,
      messageType: messageType,
      senderId: senderId,
      imageUrl: imageUrl,
    );

    var chat = _chats.firstWhereOrNull((e) => e.id == chatId);

    if (chat == null) throw Exception("Chat not found");

    var messages = List<MessageModel>.from(_messages[chatId] ?? []);
    messages.add(message);
    _messages[chatId] = messages;

    var newChat = chat.copyWith(
      lastMessage: messageId,
      unreadMessageCount: chat.unreadMessageCount + 1,
      lastUsed: DateTime.now(),
    );

    _chats[_chats.indexWhere((e) => e.id == chatId)] = newChat;

    _chatsController.add(_chats);
    _messageController.add(_messages[chatId] ?? []);
  }

  @override
  Stream<int> getUnreadMessagesCount({
    required String userId,
    String? chatId,
  }) =>
      _chatsController.stream.map((chats) {
        var count = 0;

        for (var chat in chats) {
          if (chat.users.contains(userId)) {
            count += chat.unreadMessageCount;
          }
        }

        return count;
      });

  @override
  Future<String> uploadImage({
    required String path,
    required Uint8List image,
  }) =>
      Future.value("https://picsum.photos/200/300");
}
