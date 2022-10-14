import 'package:flutter_community_chat_interface/src/model/chat_message.dart';

class ChatTextMessageModel extends ChatMessageModel {
  ChatTextMessageModel({
    required super.sender,
    required super.timestamp,
    required this.text,
  });

  final String text;
}
