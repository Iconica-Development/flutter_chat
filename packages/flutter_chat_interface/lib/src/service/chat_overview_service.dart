import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_chat_interface/flutter_chat_interface.dart";

abstract class ChatOverviewService extends ChangeNotifier {
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
  Future<ChatModel> storeChatIfNot(ChatModel chat, Uint8List? image);

  /// Retrieves the number of unread chats.
  Stream<int> getUnreadChatsCountStream();

  /// Retrieves the currently selected users to be added to a new groupchat.
  List<ChatUserModel> get currentlySelectedUsers;

  /// Adds a user to the currently selected users.
  void addCurrentlySelectedUser(ChatUserModel user);

  /// Deletes a user from the currently selected users.
  void removeCurrentlySelectedUser(ChatUserModel user);

  void clearCurrentlySelectedUsers();

  /// uploads an image for a group chat.
  Future<String> uploadGroupChatImage(Uint8List image, String chatId);
}
