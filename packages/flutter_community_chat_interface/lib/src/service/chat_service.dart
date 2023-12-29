import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';

abstract class ChatService {
  Stream<List<ChatModel>> getChatsStream(int pageSize);
  Future<ChatModel> getChatByUser(ChatUserModel user);
  Future<ChatModel> getChatById(String id);
  Future<void> deleteChat(ChatModel chat);
  Future<void> readChat(ChatModel chat);
  Future<ChatModel> storeChatIfNot(ChatModel chat);
  Stream<int> getUnreadChatsCountStream();
}
