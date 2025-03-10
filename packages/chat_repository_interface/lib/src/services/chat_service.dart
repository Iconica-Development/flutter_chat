import "dart:async";
import "dart:typed_data";

import "package:chat_repository_interface/src/extension/uint8list_data_uri.dart";
import "package:chat_repository_interface/src/interfaces/chat_repostory_interface.dart";
import "package:chat_repository_interface/src/interfaces/pending_message_repository_interface.dart";
import "package:chat_repository_interface/src/interfaces/user_repository_interface.dart";
import "package:chat_repository_interface/src/local/local_chat_repository.dart";
import "package:chat_repository_interface/src/local/local_pending_message_repository.dart";
import "package:chat_repository_interface/src/local/local_user_repository.dart";
import "package:chat_repository_interface/src/models/chat_model.dart";
import "package:chat_repository_interface/src/models/message_model.dart";
import "package:chat_repository_interface/src/models/user_model.dart";
import "package:collection/collection.dart";
import "package:rxdart/rxdart.dart";

/// The chat service
/// Use this service to interact with the chat repository.
/// Optionally provide a [chatRepository] and [userRepository]
class ChatService {
  /// Create a chat service with the given parameters.
  ChatService({
    required this.userId,
    ChatRepositoryInterface? chatRepository,
    PendingMessageRepositoryInterface? pendingMessageRepository,
    UserRepositoryInterface? userRepository,
  })  : chatRepository = chatRepository ?? LocalChatRepository(),
        pendingMessageRepository =
            pendingMessageRepository ?? LocalPendingMessageRepository(),
        userRepository = userRepository ?? LocalUserRepository();

  /// The user ID of the person currently looking at the chat
  final String userId;

  /// The chat repository
  final ChatRepositoryInterface chatRepository;

  /// The pending messages repository
  final PendingMessageRepositoryInterface pendingMessageRepository;

  /// The user repository
  final UserRepositoryInterface userRepository;

  /// Create a chat with the given parameters.
  /// [users] is a list of [UserModel] that will be part of the chat.
  /// [chatName] is the name of the chat.
  /// [description] is the description of the chat.
  /// [imageUrl] is the image url of the chat.
  /// [messages] is a list of [MessageModel] that will be part of the chat.
  /// Returns a [ChatModel] stream.
  Future<void> createChat({
    required List<UserModel> users,
    required bool isGroupChat,
    String? chatName,
    String? description,
    String? imageUrl,
    List<MessageModel>? messages,
  }) {
    var userIds = users.map((e) => e.id).toList();

    return chatRepository.createChat(
      isGroupChat: isGroupChat,
      users: userIds,
      chatName: chatName,
      description: description,
      imageUrl: imageUrl,
      messages: messages,
    );
  }

  /// Get the chats for the user with the given [userId].
  /// Returns a list of [ChatModel] stream.
  Stream<List<ChatModel>?> getChats() =>
      chatRepository.getChats(userId: userId);

  /// Get the chat with the given [chatId].
  /// Returns a [ChatModel] stream.
  Stream<ChatModel> getChat({
    required String chatId,
  }) =>
      chatRepository.getChat(chatId: chatId);

  /// Get the chat with the given [currentUser] and [otherUser].
  /// Returns a [ChatModel] stream.
  /// Returns null if the chat does not exist.
  Future<ChatModel?> getChatByUser({
    required String currentUser,
    required String otherUser,
  }) async {
    var chats = await chatRepository.getChats(userId: currentUser).first;

    var personalChats =
        chats?.where((element) => element.users.length == 2).toList();

    return personalChats?.firstWhereOrNull(
      (element) => element.users.where((e) => e == otherUser).isNotEmpty,
    );
  }

