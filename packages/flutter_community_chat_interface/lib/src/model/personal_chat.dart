import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';

class PersonalChatModel extends ChatModel {
  PersonalChatModel({
    required this.user,
    super.id,
    super.messages,
    super.lastUsed,
    super.lastMessage,
  });

  final ChatUserModel user;
}
