import "package:flutter_chat_interface/flutter_chat_interface.dart";

abstract class ChatOverviewService {
  /// Retrieves a stream of chats.
  /// This stream is updated whenever a new chat is created.
  Stream<List<ChatModel>> getChatsStream();

  /// Retrieves a chat based on the user.
  Future<ChatModel> getChatByUser(ChatUserModel user);

  /// Retrieves a chat based on the ID.
  Future<ChatModel> getChatById(String id);

  /// Deletes the chat for this user and the other users in the chat.
  Future<void> deleteChat(ChatModel chat);

  /// When a chat is read, this method is called.
  Future<void> readChat(ChatModel chat);

  /// Creates the chat if it does not exist.
  Future<ChatModel> storeChatIfNot(ChatModel chat);

  /// Retrieves the number of unread chats.
  Stream<int> getUnreadChatsCountStream();
}
