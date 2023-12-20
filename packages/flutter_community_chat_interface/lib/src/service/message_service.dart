import 'dart:typed_data';
import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';

abstract class MessageService {
  Future<void> sendTextMessage({
    required ChatModel chat,
    required String text,
  });

  Future<void> sendImageMessage({
    required ChatModel chat,
    required Uint8List image,
  });

  Stream<List<ChatMessageModel>> getMessagesStream(
    ChatModel chat,
    int pageSize,
  );
}
