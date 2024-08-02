import 'dart:ui';

import 'package:flutter_chat/src/config/chat_builders.dart';
import 'package:flutter_chat/src/config/chat_translations.dart';

class ChatOptions {
  final String Function(bool showFullDate, DateTime date)? dateformat;
  final ChatTranslations translations;
  final ChatBuilders builders;
  final bool groupChatEnabled;
  final bool showTimes;
  final Color iconEnabledColor;
  final Color iconDisabledColor;
  final Function? onNoChats;
  final int pageSize;

  ChatOptions({
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
}
