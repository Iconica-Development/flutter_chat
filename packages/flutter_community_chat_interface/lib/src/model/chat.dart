import 'package:flutter_community_chat_interface/src/model/chat_message.dart';

abstract class ChatModel {
  const ChatModel({
    this.id,
    this.messages = const [],
    this.lastUsed,
    this.lastMessage,
  });

  final String? id;
  final List<ChatMessageModel>? messages;
  final DateTime? lastUsed;
  final ChatMessageModel? lastMessage;
}
