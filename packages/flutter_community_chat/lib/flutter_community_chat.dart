// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

library flutter_community_chat;

import 'package:flutter/material.dart';
import 'package:flutter_community_chat/service/chat_service.dart';
import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';
import 'package:flutter_community_chat_view/flutter_community_chat_view.dart';
export 'package:flutter_community_chat_view/flutter_community_chat_view.dart';
export 'package:flutter_community_chat/service/chat_service.dart';
export 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';

class CommunityChat extends StatelessWidget {
  const CommunityChat({
    required this.chatService,
    super.key,
  });

  final ChatService chatService;

  @override
  Widget build(BuildContext context) => ChatScreen(
        chats: chatService.dataProvider.getChatsStream(),
        onPressStartChat: () => chatService.onPressStartChat(context),
        onPressChat: (chat) => chatService.onPressChat(context, chat),
        onDeleteChat: (ChatModel chat) => chatService.deleteChat(chat),
        options: chatService.options,
        translations: chatService.translations(context),
      );
}
