import "dart:ui";

import "package:flutter_chat/src/config/chat_builders.dart";
import "package:flutter_chat/src/config/chat_translations.dart";

/// The chat options
/// Use this class to configure the chat options.
class ChatOptions {
  /// The chat options constructor
  const ChatOptions({
    this.dateformat,
    this.groupChatEnabled = true,
    this.showTimes = true,
    this.translations = const ChatTranslations.empty(),
    this.builders = const ChatBuilders(),
    this.iconEnabledColor = const Color(0xFF212121),
    this.iconDisabledColor = const Color(0xFF9E9E9E),
    this.onNoChats,
    this.pageSize = 20,
  });

  /// [dateformat] is a function that formats the date.
  // ignore: avoid_positional_boolean_parameters
  final String Function(bool showFullDate, DateTime date)? dateformat;

  /// [translations] is the chat translations.
  final ChatTranslations translations;

  /// [builders] is the chat builders.
  final ChatBuilders builders;

  /// [groupChatEnabled] is a boolean that indicates if group chat is enabled.
  final bool groupChatEnabled;

  /// [showTimes] is a boolean that indicates if the chat times are shown.
  final bool showTimes;

  /// [iconEnabledColor] is the color of the enabled icon.
  final Color iconEnabledColor;

  /// [iconDisabledColor] is the color of the disabled icon.
  final Color iconDisabledColor;

  /// [onNoChats] is a function that is triggered when there are no chats.
  final Function? onNoChats;

  /// [pageSize] is the number of chats to load at a time.
  final int pageSize;
}
