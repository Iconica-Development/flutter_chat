/// An exception that is used to indicate the failure to load a chat for given
/// [chatId]
class ChatNotFoundException implements Exception {
  /// Create an instance of the chat not found exception
  const ChatNotFoundException({
    required this.chatId,
  });

  /// The chat that was attempted to load, but never found.
  final String chatId;
}

/// An exception that is used to indicate the failure to load the messages for a
/// given [chatId]
class ChatMessagesNotFoundException implements Exception {
  /// Create an instance of the chatmessages not found exception
  const ChatMessagesNotFoundException({
    required this.chatId,
  });

  /// The chat for which messages were attempted to load, but never found.
  final String chatId;
}
