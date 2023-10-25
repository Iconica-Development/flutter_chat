import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';

abstract class ChatService {
  Stream<List<ChatModel>> getChatsStream();
  @Deprecated('Use getChatById instead')
  Future<ChatModel> getOrCreateChatByUser(ChatUserModel user);
  Future<ChatModel> getChatById(String id);
  Future<void> deleteChat(ChatModel chat);
  Future<void> readChat(ChatModel chat);
  Future<ChatModel> storeChatIfNot(ChatModel chat);
  Stream<int> getUnreadChatsCountStream();
}
