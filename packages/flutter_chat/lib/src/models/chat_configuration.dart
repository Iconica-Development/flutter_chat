// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_chat_view/flutter_chat_view.dart';

@immutable
class ChatUserStoryConfiguration {
  const ChatUserStoryConfiguration({
    required this.chatService,
    required this.chatOptionsBuilder,
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
    this.onPressUserProfile,
  });
  final ChatService chatService;
  final Function(BuildContext, ChatModel)? onPressChat;
  final Function(BuildContext, ChatModel)? onDeleteChat;
  final ChatTranslations translations;
  final bool disableDismissForPermanentChats;
  final Future<void> Function(Uint8List image)? onUploadImage;
  final Future<void> Function(String text)? onMessageSubmit;

  /// Called after a new message is sent. This can be used to do something extra
  /// like sending a push notification.
  final Function(String chatId)? afterMessageSent;
  final Future<void> Function(ChatModel chat)? onReadChat;
  final Function(ChatUserModel)? onPressCreateChat;
  final ChatOptions Function(BuildContext context) chatOptionsBuilder;

  /// If true, the user will be routed to the new chat screen if there 
  /// are no chats.
  final bool routeToNewChatIfEmpty;
  final int messagePageSize;

  final Future<bool?> Function(BuildContext, ChatModel)? deleteChatDialog;
  final Function(BuildContext context, ChatModel chat)? onPressChatTitle;
  final Color? iconColor;
  final Widget Function(BuildContext context, Widget child)? chatPageBuilder;
  final Function()? onPressStartChat;
  final Function()? onPressUserProfile;
}
