import 'package:flutter_community_chat_interface/src/model/chat_user.dart';

abstract class ChatMessageModel {
  const ChatMessageModel({
    required this.sender,
    required this.timestamp,
  });

  final ChatUserModel sender;
  final DateTime timestamp;
}
