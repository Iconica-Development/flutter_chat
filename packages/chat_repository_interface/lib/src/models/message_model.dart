class MessageModel {
  MessageModel({
    required this.id,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.senderId,
  });

  final String id;
  final String? text;
  final String? imageUrl;
  final DateTime timestamp;
  final String senderId;

  MessageModel copyWith({
    String? id,
    String? text,
    String? imageUrl,
    DateTime? timestamp,
    String? senderId,
  }) {
    return MessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      senderId: senderId ?? this.senderId,
    );
  }
}

extension MessageType on MessageModel {
  bool isTextMessage() => text != null;

  bool isImageMessage() => imageUrl != null;
}
