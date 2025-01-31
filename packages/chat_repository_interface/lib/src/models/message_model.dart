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
    required this.messageType,
    required this.imageUrl,
    required this.timestamp,
    required this.senderId,
  });

  /// Creates a message model instance given a map instance
  factory MessageModel.fromMap(String id, Map<String, dynamic> map) =>
      MessageModel(
        chatId: map["chatId"],
        id: id,
        text: map["text"],
        messageType: map["messageType"],
        imageUrl: map["imageUrl"],
        timestamp: DateTime.fromMillisecondsSinceEpoch(map["timestamp"]),
        senderId: map["senderId"],
      );

  /// The chat id
  final String chatId;

  /// The message id
  final String id;

  /// The message text
  final String? text;

  /// The type of message for instance (user, system, etc)
  final String? messageType;

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
    String? messageType,
    String? imageUrl,
    DateTime? timestamp,
    String? senderId,
  }) =>
      MessageModel(
        chatId: chatId ?? this.chatId,
        id: id ?? this.id,
        text: text ?? this.text,
        messageType: messageType ?? this.messageType,
        imageUrl: imageUrl ?? this.imageUrl,
        timestamp: timestamp ?? this.timestamp,
        senderId: senderId ?? this.senderId,
      );

  /// Creates a map representation of this object
  Map<String, dynamic> toMap() => {
        "chatId": chatId,
        "text": text,
        "messageType": messageType,
        "imageUrl": imageUrl,
        "timestamp": timestamp.millisecondsSinceEpoch,
        "senderId": senderId,
      };
}

/// Extension on [MessageModel] to check the message type
extension MessageType on MessageModel {
  /// Check if the message is a text message
  bool get isTextMessage => text != null;

  /// Check if the message is an image message
  bool get isImageMessage => imageUrl != null;
}
