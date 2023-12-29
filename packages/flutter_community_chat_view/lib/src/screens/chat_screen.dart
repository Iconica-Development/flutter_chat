// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_community_chat_view/flutter_community_chat_view.dart';
import 'package:flutter_community_chat_view/src/services/date_formatter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    required this.options,
    required this.onPressStartChat,
    required this.onPressChat,
    required this.onDeleteChat,
    required this.service,
    required this.pageSize,
    this.onNoChats,
    this.deleteChatDialog,
    this.translations = const ChatTranslations(),
    this.disableDismissForPermanentChats = false,
    super.key,
  });

  final ChatOptions options;
  final ChatTranslations translations;
  final ChatService service;
  final Function()? onPressStartChat;
  final Function()? onNoChats;
  final void Function(ChatModel chat) onDeleteChat;
  final void Function(ChatModel chat) onPressChat;
  final int pageSize;

  /// Disable the swipe to dismiss feature for chats that are not deletable
  final bool disableDismissForPermanentChats;

  /// Method to optionally change the bottomsheetdialog
  final Future<bool?> Function(BuildContext, ChatModel)? deleteChatDialog;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DateFormatter _dateFormatter = DateFormatter();
  bool _hasCalledOnNoChats = false;
  ScrollController controller = ScrollController();
  bool showIndicator = false;
  Stream<List<ChatModel>>? chats;
  List<String> deletedChats = [];

  @override
  void initState() {
    getChats();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void getChats() {
    setState(() {
      chats = widget.service.getChatsStream(widget.pageSize);
    });
  }

  @override
  Widget build(BuildContext context) {
    var translations = widget.translations;
    return widget.options.scaffoldBuilder(
      AppBar(
        title: Text(translations.chatsTitle),
        centerTitle: true,
        actions: [
          StreamBuilder<int>(
            stream: widget.service.getUnreadChatsCountStream(),
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
        ],
      ),
      Column(
        children: [
          Expanded(
            child: Listener(
              onPointerMove: (event) {
                var isTop = controller.position.pixels ==
                    controller.position.maxScrollExtent;

                if (showIndicator == false &&
                    !isTop &&
                    controller.position.userScrollDirection ==
                        ScrollDirection.reverse) {
                  setState(() {
                    showIndicator = true;
                  });
                  getChats();
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() {
                        showIndicator = false;
                      });
                    }
                  });
                }
              },
              child: ListView(
                controller: controller,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 15.0),
                children: [
                  StreamBuilder<List<ChatModel>>(
                    stream: chats,
                    builder: (BuildContext context, snapshot) {
                      // if the stream is done, empty and noChats is set we should call that
                      if (snapshot.connectionState == ConnectionState.done &&
                          (snapshot.data?.isEmpty ?? true)) {
                        if (widget.onNoChats != null && !_hasCalledOnNoChats) {
                          _hasCalledOnNoChats = true; // Set the flag to true
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) async {
                            await widget.onNoChats!.call();
                            getChats();
                          });
                        }
                      } else {
                        _hasCalledOnNoChats =
                            false; // Reset the flag if there are chats
                      }
                      return Column(
                        children: [
                          for (ChatModel chat in (snapshot.data ?? []).where(
                            (chat) => !deletedChats.contains(chat.id),
                          )) ...[
                            Builder(
                              builder: (context) => !(widget
                                          .disableDismissForPermanentChats &&
                                      !chat.canBeDeleted)
                                  ? Dismissible(
                                      confirmDismiss: (_) async =>
                                          widget.deleteChatDialog
                                              ?.call(context, chat) ??
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                Container(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    chat.canBeDeleted
                                                        ? translations
                                                            .deleteChatModalTitle
                                                        : translations
                                                            .chatCantBeDeleted,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  if (chat.canBeDeleted)
                                                    Text(
                                                      translations
                                                          .deleteChatModalDescription,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  const SizedBox(height: 16),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      TextButton(
                                                        child: Text(
                                                          translations
                                                              .deleteChatModalCancel,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        onPressed: () =>
                                                            Navigator.of(
                                                          context,
                                                        ).pop(false),
                                                      ),
                                                      if (chat.canBeDeleted)
                                                        ElevatedButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                            context,
                                                          ).pop(true),
                                                          child: Text(
                                                            translations
                                                                .deleteChatModalConfirm,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      onDismissed: (_) {
                                        setState(() {
                                          deletedChats.add(chat.id!);
                                        });
                                        widget.onDeleteChat(chat);
                                      },
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
                                      child: ChatListItem(
                                        widget: widget,
                                        chat: chat,
                                        translations: translations,
                                        dateFormatter: _dateFormatter,
                                      ),
                                    )
                                  : ChatListItem(
                                      widget: widget,
                                      chat: chat,
                                      translations: translations,
                                      dateFormatter: _dateFormatter,
                                    ),
                            ),
                          ],
                          if (showIndicator &&
                              snapshot.connectionState !=
                                  ConnectionState.done) ...[
                            const SizedBox(
                              height: 10,
                            ),
                            const CircularProgressIndicator(),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          if (widget.onPressStartChat != null)
            widget.options.newChatButtonBuilder(
              context,
              () async {
                await widget.onPressStartChat!.call();
                getChats();
              },
              translations,
            ),
        ],
      ),
    );
  }
}

class ChatListItem extends StatelessWidget {
  const ChatListItem({
    required this.widget,
    required this.chat,
    required this.translations,
    required DateFormatter dateFormatter,
    super.key,
  }) : _dateFormatter = dateFormatter;

  final ChatScreen widget;
  final ChatModel chat;
  final ChatTranslations translations;
  final DateFormatter _dateFormatter;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onPressChat(chat),
      child: Container(
        color: Colors.transparent,
        child: widget.options.chatRowContainerBuilder(
          (chat is PersonalChatModel)
              ? ChatRow(
                  unreadMessages: chat.unreadMessages ?? 0,
                  avatar: widget.options.userAvatarBuilder(
                    (chat as PersonalChatModel).user,
                    40.0,
                  ),
                  title: (chat as PersonalChatModel).user.fullName ??
                      translations.anonymousUser,
                  subTitle: chat.lastMessage != null
                      ? chat.lastMessage is ChatTextMessageModel
                          ? (chat.lastMessage! as ChatTextMessageModel).text
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
                  unreadMessages: chat.unreadMessages ?? 0,
                  subTitle: chat.lastMessage != null
                      ? chat.lastMessage is ChatTextMessageModel
                          ? (chat.lastMessage! as ChatTextMessageModel).text
                          : '📷 '
                              '${translations.image}'
                      : '',
                  avatar: widget.options.groupAvatarBuilder(
                    (chat as GroupChatModel).title,
                    (chat as GroupChatModel).imageUrl,
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
    );
  }
}
