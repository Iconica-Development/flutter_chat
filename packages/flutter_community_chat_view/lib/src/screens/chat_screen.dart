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
  Widget build(BuildContext context) {
    return widget.options.scaffoldBuilder(
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
                      for (ChatModel chat in snapshot.data ?? []) ...[
                        Builder(
                          builder: (context) => Dismissible(
                            confirmDismiss: (_) => showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: Text(
                                  widget.translations.deleteChatModalTitle,
                                ),
                                content: Text(
                                  widget
                                      .translations.deleteChatModalDescription,
                                ),
                                actions: [
                                  TextButton(
                                    child: Text(
                                      widget.translations.deleteChatModalCancel,
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text(
                                      widget
                                          .translations.deleteChatModalConfirm,
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
                                    widget.translations.deleteChatButton,
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
                                        avatar:
                                            widget.options.userAvatarBuilder(
                                          chat.user,
                                          40.0,
                                        ),
                                        title: chat.user.fullName,
                                        subTitle: chat.lastMessage != null &&
                                                chat.lastMessage
                                                    is ChatTextMessageModel
                                            ? (chat.lastMessage!
                                                    as ChatTextMessageModel)
                                                .text
                                            : '📷 ${widget.translations.image}',
                                        lastUsed: chat.lastUsed != null
                                            ? _dateFormatter.format(
                                                date: chat.lastUsed!,
                                              )
                                            : null,
                                      )
                                    : ChatRow(
                                        title: (chat as GroupChatModel).title,
                                        subTitle: chat.lastMessage != null &&
                                                chat.lastMessage
                                                    is ChatTextMessageModel
                                            ? (chat.lastMessage!
                                                    as ChatTextMessageModel)
                                                .text
                                            : '📷 '
                                                '${widget.translations.image}',
                                        avatar:
                                            widget.options.groupAvatarBuilder(
                                          chat.imageUrl,
                                          40.0,
                                        ),
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
              widget.translations,
            ),
        ],
      ),
    );
  }
}
