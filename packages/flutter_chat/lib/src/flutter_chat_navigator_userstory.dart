// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_chat/flutter_chat.dart';

Widget chatNavigatorUserStory(
    ChatUserStoryConfiguration configuration, BuildContext context) {
  return _chatScreenRoute(configuration, context);
}

Widget _chatScreenRoute(
    ChatUserStoryConfiguration configuration, BuildContext context) {
  return ChatScreen(
    service: configuration.chatService,
    options: configuration.chatOptionsBuilder(context),
    onNoChats: () async => await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _newChatScreenRoute(
          configuration,
          context,
        ),
      ),
    ),
    onPressStartChat: () async {
      if (configuration.onPressStartChat != null) {
        return await configuration.onPressStartChat?.call();
      }

      return await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => _newChatScreenRoute(
            configuration,
            context,
          ),
        ),
      );
    },
    onPressChat: (chat) async =>
        configuration.onPressChat?.call(context, chat) ??
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _chatDetailScreenRoute(
              configuration,
              context,
              chat.id!,
            ),
          ),
        ),
    onDeleteChat: (chat) =>
        configuration.onDeleteChat?.call(context, chat) ??
        configuration.chatService.chatOverviewService.deleteChat(chat),
    deleteChatDialog: configuration.deleteChatDialog,
    translations: configuration.translations,
  );
}

Widget _chatDetailScreenRoute(ChatUserStoryConfiguration configuration,
    BuildContext context, String chatId) {
  return ChatDetailScreen(
    pageSize: configuration.messagePageSize,
    options: configuration.chatOptionsBuilder(context),
    translations: configuration.translations,
    service: configuration.chatService,
    chatId: chatId,
    onMessageSubmit: (message) async {
      configuration.onMessageSubmit?.call(message) ??
          configuration.chatService.chatDetailService
              .sendTextMessage(chatId: chatId, text: message);
      configuration.afterMessageSent?.call(chatId);
    },
    onUploadImage: (image) async {
      configuration.onUploadImage?.call(image) ??
          configuration.chatService.chatDetailService
              .sendImageMessage(chatId: chatId, image: image);
      configuration.afterMessageSent?.call(chatId);
    },
    onReadChat: (chat) =>
        configuration.onReadChat?.call(chat) ??
        configuration.chatService.chatOverviewService.readChat(chat),
    onPressChatTitle: (context, chat) async {
      if (configuration.onPressChatTitle?.call(context, chat) != null) {
        return configuration.onPressChatTitle?.call(context, chat);
      }

      return await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => _chatProfileScreenRoute(
            configuration,
            context,
            chatId,
            null,
          ),
        ),
      );
    },
    iconColor: configuration.iconColor,
  );
}

Widget _chatProfileScreenRoute(ChatUserStoryConfiguration configuration,
    BuildContext context, String chatId, String? userId) {
  return ChatProfileScreen(
    translations: configuration.translations,
    chatService: configuration.chatService,
    chatId: chatId,
    userId: userId,
    onTapUser: (user) async {
      if (configuration.onPressUserProfile != null) {
        return configuration.onPressUserProfile!.call();
      }

      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => _chatProfileScreenRoute(
            configuration,
            context,
            chatId,
            userId,
          ),
        ),
      );
    },
  );
}

Widget _newChatScreenRoute(
    ChatUserStoryConfiguration configuration, BuildContext context) {
  return NewChatScreen(
    options: configuration.chatOptionsBuilder(context),
    translations: configuration.translations,
    service: configuration.chatService,
    onPressCreateChat: (user) async {
      configuration.onPressCreateChat?.call(user);
      if (configuration.onPressCreateChat != null) return;
      var chat = await configuration.chatService.chatOverviewService
          .getChatByUser(user);
      if (chat.id == null) {
        chat =
            await configuration.chatService.chatOverviewService.storeChatIfNot(
          PersonalChatModel(
            user: user,
          ),
        );
      }
      if (context.mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _chatDetailScreenRoute(
              configuration,
              context,
              chat.id!,
            ),
          ),
        );
      }
    },
  );
}
