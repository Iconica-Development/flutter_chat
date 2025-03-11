import "dart:async";

import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:chat_repository_interface/src/local/local_memory_db.dart";
import "package:collection/collection.dart";
import "package:rxdart/rxdart.dart";

/// The local pending message repository
class LocalPendingMessageRepository
    implements PendingMessageRepositoryInterface {
  /// The local pending message repository constructor
  LocalPendingMessageRepository();

  final StreamController<List<MessageModel>> _messageController =
      BehaviorSubject<List<MessageModel>>();

  @override
  Stream<List<MessageModel>> getMessages({
    required String chatId,
    required String userId,
  }) {
    var foundChat =
        chats.firstWhereOrNull((chatModel) => chatModel.id == chatId);

    if (foundChat == null) {
      _messageController.add([]);
    } else {
      var allMessages = List<MessageModel>.from(
        pendingChatMessages[chatId] ?? [],
      );
      allMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      _messageController.add(allMessages);
    }

    return _messageController.stream;
  }

  Future<void> _chatExists(String chatId) async {
    var chat = chats.firstWhereOrNull((e) => e.id == chatId);
    if (chat == null) throw Exception("Chat not found");
  }

  @override
  Future<MessageModel> createMessage({
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
      status: MessageStatus.sending,
    );

    await _chatExists(chatId);

    var messages = List<MessageModel>.from(pendingChatMessages[chatId] ?? []);
    messages.add(message);

    pendingChatMessages[chatId] = messages;

    _messageController.add(pendingChatMessages[chatId] ?? []);

    return message;
  }

  @override
  Future<void> markMessageSent({
    required String chatId,
    required String messageId,
  }) async {
    await _chatExists(chatId);
    var messages = List<MessageModel>.from(pendingChatMessages[chatId] ?? []);

    MessageModel markSent(MessageModel message) =>
        (message.id == messageId) ? message.markSent() : message;

    pendingChatMessages[chatId] = messages.map(markSent).toList();
  }
}
