import 'dart:typed_data';

import 'package:chat_repository_interface/src/models/chat_model.dart';
import 'package:chat_repository_interface/src/models/message_model.dart';
import 'package:chat_repository_interface/src/models/user_model.dart';

abstract class ChatRepositoryInterface {
  String createChat({
    required List<UserModel> users,
    String? chatName,
    String? description,
    String? imageUrl,
    List<MessageModel>? messages,
  });

  Stream<ChatModel> updateChat({
    required ChatModel chat,
  });

  Stream<ChatModel> getChat({
    required String chatId,
  });

  Stream<List<ChatModel>?> getChats({
    required String userId,
  });

  Stream<List<MessageModel>?> getMessages({
    required String chatId,
    required String userId,
    required int pageSize,
    required int page,
  });

  bool sendMessage({
    required String chatId,
    required String senderId,
    String? text,
    String? imageUrl,
  });

  bool deleteChat({
    required String chatId,
  });

  Stream<int> getUnreadMessagesCount({
    required String userId,
    String? chatId,
  });

  Future<String> uploadImage({
    required String path,
    required Uint8List image,
  });
}
