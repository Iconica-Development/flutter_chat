// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';
import 'package:flutter_community_chat_view/flutter_community_chat_view.dart';
import 'package:flutter_community_chat_view/src/services/date_formatter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    required this.options,
    required this.chats,
    required this.onPressStartChat,
    required this.onPressChat,
    this.translations = const ChatTranslations(),
    super.key,
  });

  final ChatOptions options;
  final ChatTranslations translations;
  final Stream<List<ChatModel>> chats;
  final VoidCallback? onPressStartChat;
  final void Function(ChatModel chat) onPressChat;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DateFormatter _dateFormatter = DateFormatter();

  @override
  Widget build(BuildContext context) => widget.options.scaffoldBuilder(
        AppBar(
          title: Text(widget.translations.chatsTitle),
        ),
        Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(
                  top: 15.0,
                ),
                children: [
                  StreamBuilder<List<ChatModel>>(
                    stream: widget.chats,
                    builder: (BuildContext context, snapshot) => Column(
                      children: [
                        for (ChatModel chat in snapshot.data ?? [])
                          GestureDetector(
                            onTap: () => widget.onPressChat(chat),
                            child: widget.options.chatRowContainerBuilder(
                              ChatRow(
                                image: chat is PersonalChatModel
                                    ? chat.user.imageUrl
                                    : (chat as GroupChatModel).imageUrl,
                                title: chat is PersonalChatModel
                                    ? chat.user.name ?? ''
                                    : (chat as GroupChatModel).title,
                                subTitle: chat.lastMessage != null
                                    ? chat.lastMessage is ChatTextMessageModel
                                        ? (chat.lastMessage!
                                                as ChatTextMessageModel)
                                            .text
                                        : '📷 ${widget.translations.image}'
                                    : null,
                                lastUsed: chat.lastUsed != null
                                    ? _dateFormatter.format(
                                        date: chat.lastUsed!,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (widget.onPressStartChat != null)
              widget.options.newChatButtonBuilder(
                context,
                widget.onPressStartChat!,
                widget.translations,
              ),
          ],
        ),
      );
}
