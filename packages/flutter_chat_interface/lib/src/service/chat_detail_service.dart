import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_chat_interface/flutter_chat_interface.dart';

/// An abstract class defining the interface for a chat detail service.
abstract class ChatDetailService with ChangeNotifier {
  /// Sends a text message to the specified chat.
  Future<void> sendTextMessage({
    required String chatId,
    required String text,
  });

  /// Sends an image message to the specified chat.
  Future<void> sendImageMessage({
    required String chatId,
    required Uint8List image,
  });

  /// Retrieves a stream of messages for the specified chat.
  Stream<List<ChatMessageModel>> getMessagesStream(
    String chatId,
  );

  /// Fetches more messages for the specified chat with a given page size.
  Future<void> fetchMoreMessage(int pageSize, String chatId);

  /// Retrieves the list of messages for the chat.
  List<ChatMessageModel> getMessages();

  /// Stops listening for messages.
  void stopListeningForMessages();
}
