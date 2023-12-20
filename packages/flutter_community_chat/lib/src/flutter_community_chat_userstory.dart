// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_community_chat/src/models/community_chat_configuration.dart';
import 'package:flutter_community_chat/src/go_router.dart';
import 'package:flutter_community_chat/src/routes.dart';
import 'package:flutter_community_chat_view/flutter_community_chat_view.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> getCommunityChatStoryRoutes(
  CommunityChatUserStoryConfiguration configuration,
) =>
    <GoRoute>[
      GoRoute(
        path: CommunityChatUserStoryRoutes.chatScreen,
        pageBuilder: (context, state) {
          var chatScreen = ChatScreen(
            pageSize: configuration.pageSize,
            service: configuration.service,
            options: configuration.chatOptionsBuilder(context),
            onNoChats: () async =>
                await context.push(CommunityChatUserStoryRoutes.newChatScreen),
            onPressStartChat: () async =>
                await configuration.onPressStartChat?.call() ??
                await context.push(CommunityChatUserStoryRoutes.newChatScreen),
            onPressChat: (chat) =>
                configuration.onPressChat?.call(context, chat) ??
                context.push(
                    CommunityChatUserStoryRoutes.chatDetailViewPath(chat.id!)),
            onDeleteChat: (chat) =>
                configuration.onDeleteChat?.call(context, chat) ??
                configuration.service.deleteChat(chat),
            deleteChatDialog: configuration.deleteChatDialog,
            translations: configuration.translations,
          );
          return buildScreenWithoutTransition(
            context: context,
            state: state,
            child: configuration.chatPageBuilder?.call(
                  context,
                  chatScreen,
                ) ??
                Scaffold(
                  body: chatScreen,
                ),
          );
        },
      ),
      GoRoute(
        path: CommunityChatUserStoryRoutes.chatDetailScreen,
        pageBuilder: (context, state) {
          var chatId = state.pathParameters['id'];
          var chat = PersonalChatModel(user: ChatUserModel(), id: chatId);
          var chatDetailScreen = ChatDetailScreen(
            pageSize: configuration.messagePageSize,
            options: configuration.chatOptionsBuilder(context),
            translations: configuration.translations,
            chatUserService: configuration.userService,
            service: configuration.service,
            messageService: configuration.messageService,
            chat: chat,
            onMessageSubmit: (message) async {
              configuration.onMessageSubmit?.call(message) ??
                  configuration.messageService
                      .sendTextMessage(chat: chat, text: message);
              configuration.afterMessageSent?.call(chat);
            },
            onUploadImage: (image) async {
              configuration.onUploadImage?.call(image) ??
                  configuration.messageService
                      .sendImageMessage(chat: chat, image: image);
              configuration.afterMessageSent?.call(chat);
            },
            onReadChat: (chat) =>
                configuration.onReadChat?.call(chat) ??
                configuration.service.readChat(chat),
            onPressChatTitle: (context, chat) =>
                configuration.onPressChatTitle?.call(context, chat),
            iconColor: configuration.iconColor,
          );
          return buildScreenWithoutTransition(
            context: context,
            state: state,
            child: configuration.chatPageBuilder?.call(
                  context,
                  chatDetailScreen,
                ) ??
                Scaffold(
                  body: chatDetailScreen,
                ),
          );
        },
      ),
      GoRoute(
        path: CommunityChatUserStoryRoutes.newChatScreen,
        pageBuilder: (context, state) {
          var newChatScreen = NewChatScreen(
              options: configuration.chatOptionsBuilder(context),
              translations: configuration.translations,
              service: configuration.service,
              userService: configuration.userService,
              onPressCreateChat: (user) async {
                configuration.onPressCreateChat?.call(user);
                if (configuration.onPressChat != null) return;
                var chat = await configuration.service.getChatByUser(user);
                if (chat.id == null) {
                  chat = await configuration.service.storeChatIfNot(
                    PersonalChatModel(
                      user: user,
                    ),
                  );
                }
                if (context.mounted) {
                  await context.push(
                      CommunityChatUserStoryRoutes.chatDetailViewPath(
                          chat.id ?? ''));
                }
              });
          return buildScreenWithoutTransition(
            context: context,
            state: state,
            child: configuration.chatPageBuilder?.call(
                  context,
                  newChatScreen,
                ) ??
                Scaffold(
                  body: newChatScreen,
                ),
          );
        },
      ),
    ];
