import 'package:flutter_community_chat_interface/src/model/chat_message.dart';

class ChatImageMessageModel extends ChatMessageModel {
  ChatImageMessageModel({
    required super.sender,
    required super.timestamp,
    required this.imageUrl,
  });

  final String imageUrl;
}