  /// Get the group chats with the given [currentUser] and [otherUsers].
  /// Returns a [ChatModel] stream.
  Future<ChatModel?> getGroupChatByUser({
    required String currentUser,
    required List<UserModel> otherUsers,
    required String chatName,
    required String description,
  }) async {
    try {
      var chats = await chatRepository.getChats(userId: currentUser).first;

      var personalChats =
          chats?.where((element) => element.isGroupChat).toList();

      var groupChats = personalChats
          ?.where(
            (chats) =>
                otherUsers.every((user) => chats.users.contains(user.id)),
          )
          .toList();

      return groupChats?.firstWhereOrNull(
        (element) =>
            element.chatName == chatName && element.description == description,
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      throw Exception("Chat not found");
    }
  }

  /// Get the message with the given [messageId].
  /// [chatId] is the chat id.
  /// Returns a [MessageModel] stream.
  Stream<MessageModel?> getMessage({
    required String chatId,
    required String messageId,
  }) =>
      chatRepository.getMessage(chatId: chatId, messageId: messageId);

  /// Get the messages for the given [chatId].
  /// Returns a list of [MessageModel] stream.
  /// [pageSize] is the number of messages to be fetched.
  /// [page] is the page number.
  /// [chatId] is the chat id.
  /// Returns a list of [MessageModel] stream.
  Stream<List<MessageModel>?> getMessages({
    required String chatId,
  }) {
    List<MessageModel> mergePendingMessages(
      List<MessageModel> messages,
      List<MessageModel> pendingMessages,
    ) =>
        {
          ...Map.fromEntries(
            pendingMessages.map((message) => MapEntry(message.id, message)),
          ),
          ...Map.fromEntries(
            messages.map((message) => MapEntry(message.id, message)),
          ),
        }.values.toList();

    return Rx.combineLatest2(
      chatRepository.getMessages(userId: userId, chatId: chatId),
      pendingMessageRepository.getMessages(userId: userId, chatId: chatId),
      (chatMessages, pendingChatMessages) {
        // TODO(Quirille): This is because chatRepository.getMessages
        // might return null, when really it should've just thrown
        // an exception instead.
        if (chatMessages == null) return null;
        return mergePendingMessages(chatMessages, pendingChatMessages);
      },
    );
  }

  /// Signals that new messages should be loaded after the given message.
  /// The stream should emit the new messages.
  Future<void> loadNewMessagesAfter({
    required MessageModel lastMessage,
  }) =>
      chatRepository.loadNewMessagesAfter(
        userId: userId,
        lastMessage: lastMessage,
      );

  /// Signals that old messages should be loaded before the given message.
  /// The stream should emit the new messages.
  Future<void> loadOldMessagesBefore({
    required MessageModel firstMessage,
  }) =>
      chatRepository.loadOldMessagesBefore(
        userId: userId,
        firstMessage: firstMessage,
      );

  /// Send a message with the given parameters.
  /// [chatId] is the chat id.
  /// [senderId] is the sender id.
  /// [text] is the message text.
  /// [imageUrl] is the image url.
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String messageId,
    String? text,
    String? messageType,
    String? imageUrl,
    Uint8List? imageData,
  }) async {
    await pendingMessageRepository.createMessage(
      chatId: chatId,
      senderId: senderId,
      messageId: messageId,
      text: text,
      messageType: messageType,
      imageUrl: imageData?.toDataUri() ?? imageUrl,
    );

    unawaited(
      chatRepository
          .sendMessage(
            chatId: chatId,
            messageId: messageId,
            text: text,
            messageType: messageType,
            senderId: senderId,
            imageUrl: imageUrl,
          )
          .then(
            (_) => pendingMessageRepository.markMessageSent(
              chatId: chatId,
              messageId: messageId,
            ),
          )
          .onError(
        (e, s) {
          // TODO(Quirille): handle exception when message sending has failed.
        },
      ),
    );
  }

  /// Delete the chat with the given parameters.
  /// [chatId] is the chat id.
  Future<void> deleteChat({
    required String chatId,
  }) =>
      chatRepository.deleteChat(chatId: chatId);

  /// Get user with the given [userId].
  /// Returns a [UserModel] stream.
  Stream<UserModel> getUser({required String userId}) =>
      userRepository.getUser(userId: userId);

  /// Get all the users.
  /// Returns a list of [UserModel] stream.
  Stream<List<UserModel>> getAllUsers() => userRepository.getAllUsers();

  /// Get the unread messages count for a user [chatId].
  /// [chatId] is the chat id. If not provided, it will return the
  /// total unread messages count.
  /// Returns a [Stream] of [int].
  Stream<int> getUnreadMessagesCount({
    String? chatId,
  }) =>
      chatRepository.getUnreadMessagesCount(userId: userId, chatId: chatId);

  /// Upload an image with the given parameters.
  /// [path] is the image path.
  /// [image] is the image bytes.
  /// [chatId] is the chat id.
  /// Returns a [Future] of [String].
  Future<String> uploadImage({
    required String path,
    required Uint8List image,
    required String chatId,
  }) =>
      chatRepository.uploadImage(
        path: path,
        image: image,
        senderId: userId,
        chatId: chatId,
      );

  /// Mark the chat as read with the given parameters.
  /// [chatId] is the chat id.
  /// Returns a [Future] of [void].
  Future<void> markAsRead({
    required String chatId,
  }) async {
    var chat = await chatRepository.getChat(chatId: chatId).first;

    if (chat.lastMessage == null) return;

    var lastMessage = await chatRepository
        .getMessage(chatId: chatId, messageId: chat.lastMessage!)
        .first;

    if (lastMessage != null && lastMessage.senderId == userId) return;

    var newChat = chat.copyWith(
      lastUsed: DateTime.now(),
      unreadMessageCount: 0,
    );

    await chatRepository.updateChat(chat: newChat);
  }

  /// Get all the users for the given [chatId].
  /// Returns a list of [UserModel] stream.
  Stream<List<UserModel>> getAllUsersForChat({required String chatId}) =>
      userRepository.getAllUsersForChat(chatId: chatId);
}
