import "dart:typed_data";

import "package:chat_repository_interface/src/models/chat_model.dart";
import "package:chat_repository_interface/src/models/message_model.dart";
import "package:chat_repository_interface/src/models/user_model.dart";

/// The chat repository interface
/// Implement this interface to create a chat
/// repository with a given data source.
abstract class ChatRepositoryInterface {
  /// Create a chat with the given parameters.
  /// [users] is a list of [UserModel] that will be part of the chat.
  /// [chatName] is the name of the chat.
  /// [description] is the description of the chat.
  /// [imageUrl] is the image url of the chat.
  /// [messages] is a list of [MessageModel] that will be part of the chat.
  Future<void> createChat({
    required List<String> users,
    required bool isGroupChat,
    String? chatName,
    String? description,
    String? imageUrl,
    List<MessageModel>? messages,
  });

  /// Update the chat with the given parameters.
  /// [chat] is the chat that will be updated.
  Future<void> updateChat({
    required ChatModel chat,
  });

  /// Get the chat with the given [chatId].
  /// Returns a [ChatModel] stream.
  Stream<ChatModel> getChat({
    required String chatId,
  });

  /// Get the chats for the given [userId].
  /// Returns a list of [ChatModel] stream.
  Stream<List<ChatModel>?> getChats({
    required String userId,
  });

  /// Get the messages for the given [chatId].
  /// Returns a list of [MessageModel] stream.
  /// [userId] is the user id.
  /// [chatId] is the chat id.
  /// Returns a list of [MessageModel] stream.
  Stream<List<MessageModel>?> getMessages({
    required String chatId,
    required String userId,
  });

  /// Get the message with the given [messageId].
  /// [chatId] is the chat id.
  /// Returns a [MessageModel] stream.
  Stream<MessageModel?> getMessage({
    required String chatId,
    required String messageId,
  });

  /// Signals that new messages should be loaded after the given message.
  /// The stream should emit the new messages.
  Future<void> loadNewMessagesAfter({
    required String userId,
    required MessageModel lastMessage,
  });

  /// Signals that old messages should be loaded before the given message.
  /// The stream should emit the new messages.
  Future<void> loadOldMessagesBefore({
    required String userId,
    required MessageModel firstMessage,
  });

  /// Retrieve the next unused message id given a current chat.
  ///
  /// The resulting string should be at least unique per [chatId]. The userId
  /// is provided in case the specific user has influence on the id.
  ///
  /// Imagine returning a UUID, the next integer in a counter or the document
  /// id in firebase.
  Future<String> getNextMessageId({
    required String userId,
    required String chatId,
  });

  /// Send a message with the given parameters.
  ///
  /// [chatId] is the chat id.
  /// [senderId] is the sender id.
  /// [messageId] is the identifier for this message
  /// [text] is the message text.
  /// [imageUrl] is the image url.
  /// [messageType] is a way to identify a difference in messages
  /// [timestamp] is the moment of sending.
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String messageId,
    String? text,
    String? imageUrl,
    String? messageType,
    DateTime? timestamp,
  });

  /// Delete the chat with the given [chatId].
  Future<void> deleteChat({
    required String chatId,
  });

  /// Get the unread messages count for the given [userId].
  /// [chatId] is the chat id. If not provided, it will return the
  /// total unread messages count.
  /// Returns an integer stream.
  Stream<int> getUnreadMessagesCount({
    required String userId,
    String? chatId,
  });

  /// Upload an image with the given parameters.
  /// [path] is the path of the image.
  /// [image] is the image data.
  /// [senderId] is the sender id.
  /// [chatId] is the chat id.
  /// Returns the image url.
  Future<String> uploadImage({
    required String path,
    required String senderId,
    required String chatId,
    required Uint8List image,
  });
}
