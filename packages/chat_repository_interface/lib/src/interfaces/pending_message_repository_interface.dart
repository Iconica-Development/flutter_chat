import "package:chat_repository_interface/src/models/message_model.dart";

/// The pending chat messages repository interface
/// Implement this interface to create a pending chat
/// messages repository with a given data source.
abstract class PendingMessageRepositoryInterface {
  /// Get the messages for the given [chatId].
  /// Returns a list of [MessageModel] stream.
  /// [userId] is the user id.
  /// [chatId] is the chat id.
  /// Returns a list of [MessageModel] stream.
  Stream<List<MessageModel>> getMessages({
    required String chatId,
    required String userId,
  });

  /// Create a message in the pending messages and return the created message.
  /// [chatId] is the chat id.
  /// [senderId] is the sender id.
  /// [text] is the message text.
  /// [imageUrl] is the image url.
  Future<MessageModel> createMessage({
    required String chatId,
    required String senderId,
    required String messageId,
    String? text,
    String? imageUrl,
    String? messageType,
    DateTime? timestamp,
  });

  /// Mark a message as being succesfully sent to the server,
  /// so that it can be removed from this data source.
  Future<void> markMessageSent({
    required String chatId,
    required String messageId,
  });
}
