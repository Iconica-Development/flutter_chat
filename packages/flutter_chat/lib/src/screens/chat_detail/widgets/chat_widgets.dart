import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_accessibility/flutter_accessibility.dart";
import "package:flutter_chat/src/screens/chat_detail/widgets/default_message_builder.dart";
import "package:flutter_chat/src/util/scope.dart";
import "package:flutter_hooks/flutter_hooks.dart";

/// Widget displayed when there are no messages in the chat.
class ChatNoMessages extends HookWidget {
  /// Creates a new [ChatNoMessages] widget.
  const ChatNoMessages({
    required this.isGroupChat,
    super.key,
  });

  /// Determines if this chat is a group chat.
  final bool isGroupChat;

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;
    var translations = options.translations;
    var theme = Theme.of(context);

    return Center(
      child: CustomSemantics(
        identifier: options.semantics.chatNoMessages,
        value: isGroupChat
            ? translations.writeFirstMessageInGroupChat
            : translations.writeMessageToStartChat,
        child: Text(
          isGroupChat
              ? translations.writeFirstMessageInGroupChat
              : translations.writeMessageToStartChat,
          style: theme.textTheme.bodySmall,
        ),
      ),
    );
  }
}

/// A single chat bubble in the chat
class ChatBubble extends HookWidget {
  /// Creates a new [ChatBubble] widget.
  const ChatBubble({
    required this.message,
    required this.sender,
    required this.onPressSender,
    required this.semanticIdTitle,
    required this.semanticIdText,
    required this.semanticIdTime,
    this.previousMessage,
    super.key,
  });

  /// The message to display.
  final MessageModel message;

  /// The user who sent the message. This can be null because some messages are
  /// not from users
  final UserModel? sender;

  /// The previous message in the list, if any.
  final MessageModel? previousMessage;

  /// Callback function when a message sender is pressed.
  final Function(UserModel user) onPressSender;

  /// Semantic id for message title
  final String semanticIdTitle;

  /// Semantic id for message time
  final String semanticIdTime;

  /// Semantic id for message text
  final String semanticIdText;

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;

    return options.builders.chatMessageBuilder.call(
          context,
          message,
          previousMessage,
          sender,
          onPressSender,
          semanticIdTitle,
          semanticIdTime,
          semanticIdText,
        ) ??
        DefaultChatMessageBuilder(
          message: message,
          previousMessage: previousMessage,
          sender: sender,
          onPressSender: onPressSender,
          semanticIdTitle: semanticIdTitle,
          semanticIdTime: semanticIdTime,
          semanticIdText: semanticIdText,
        );
  }
}
