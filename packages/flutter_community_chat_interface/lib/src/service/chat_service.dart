import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';

abstract class ChatService {
  Stream<List<PersonalChatModel>> getChatsStream();
  Future<PersonalChatModel> getOrCreateChatByUser(ChatUserModel user);
  Future<void> deleteChat(PersonalChatModel chat);
  Future<PersonalChatModel> storeChatIfNot(PersonalChatModel chat);
}
