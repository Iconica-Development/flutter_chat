import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_chat_interface/flutter_chat_interface.dart';

abstract class ChatDetailService with ChangeNotifier {
  Future<void> sendTextMessage({
    required String chatId,
    required String text,
  });

  Future<void> sendImageMessage({
    required String chatId,
    required Uint8List image,
  });

  Stream<List<ChatMessageModel>> getMessagesStream(
    String chatId,
  );

  Future<void> fetchMoreMessage(
    int pageSize,
    String chatId,
  );

  List<ChatMessageModel> getMessages();

  void stopListeningForMessages();
}
