import "package:flutter/material.dart";
import "package:flutter_chat/flutter_chat.dart";
export "package:flutter_chat/src/screens/chat_detail/widgets/default_chat_time_indicator.dart";

/// All options related to the time indicator
class ChatTimeIndicatorOptions {
  /// Create default ChatTimeIndicator options
  const ChatTimeIndicatorOptions({
    this.indicatorBuilder = DefaultChatTimeIndicator.builder,
    this.labelResolver = defaultChatTimeIndicatorLabelResolver,
    this.sectionCheck = defaultChatTimeIndicatorSectionChecker,
  });

  /// This completely disables the chat time indicator feature
  const ChatTimeIndicatorOptions.none()
      : indicatorBuilder = DefaultChatTimeIndicator.builder,
        labelResolver = defaultChatTimeIndicatorLabelResolver,
        sectionCheck = neverShowChatTimeIndicatorSectionChecker;

  /// The general builder for the indicator
  final ChatTimeIndicatorBuilder indicatorBuilder;

  /// A function that translates offset / time to a string label
  final ChatTimeIndicatorLabelResolver labelResolver;

  /// A function that determines when a new section starts
  ///
  /// By default, all messages are prefixed with a message.
  /// You can disable this using the [skipFirstChatTimeIndicatorSectionChecker]
  /// instead of the default, which would skip the first section
  final ChatTimeIndicatorSectionChecker sectionCheck;

  /// public method on the options for readability
  bool isMessageInNewTimeSection(
    BuildContext context,
    MessageModel? previousMessage,
    MessageModel currentMessage,
  ) =>
      sectionCheck(
        context,
        previousMessage,
        currentMessage,
      );
}

/// A function that would generate a string given the current window/datetime
typedef ChatTimeIndicatorLabelResolver = String Function(
  BuildContext context,
  int dayOffset,
  DateTime currentWindow,
);

/// A function that would determine if a chat indicator has to render
typedef ChatTimeIndicatorSectionChecker = bool Function(
  BuildContext context,
  MessageModel? previousMessage,
  MessageModel currentMessage,
);

/// Build used to render time indicators on chat detail screens
typedef ChatTimeIndicatorBuilder = Widget Function(
  BuildContext context,
  String timeLabel,
);

///
String defaultChatTimeIndicatorLabelResolver(
  BuildContext context,
  int dayOffset,
  DateTime currentWindow,
) {
  var translations = ChatScope.of(context).options.translations;
  return translations.chatTimeIndicatorLabel(dayOffset, currentWindow);
}

/// A function that disables the time indicator in chat
bool neverShowChatTimeIndicatorSectionChecker(
  BuildContext context,
  MessageModel? previousMessage,
  MessageModel currentMessage,
) =>
    false;

/// Variant of the default implementation for determining if a new section
/// starts, where the first section is skipped.
///
/// Renders a new indicator every new section, skipping the first section
bool skipFirstChatTimeIndicatorSectionChecker(
  BuildContext context,
  MessageModel? previousMessage,
  MessageModel currentMessage,
) =>
    previousMessage != null &&
    previousMessage.timestamp.date.isBefore(currentMessage.timestamp.date);

/// Default implementation for determining if a new section starts.
///
/// Renders a new indicator every new section
bool defaultChatTimeIndicatorSectionChecker(
  BuildContext context,
  MessageModel? previousMessage,
  MessageModel currentMessage,
) =>
    previousMessage == null ||
    previousMessage.timestamp.date.isBefore(currentMessage.timestamp.date);
