import 'package:flutter_chat_interface/flutter_chat_interface.dart';

abstract class ChatOverviewService {
  Stream<List<ChatModel>> getChatsStream();
  Future<ChatModel> getChatByUser(ChatUserModel user);
  Future<ChatModel> getChatById(String id);
  Future<void> deleteChat(ChatModel chat);
  Future<void> readChat(ChatModel chat);
  Future<ChatModel> storeChatIfNot(ChatModel chat);
  Stream<int> getUnreadChatsCountStream();
}
