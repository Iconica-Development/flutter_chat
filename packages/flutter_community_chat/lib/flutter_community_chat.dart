// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

library flutter_community_chat;

import 'package:flutter/material.dart';
import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';
import 'package:flutter_community_chat_view/flutter_community_chat_view.dart';
export 'package:flutter_community_chat_view/flutter_community_chat_view.dart';
export 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';

class CommunityChat extends StatefulWidget {
  const CommunityChat({
    required this.dataProvider,
    this.translations = const ChatTranslations(),
    this.options = const ChatOptions(),
    super.key,
  });

  final ChatDataProvider dataProvider;
  final ChatOptions options;
  final ChatTranslations translations;

  @override
  State<CommunityChat> createState() => _CommunityChatState();
}

class _CommunityChatState extends State<CommunityChat> {
  bool _isFetchingUsers = false;

  @override
  Widget build(BuildContext context) {
    Future<void> push(Widget widget) => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => widget),
        );

    void pop() => Navigator.of(context).pop();

    Future<void> onPressChat(
      ChatModel chat, {
      bool popBeforePush = false,
    }) async {
      if (popBeforePush) {
        pop();
      }
      // push(
      //   ChatDetailScreen(
      //     options: widget.options,
      //     translations: widget.translations,
      //     chat: chat,
      //     chatMessages: widget.dataProvider.messageService.getMessagesStream(),
      //     onUploadImage: widget.dataProvider.messageService.sendImageMessage,
      //     onMessageSubmit: widget.dataProvider.messageService.sendTextMessage,
      //   ),
      // );
    }

    Future<void> onPressStartChat() async {
      if (!_isFetchingUsers) {
        _isFetchingUsers = true;
        await widget.dataProvider.userService.getAllUsers().then(
          (users) {
            _isFetchingUsers = false;
            push(
              NewChatScreen(
                options: widget.options,
                translations: widget.translations,
                onPressCreateChat: (user) => onPressChat(
                  PersonalChatModel(user: user),
                  popBeforePush: true,
                ),
                users: users,
              ),
            );
          },
        );
      }
    }

    return ChatScreen(
      chats: widget.dataProvider.chatService.getChatsStream(),
      onPressStartChat: () => onPressStartChat(),
      onPressChat: (chat) => onPressChat(chat),
      onDeleteChat: (PersonalChatModel chat) =>
          widget.dataProvider.chatService.deleteChat(chat),
      options: widget.options,
      translations: widget.translations,
    );
  }
}
