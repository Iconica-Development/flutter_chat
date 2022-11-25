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
    required this.onDeleteChat,
    this.translations = const ChatTranslations(),
    super.key,
  });

  final ChatOptions options;
  final ChatTranslations translations;
  final Stream<List<ChatModel>> chats;
  final VoidCallback? onPressStartChat;
  final void Function(ChatModel chat) onDeleteChat;
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
                padding: const EdgeInsets.only(top: 15.0),
                children: [
                  StreamBuilder<List<ChatModel>>(
                    stream: widget.chats,
                    builder: (BuildContext context, snapshot) => Column(
                      children: [
                        for (ChatModel chat in snapshot.data ?? [])
                          Builder(
                            builder: (context) => Dismissible(
                              onDismissed: (_) => showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text(
                                    widget.translations.deleteChatModalTitle,
                                  ),
                                  content: Text(
                                    widget.translations
                                        .deleteChatModalDescription,
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        widget
                                            .translations.deleteChatModalCancel,
                                      ),
                                      onPressed: () {},
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          widget.onDeleteChat(chat),
                                      child: Text(
                                        widget.translations
                                            .deleteChatModalConfirm,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              background: Container(
                                color: Colors.red,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      widget.translations.deleteChatButton,
                                    ),
                                  ),
                                ),
                              ),
                              key: Key(
                                chat.id.toString(),
                              ),
                              child: GestureDetector(
                                onTap: () => widget.onPressChat(chat),
                                child: widget.options.chatRowContainerBuilder(
                                  ChatRow(
                                    avatar: chat is PersonalChatModel
                                        ? widget.options.userAvatarBuilder(
                                            chat.user,
                                            40.0,
                                          )
                                        : Container(),
                                    title: chat is PersonalChatModel
                                        ? chat.user.fullName
                                        : (chat as GroupChatModel).title,
                                    subTitle: chat.lastMessage != null
                                        ? chat.lastMessage
                                                is ChatTextMessageModel
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
