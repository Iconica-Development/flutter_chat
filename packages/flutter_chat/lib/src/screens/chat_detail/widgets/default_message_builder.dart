import "package:cached_network_image/cached_network_image.dart";
import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_chat/src/config/chat_options.dart";
import "package:flutter_chat/src/services/date_formatter.dart";
import "package:flutter_chat/src/util/scope.dart";

/// The default chat message builder that shows messages aligned to the left or
/// right depending on the sender.
/// It can be styled using the [MessageTheme] from the [ChatOptions].
class DefaultChatMessageBuilder extends StatelessWidget {
  /// Creates a new [DefaultChatMessageBuilder]
  const DefaultChatMessageBuilder({
    required this.message,
    required this.previousMessage,
    required this.user,
    required this.onPressUserProfile,
    super.key,
  });

  /// The message that is being built
  final MessageModel message;

  /// The previous message if any, this can be used to determine if the message
  /// is from the same sender as the previous message.
  final MessageModel? previousMessage;

  /// The user that sent the message
  final UserModel user;

  /// The function that is called when the user profile is pressed
  final Function(UserModel user) onPressUserProfile;

  /// implements [ChatMessageBuilder]
  static Widget builder(
    BuildContext context,
    MessageModel message,
    MessageModel? previousMessage,
    UserModel user,
    Function(UserModel user) onPressUserProfile,
  ) =>
      DefaultChatMessageBuilder(
        message: message,
        previousMessage: previousMessage,
        user: user,
        onPressUserProfile: onPressUserProfile,
      );

  /// Merges the [MessageTheme] from the themeresolver with the [MessageTheme]
  /// from the options and the [MessageTheme] from the theme. Priority is given
  /// to the [MessageTheme] from the themeresolver.
  MessageTheme _resolveMessageTheme({
    required BuildContext context,
    required ChatOptions options,
    required MessageModel message,
    required UserModel user,
  }) =>
      [
        options.messageThemeResolver(context, message, user),
        options.messageTheme,
        MessageTheme.fromTheme(Theme.of(context)),
      ].whereType<MessageTheme>().reduce((value, element) => value | element);

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;
    var userId = chatScope.userId;

    var messageTheme = _resolveMessageTheme(
      context: context,
      options: options,
      message: message,
      user: user,
    );

    var isSameSender = previousMessage != null &&
        previousMessage?.senderId == message.senderId;

    var isMessageFromSelf = message.senderId == userId;

    var chatMessage = _ChatMessageBubble(
      isSameSender: isSameSender,
      isMessageFromSelf: isMessageFromSelf,
      message: message,
      messageTheme: messageTheme,
      user: user,
    );

    var messagePadding = messageTheme.messageSidePadding!;

    var standardAlignmentIfNull =
        isMessageFromSelf ? TextAlign.right : TextAlign.left;

    var leftPaddingMessage =
        switch (messageTheme.messageAlignment ?? standardAlignmentIfNull) {
      TextAlign.left => 0.0,
      TextAlign.right => messagePadding,
      _ => messagePadding / 2,
    };

    var rightPadding =
        switch (messageTheme.messageAlignment ?? standardAlignmentIfNull) {
      TextAlign.left => messagePadding,
      TextAlign.right => 0.0,
      _ => messagePadding / 2,
    };

    return Row(
      children: [
        SizedBox(width: leftPaddingMessage + options.spacing.chatSidePadding),
        chatMessage,
        SizedBox(width: rightPadding + options.spacing.chatSidePadding),
      ],
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  const _ChatMessageBubble({
    required this.isSameSender,
    required this.isMessageFromSelf,
    required this.message,
    required this.messageTheme,
    required this.user,
  });

  final bool isSameSender;
  final bool isMessageFromSelf;
  final MessageModel message;
  final MessageTheme messageTheme;
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    var options = ChatScope.of(context).options;
    var dateFormatter = DateFormatter(options: options);

    var messageTime = dateFormatter.format(date: message.timestamp);

    var senderTitle = Text(
      user.firstName ?? "",
      style: theme.textTheme.titleMedium,
    );

    var messageTimeRow = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 4),
          child: Text(
            messageTime,
            style: textTheme.bodySmall?.copyWith(
              color: messageTheme.textColor,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (messageTheme.showName! && !isSameSender) ...[
            SizedBox(height: options.spacing.chatBetweenMessagesPadding),
            senderTitle,
          ],
          const SizedBox(height: 4),
          DefaultChatMessageContainer(
            backgroundColor: messageTheme.backgroundColor!,
            borderColor: messageTheme.borderColor!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 4),
                if (message.imageUrl?.isNotEmpty ?? false) ...[
                  _DefaultChatImage(
                    message: message,
                    messageTheme: messageTheme,
                  ),
                  const SizedBox(height: 2),
                ],
                if (message.text?.isNotEmpty ?? false) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                      left: 12,
                      right: 12,
                      bottom: 4,
                    ),
                    child: Text(
                      message.text!,
                      style: textTheme.bodyLarge?.copyWith(
                        color: messageTheme.textColor,
                      ),
                      textAlign: messageTheme.textAlignment,
                    ),
                  ),
                ],
                if (messageTheme.showTime!) ...[
                  messageTimeRow,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DefaultChatImage extends StatelessWidget {
  const _DefaultChatImage({
    required this.message,
    required this.messageTheme,
  });

  final MessageModel message;

  final MessageTheme messageTheme;

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: CachedNetworkImage(
              imageUrl: message.imageUrl!,
              fit: BoxFit.fitWidth,
              errorWidget: (context, url, error) => Text(
                "Something went wrong",
                style: textTheme.bodyLarge?.copyWith(
                  color: messageTheme.textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A container for the chat message that provides a decoration around the
/// message
class DefaultChatMessageContainer extends StatelessWidget {
  /// Creates a new [DefaultChatMessageContainer]
  const DefaultChatMessageContainer({
    required this.backgroundColor,
    required this.borderColor,
    required this.child,
    super.key,
  });

  /// The color of the message background
  final Color backgroundColor;

  /// The color of the border around the message
  final Color borderColor;

  /// The content of the message
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 1,
            color: borderColor,
          ),
        ),
        child: child,
      );
}
