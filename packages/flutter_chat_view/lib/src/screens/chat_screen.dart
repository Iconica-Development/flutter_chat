// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_view/flutter_chat_view.dart';
import 'package:flutter_chat_view/src/services/date_formatter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    required this.options,
    required this.onPressStartChat,
    required this.onPressChat,
    required this.onDeleteChat,
    required this.service,
    this.unreadMessageTextStyle,
    this.onNoChats,
    this.deleteChatDialog,
    this.translations = const ChatTranslations.empty(),
    this.disableDismissForPermanentChats = false,
    super.key,
  });

  /// Chat options.
  final ChatOptions options;

  /// Chat service instance.
  final ChatService service;

  /// Callback function for starting a chat.
  final Function()? onPressStartChat;

  /// Callback function for pressing on a chat.
  final void Function(ChatModel chat) onPressChat;

  /// Callback function for deleting a chat.
  final void Function(ChatModel chat) onDeleteChat;

  /// Callback function for handling when there are no chats.
  final Function()? onNoChats;

  /// Method to optionally change the bottom sheet dialog.
  final Future<bool?> Function(BuildContext, ChatModel)? deleteChatDialog;

  /// Translations for the chat.
  final ChatTranslations translations;

  /// Disables the swipe to dismiss feature for chats that are not deletable.
  final bool disableDismissForPermanentChats;
  final TextStyle? unreadMessageTextStyle;

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
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var translations = widget.translations;
    var theme = Theme.of(context);
    return widget.options.scaffoldBuilder(
      AppBar(
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? const Color(0xff212121),
        title: Text(
          translations.chatsTitle,
          style: theme.appBarTheme.titleTextStyle ??
              const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 24,
                color: Color(0xff71C6D1),
              ),
        ),
        centerTitle: true,
        actions: [
          StreamBuilder<int>(
            stream:
                widget.service.chatOverviewService.getUnreadChatsCountStream(),
            builder: (BuildContext context, snapshot) => Align(
              alignment: Alignment.centerRight,
              child: Visibility(
                visible: (snapshot.data ?? 0) > 0,
                child: Padding(
                  padding: const EdgeInsets.only(right: 22.0),
                  child: Text(
                    '${snapshot.data ?? 0} ${translations.chatsUnread}',
                    style: widget.unreadMessageTextStyle ??
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
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
            child: ListView(
              controller: controller,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
              children: [
                StreamBuilder<List<ChatModel>>(
                  stream: widget.service.chatOverviewService.getChatsStream(),
                  builder: (BuildContext context, snapshot) {
                    // if the stream is done, empty and noChats is set we should call that
                    if (snapshot.connectionState == ConnectionState.done &&
                            (snapshot.data?.isEmpty ?? true) ||
                        (snapshot.data != null && snapshot.data!.isEmpty)) {
                      if (widget.onNoChats != null && !_hasCalledOnNoChats) {
                        _hasCalledOnNoChats = true; // Set the flag to true
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          await widget.onNoChats!.call();
                        });
                      }
                      return Center(
                        child: Text(
                          translations.noChatsFound,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      );
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
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Text(
                                                  chat.canBeDeleted
                                                      ? translations
                                                          .deleteChatModalTitle
                                                      : translations
                                                          .chatCantBeDeleted,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                if (chat.canBeDeleted)
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 16,
                                                    ),
                                                    child: Text(
                                                      translations
                                                          .deleteChatModalDescription,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ),
                                                const SizedBox(
                                                  height: 24,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () =>
                                                          Navigator.of(
                                                        context,
                                                      ).pop(false),
                                                      child: Text(
                                                        translations
                                                            .deleteChatModalCancel,
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ),
                                                    if (chat.canBeDeleted)
                                                      const SizedBox(
                                                        width: 16,
                                                      ),
                                                    if (chat.canBeDeleted)
                                                      ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              const Color
                                                                  .fromRGBO(
                                                            113,
                                                            198,
                                                            209,
                                                            1,
                                                          ),
                                                        ),
                                                        onPressed: () =>
                                                            Navigator.of(
                                                          context,
                                                        ).pop(
                                                          true,
                                                        ),
                                                        child: Text(
                                                          translations
                                                              .deleteChatModalConfirm,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
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
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          if (widget.onPressStartChat != null)
            widget.options.newChatButtonBuilder(
              context,
              () async {
                await widget.onPressStartChat!.call();
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
  Widget build(BuildContext context) => Column(
        children: [
          GestureDetector(
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
                                ? (chat.lastMessage! as ChatTextMessageModel)
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
                        unreadMessages: chat.unreadMessages ?? 0,
                        subTitle: chat.lastMessage != null
                            ? chat.lastMessage is ChatTextMessageModel
                                ? (chat.lastMessage! as ChatTextMessageModel)
                                    .text
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
          ),
        ],
      );
}
