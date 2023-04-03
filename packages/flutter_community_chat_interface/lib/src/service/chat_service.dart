import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';

abstract class ChatService {
  Stream<List<ChatModel>> getChatsStream();
  Future<ChatModel> getOrCreateChatByUser(ChatUserModel user);
  Future<void> deleteChat(ChatModel chat);
  Future<ChatModel> storeChatIfNot(ChatModel chat);
}
