// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_community_chat_view/flutter_community_chat_view.dart';

@immutable
class CommunityChatUserStoryConfiguration {
  const CommunityChatUserStoryConfiguration({
    required this.userService,
    required this.messageService,
    required this.service,
    required this.chatOptionsBuilder,
    this.pageSize = 10,
    this.onPressStartChat,
    this.onPressChat,
    this.onDeleteChat,
    this.onMessageSubmit,
    this.onReadChat,
    this.onUploadImage,
    this.onPressCreateChat,
    this.iconColor,
    this.deleteChatDialog,
    this.disableDismissForPermanentChats = false,
    this.routeToNewChatIfEmpty = true,
    this.translations = const ChatTranslations(),
    this.chatPageBuilder,
    this.onPressChatTitle,
    this.afterMessageSent,
    this.messagePageSize = 20,
  });
  final ChatService service;
  final ChatUserService userService;
  final MessageService messageService;
  final Function(BuildContext, ChatModel)? onPressChat;
  final Function(BuildContext, ChatModel)? onDeleteChat;
  final ChatTranslations translations;
  final bool disableDismissForPermanentChats;
  final Future<void> Function(Uint8List image)? onUploadImage;
  final Future<void> Function(String text)? onMessageSubmit;

  /// Called after a new message is sent. This can be used to do something extra like sending a push notification.
  final Function(ChatModel chat)? afterMessageSent;
  final Future<void> Function(ChatModel chat)? onReadChat;
  final Function(ChatUserModel)? onPressCreateChat;
  final ChatOptions Function(BuildContext context) chatOptionsBuilder;

  /// If true, the user will be routed to the new chat screen if there are no chats.
  final bool routeToNewChatIfEmpty;
  final int pageSize;
  final int messagePageSize;

  final Future<bool?> Function(BuildContext, ChatModel)? deleteChatDialog;
  final Function(BuildContext context, ChatModel chat)? onPressChatTitle;
  final Color? iconColor;
  final Widget Function(BuildContext context, Widget child)? chatPageBuilder;
  final Function()? onPressStartChat;
}
