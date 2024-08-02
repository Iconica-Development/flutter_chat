import 'dart:async';
import 'dart:typed_data';

import 'package:chat_repository_interface/src/interfaces/chat_repostory_interface.dart';
import 'package:chat_repository_interface/src/interfaces/user_repository_interface.dart';
import 'package:chat_repository_interface/src/local/local_chat_repository.dart';
import 'package:chat_repository_interface/src/local/local_user_repository.dart';
import 'package:chat_repository_interface/src/models/chat_model.dart';
import 'package:chat_repository_interface/src/models/message_model.dart';
import 'package:chat_repository_interface/src/models/user_model.dart';
import 'package:collection/collection.dart';

class ChatService {
  final ChatRepositoryInterface chatRepository;
  final UserRepositoryInterface userRepository;

  ChatService({
    ChatRepositoryInterface? chatRepository,
    UserRepositoryInterface? userRepository,
  })  : chatRepository = chatRepository ?? LocalChatRepository(),
        userRepository = userRepository ?? LocalUserRepository();

  Stream<ChatModel> createChat({
    required List<UserModel> users,
    String? chatName,
    String? description,
    String? imageUrl,
    List<MessageModel>? messages,
  }) {
    var chatId = chatRepository.createChat(
      users: users,
      chatName: chatName,
      description: description,
      imageUrl: imageUrl,
      messages: messages,
    );

    return chatRepository.getChat(chatId: chatId);
  }

  Stream<List<ChatModel>?> getChats({
    required String userId,
  }) {
    return chatRepository.getChats(userId: userId);
  }

  Stream<ChatModel> getChat({
    required String chatId,
  }) {
    return chatRepository.getChat(chatId: chatId);
  }

  Future<ChatModel?> getChatByUser({
    required String currentUser,
    required String otherUser,
  }) async {
    var chats = await chatRepository
        .getChats(userId: currentUser)
        .first
        .timeout(const Duration(seconds: 1));

    var personalChats =
        chats?.where((element) => element.users.length == 2).toList();

    return personalChats?.firstWhereOrNull(
      (element) => element.users.where((e) => e.id == otherUser).isNotEmpty,
    );
  }

  Future<ChatModel?> getGroupChatByUser({
    required String currentUser,
    required List<UserModel> otherUsers,
    required String chatName,
    required String description,
  }) async {
    var chats = await chatRepository
        .getChats(userId: currentUser)
        .first
        .timeout(const Duration(seconds: 1));

    var personalChats =
        chats?.where((element) => element.users.length > 2).toList();

    try {
      var groupChats = personalChats
          ?.where((chats) => otherUsers.every(chats.users.contains))
          .toList();

      return groupChats?.firstWhereOrNull(
        (element) =>
            element.chatName == chatName && element.description == description,
      );
    } catch (e) {
      return null;
    }
  }

  Stream<List<MessageModel>?> getMessages({
    required String userId,
    required String chatId,
    required int pageSize,
    required int page,
  }) {
    return chatRepository.getMessages(
      userId: userId,
      chatId: chatId,
      pageSize: pageSize,
      page: page,
    );
  }

  bool sendMessage({
    required String chatId,
    String? text,
    required String senderId,
    String? imageUrl,
  }) {
    return chatRepository.sendMessage(
      chatId: chatId,
      text: text,
      senderId: senderId,
      imageUrl: imageUrl,
    );
  }

  bool deleteChat({
    required String chatId,
  }) {
    return chatRepository.deleteChat(chatId: chatId);
  }

  Stream<UserModel> getUser({required String userId}) {
    return userRepository.getUser(userId: userId);
  }

  Stream<List<UserModel>> getAllUsers() {
    return userRepository.getAllUsers();
  }

  Stream<int> getUnreadMessagesCount({
    required String userId,
    String? chatId,
  }) {
    if (chatId == null) {
      return chatRepository.getUnreadMessagesCount(userId: userId);
    }

    return chatRepository.getUnreadMessagesCount(
      userId: userId,
      chatId: chatId,
    );
  }

  Future<String> uploadImage({
    required String path,
    required Uint8List image,
  }) {
    return chatRepository.uploadImage(
      path: path,
      image: image,
    );
  }

  Future<void> markAsRead({
    required String chatId,
  }) async {
    var chat = await chatRepository.getChat(chatId: chatId).first;

    var newChat = chat.copyWith(
      lastUsed: DateTime.now(),
      unreadMessageCount: 0,
    );

    chatRepository.updateChat(chat: newChat);
  }
}
