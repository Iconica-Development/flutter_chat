import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_accessibility/flutter_accessibility.dart";
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
    required this.sender,
    required this.onPressSender,
    required this.semanticIdTitle,
    required this.semanticIdText,
    required this.semanticIdTime,
    super.key,
  });

  /// The message that is being built
  final MessageModel message;

  /// The previous message if any, this can be used to determine if the message
  /// is from the same sender as the previous message.
  final MessageModel? previousMessage;

  /// The user that sent the message, can be null if the message is an event
  final UserModel? sender;

  /// The function that is called when the sender is clicked
  final Function(UserModel user) onPressSender;

  /// Semantic id for message title
  final String semanticIdTitle;

  /// Semantic id for message time
  final String semanticIdTime;

  /// Semantic id for message text
  final String semanticIdText;

  /// implements [ChatMessageBuilder]
  static Widget builder(
    BuildContext context,
    MessageModel message,
    MessageModel? previousMessage,
    UserModel? sender,
    Function(UserModel sender) onPressSender,
    String semanticIdTitle,
    String semanticIdText,
    String semanticIdTime,
  ) =>
      DefaultChatMessageBuilder(
        message: message,
        previousMessage: previousMessage,
        sender: sender,
        onPressSender: onPressSender,
        semanticIdTitle: semanticIdTitle,
        semanticIdTime: semanticIdTime,
        semanticIdText: semanticIdText,
      );

  /// Merges the [MessageTheme] from the themeresolver with the [MessageTheme]
  /// from the options and the [MessageTheme] from the theme. Priority is given
  /// to the [MessageTheme] from the themeresolver.
  MessageTheme _resolveMessageTheme({
    required BuildContext context,
    required ChatOptions options,
    required MessageModel message,
    required MessageModel? previousMessage,
    required UserModel? user,
  }) =>
      [
        options.messageThemeResolver(context, message, previousMessage, user),
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
      previousMessage: previousMessage,
      user: sender,
    );

    var isSameSender = previousMessage != null &&
        previousMessage?.senderId == message.senderId;

    var hasPreviousIndicator = options.timeIndicatorOptions.sectionCheck(
      context,
      previousMessage,
      message,
    );

    var isMessageFromSelf = message.senderId == userId;

    var chatMessage = _ChatMessageBubble(
      isSameSender: isSameSender,
      hasPreviousIndicator: hasPreviousIndicator,
      isMessageFromSelf: isMessageFromSelf,
      previousMessage: previousMessage,
      message: message,
      messageTheme: messageTheme,
      sender: sender,
      semanticIdTitle: semanticIdTitle,
      semanticIdTime: semanticIdTime,
      semanticIdText: semanticIdText,
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
    required this.hasPreviousIndicator,
    required this.isMessageFromSelf,
    required this.message,
    required this.previousMessage,
    required this.messageTheme,
    required this.sender,
    required this.semanticIdTitle,
    required this.semanticIdTime,
    required this.semanticIdText,
  });

  final bool isSameSender;
  final bool hasPreviousIndicator;
  final bool isMessageFromSelf;
  final MessageModel message;
  final MessageModel? previousMessage;
  final MessageTheme messageTheme;
  final UserModel? sender;
  final String semanticIdTitle;
  final String semanticIdTime;
  final String semanticIdText;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    var options = ChatScope.of(context).options;
    var dateFormatter = DateFormatter(options: options);

    var isNewDate = previousMessage != null &&
        message.timestamp.day != previousMessage?.timestamp.day;

    var showFullDateOnMessage =
        messageTheme.showFullDate ?? (isNewDate || previousMessage == null);
    var messageTime = dateFormatter.format(
      date: message.timestamp.toLocal(),
      showFullDate: showFullDateOnMessage,
    );

    var senderTitle =
        options.senderTitleResolver?.call(sender) ?? sender?.firstName ?? "";
    var senderTitleText = CustomSemantics(
      identifier: semanticIdTitle,
      value: senderTitle,
      child: Text(
        senderTitle,
        style: theme.textTheme.titleMedium,
      ),
    );

    var messageTimeRow = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 4),
          child: CustomSemantics(
            identifier: semanticIdTime,
            value: messageTime,
            child: Text(
              messageTime,
              style: textTheme.bodySmall?.copyWith(
                color: messageTheme.textColor,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ),
      ],
    );

    var showName =
        messageTheme.showName ?? (!isSameSender || hasPreviousIndicator);

    var isNewSection = hasPreviousIndicator || showName;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isNewSection) ...[
            SizedBox(height: options.spacing.chatBetweenMessagesPadding),
          ],
          if (showName) senderTitleText,
          const SizedBox(height: 4),
          DefaultChatMessageContainer(
            backgroundColor: messageTheme.backgroundColor!,
            borderColor: messageTheme.borderColor!,
            borderRadius: messageTheme.borderRadius!,
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
                    child: Semantics(
                      identifier: semanticIdText,
                      value: message.text,
                      child: Text(
                        message.text!,
                        style: textTheme.bodyLarge?.copyWith(
                          color: messageTheme.textColor,
                        ),
                        textAlign: messageTheme.textAlignment,
                      ),
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
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;
    var textTheme = Theme.of(context).textTheme;
    var imageUrl = message.imageUrl!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: Image(
              image:
                  options.imageProviderResolver(context, Uri.parse(imageUrl)),
              fit: BoxFit.fitWidth,
              errorBuilder: (context, error, stackTrace) => Text(
                // TODO(Jacques): Non-replaceable text
                "Something went wrong with loading the image",
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
    required this.borderRadius,
    required this.child,
    super.key,
  });

  /// The color of the message background
  final Color backgroundColor;

  /// The color of the border around the message
  final Color borderColor;

  /// The border radius of the message container
  final BorderRadius borderRadius;

  /// The content of the message
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          border: Border.all(
            width: 1,
            color: borderColor,
          ),
        ),
        child: child,
      );
}
