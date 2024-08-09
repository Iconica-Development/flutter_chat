/// Message model
/// Represents a message in a chat
/// [id] is the message id.
/// [text] is the message text.
/// [imageUrl] is the message image url.
/// [timestamp] is the message timestamp.
/// [senderId] is the sender id.
class MessageModel {
  /// Message model constructor
  const MessageModel({
    required this.chatId,
    required this.id,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.senderId,
  });

  final String chatId;

  /// The message id
  final String id;

  /// The message text
  final String? text;

  /// The message image url
  final String? imageUrl;

  /// The message timestamp
  final DateTime timestamp;

  /// The sender id
  final String senderId;

  /// The message model copy with method
  MessageModel copyWith({
    String? chatId,
    String? id,
    String? text,
    String? imageUrl,
    DateTime? timestamp,
    String? senderId,
  }) =>
      MessageModel(
        chatId: chatId ?? this.chatId,
        id: id ?? this.id,
        text: text ?? this.text,
        imageUrl: imageUrl ?? this.imageUrl,
        timestamp: timestamp ?? this.timestamp,
        senderId: senderId ?? this.senderId,
      );
}

/// Extension on [MessageModel] to check the message type
extension MessageType on MessageModel {
  /// Check if the message is a text message
  bool get isTextMessage => text != null;

  /// Check if the message is an image message
  bool get isImageMessage => imageUrl != null;
}
