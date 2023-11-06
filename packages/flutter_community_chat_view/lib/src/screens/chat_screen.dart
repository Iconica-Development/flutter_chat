// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_community_chat_view/flutter_community_chat_view.dart';
import 'package:flutter_community_chat_view/src/services/date_formatter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    required this.options,
    required this.chats,
    required this.onPressStartChat,
    required this.onPressChat,
    required this.onDeleteChat,
    this.unreadChats,
    this.translations = const ChatTranslations(),
    super.key,
  });

  final ChatOptions options;
  final ChatTranslations translations;
  final Stream<List<ChatModel>> chats;
  final Stream<int>? unreadChats;
  final VoidCallback? onPressStartChat;
  final void Function(ChatModel chat) onDeleteChat;
  final void Function(ChatModel chat) onPressChat;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DateFormatter _dateFormatter = DateFormatter();

  @override
  Widget build(BuildContext context) {
    var translations = widget.translations;
    return widget.options.scaffoldBuilder(
      AppBar(
        title: Text(translations.chatsTitle),
        centerTitle: true,
        actions: widget.unreadChats != null
            ? [
                StreamBuilder<int>(
                  stream: widget.unreadChats,
                  builder: (BuildContext context, snapshot) => Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 22.0),
                      child: Text(
                        '${snapshot.data ?? 0} ${translations.chatsUnread}',
                        style: const TextStyle(
                          color: Color(0xFFBBBBBB),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ]
            : [],
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
                      for (ChatModel chat in snapshot.data ?? []) ...[
                        Builder(
                          builder: (context) => Dismissible(
                            confirmDismiss: (_) => showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: Text(
                                  translations.deleteChatModalTitle,
                                ),
                                content: Text(
                                  translations.deleteChatModalDescription,
                                ),
                                actions: [
                                  TextButton(
                                    child: Text(
                                      translations.deleteChatModalCancel,
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text(
                                      translations.deleteChatModalConfirm,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onDismissed: (_) => widget.onDeleteChat(chat),
                            background: Container(
                              color: Colors.red,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    translations.deleteChatButton,
                                  ),
                                ),
                              ),
                            ),
                            key: ValueKey(
                              chat.id.toString(),
                            ),
                            child: GestureDetector(
                              onTap: () => widget.onPressChat(chat),
                              child: widget.options.chatRowContainerBuilder(
                                (chat is PersonalChatModel)
                                    ? ChatRow(
                                        unreadMessages:
                                            chat.unreadMessages ?? 0,
                                        avatar:
                                            widget.options.userAvatarBuilder(
                                          chat.user,
                                          40.0,
                                        ),
                                        title: chat.user.fullName ??
                                            translations.anonymousUser,
                                        subTitle: chat.lastMessage != null
                                            ? chat.lastMessage
                                                    is ChatTextMessageModel
                                                ? (chat.lastMessage!
                                                        as ChatTextMessageModel)
                                                    .text
                                                : '📷 '
                                                    '${translations.image}'
                                            : '',
                                        lastUsed: chat.lastUsed != null
                                            ? _dateFormatter.format(
                                                date: chat.lastUsed!,
                                              )
                                            : null,
                                      )
                                    : ChatRow(
                                        title: (chat as GroupChatModel).title,
                                        unreadMessages:
                                            chat.unreadMessages ?? 0,
                                        subTitle: chat.lastMessage != null
                                            ? chat.lastMessage
                                                    is ChatTextMessageModel
                                                ? (chat.lastMessage!
                                                        as ChatTextMessageModel)
                                                    .text
                                                : '📷 '
                                                    '${translations.image}'
                                            : '',
                                        avatar:
                                            widget.options.groupAvatarBuilder(
                                          chat.imageUrl,
                                          40.0,
                                        ),
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
              translations,
            ),
        ],
      ),
    );
  }
}
