// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_chat_view/flutter_chat_view.dart';

/// `ChatUserStoryConfiguration` is a class that configures the chat user story.
@immutable
class ChatUserStoryConfiguration {
  /// Creates a new instance of `ChatUserStoryConfiguration`.
  const ChatUserStoryConfiguration({
    required this.chatService,
    required this.chatOptionsBuilder,
    this.chatServiceBuilder,
    this.onPressStartChat,
    this.onPressChat,
    this.onDeleteChat,
    this.onMessageSubmit,
    this.onReadChat,
    this.onUploadImage,
    this.onPressCreateChat,
    this.onPressCreateGroupChat,
    this.onPressCompleteGroupChatCreation,
    this.iconColor = Colors.black,
    this.deleteChatDialog,
    this.disableDismissForPermanentChats = false,
    this.routeToNewChatIfEmpty = true,
    this.translations = const ChatTranslations(),
    this.translationsBuilder,
    this.chatPageBuilder,
    this.onPressChatTitle,
    this.afterMessageSent,
    this.messagePageSize = 20,
    this.onPressUserProfile,
    this.textfieldBottomPadding = 20,
    this.iconDisabledColor = Colors.grey,
    this.unreadMessageTextStyle,
    this.loadingWidgetBuilder,
    this.usernameBuilder,
    this.chatTitleBuilder,
  });

  /// The service responsible for handling chat-related functionalities.
  final ChatService chatService;

  /// A method to get the chat service only when needed and with a context.
  final ChatService Function(BuildContext context)? chatServiceBuilder;

  /// Callback function triggered when a chat is pressed.
  final Function(BuildContext, ChatModel)? onPressChat;

  /// Callback function triggered when a chat is deleted.
  final Function(BuildContext, ChatModel)? onDeleteChat;

  /// Translations for internationalization/localization support.
  final ChatTranslations translations;

  /// Translations builder because context might be needed for translations.
  final ChatTranslations Function(BuildContext context)? translationsBuilder;

  /// Determines whether dismissing is disabled for permanent chats.
  final bool disableDismissForPermanentChats;

  /// Callback function for uploading an image.
  final Future<void> Function(Uint8List image)? onUploadImage;

  /// Callback function for submitting a message.
  final Future<void> Function(String text)? onMessageSubmit;

  /// Called after a new message is sent. This can be used to do something
  /// extra like sending a push notification.
  final Function(String chatId)? afterMessageSent;

  /// Callback function triggered when a chat is read.
  final Future<void> Function(ChatModel chat)? onReadChat;

  /// Callback function triggered when creating a chat.
  final Function(ChatUserModel)? onPressCreateChat;

  /// Builder for chat options based on context.
  final Function(List<ChatUserModel>, String)? onPressCompleteGroupChatCreation;
  final Function()? onPressCreateGroupChat;
  final ChatOptions Function(BuildContext context) chatOptionsBuilder;

  /// If true, the user will be routed to the new chat screen if there are
  /// no chats.
  final bool routeToNewChatIfEmpty;

  /// The size of each page of messages.
  final int messagePageSize;

  /// Dialog for confirming chat deletion.
  final Future<bool?> Function(BuildContext, ChatModel)? deleteChatDialog;

  /// Callback function triggered when chat title is pressed.
  final Function(BuildContext context, ChatModel chat)? onPressChatTitle;

  /// Color of icons.
  final Color? iconColor;

  /// Builder for the chat page.
  final Widget Function(BuildContext context, Widget child)? chatPageBuilder;

  /// Callback function triggered when starting a chat.
  final Function()? onPressStartChat;

  /// Callback function triggered when user profile is pressed.
  final Function()? onPressUserProfile;
  final double? textfieldBottomPadding;
  final Color? iconDisabledColor;
  final TextStyle? unreadMessageTextStyle;
  final Widget? Function(BuildContext context)? loadingWidgetBuilder;
  final Widget Function(String userFullName)? usernameBuilder;
  final Widget Function(String chatTitle)? chatTitleBuilder;
}
