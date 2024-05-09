// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_chat/flutter_chat.dart';
import 'package:flutter_chat/src/go_router.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> getChatStoryRoutes(
  ChatUserStoryConfiguration configuration,
) =>
    <GoRoute>[
      GoRoute(
        path: ChatUserStoryRoutes.chatScreen,
        pageBuilder: (context, state) {
          var service = configuration.chatServiceBuilder?.call(context) ??
              configuration.chatService;
          var chatScreen = ChatScreen(
            unreadMessageTextStyle: configuration.unreadMessageTextStyle,
            service: service,
            options: configuration.chatOptionsBuilder(context),
            onNoChats: () async =>
                context.push(ChatUserStoryRoutes.newChatScreen),
            onPressStartChat: () async {
              if (configuration.onPressStartChat != null) {
                return await configuration.onPressStartChat?.call();
              }

              return context.push(ChatUserStoryRoutes.newChatScreen);
            },
            onPressChat: (chat) async =>
                configuration.onPressChat?.call(context, chat) ??
                context.push(ChatUserStoryRoutes.chatDetailViewPath(chat.id!)),
            onDeleteChat: (chat) async =>
                configuration.onDeleteChat?.call(context, chat) ??
                configuration.chatService.chatOverviewService.deleteChat(chat),
            deleteChatDialog: configuration.deleteChatDialog,
            translations: configuration.translationsBuilder?.call(context) ??
                configuration.translations,
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
        path: ChatUserStoryRoutes.chatDetailScreen,
        pageBuilder: (context, state) {
          var chatId = state.pathParameters['id'];
          var service = configuration.chatServiceBuilder?.call(context) ??
              configuration.chatService;
          var chatDetailScreen = ChatDetailScreen(
            chatTitleBuilder: configuration.chatTitleBuilder,
            usernameBuilder: configuration.usernameBuilder,
            loadingWidgetBuilder: configuration.loadingWidgetBuilder,
            iconDisabledColor: configuration.iconDisabledColor,
            pageSize: configuration.messagePageSize,
            options: configuration.chatOptionsBuilder(context),
            translations: configuration.translationsBuilder?.call(context) ??
                configuration.translations,
            service: service,
            chatId: chatId!,
            textfieldBottomPadding: configuration.textfieldBottomPadding ?? 0,
            onPressUserProfile: (user) async {
              if (configuration.onPressUserProfile != null) {
                return configuration.onPressUserProfile?.call(context, user);
              }
              return context.push(
                ChatUserStoryRoutes.chatProfileScreenPath(chatId, user.id),
              );
            },
            onMessageSubmit: (message) async {
              if (configuration.onMessageSubmit != null) {
                await configuration.onMessageSubmit?.call(message);
              } else {
                await configuration.chatService.chatDetailService
                    .sendTextMessage(chatId: chatId, text: message);
              }
              configuration.afterMessageSent?.call(chatId);
            },
            onUploadImage: (image) async {
              if (configuration.onUploadImage?.call(image) != null) {
                await configuration.onUploadImage?.call(image);
              } else {
                await configuration.chatService.chatDetailService
                    .sendImageMessage(chatId: chatId, image: image);
              }
              configuration.afterMessageSent?.call(chatId);
            },
            onReadChat: (chat) async =>
                configuration.onReadChat?.call(chat) ??
                configuration.chatService.chatOverviewService.readChat(chat),
            onPressChatTitle: (context, chat) async {
              if (configuration.onPressChatTitle?.call(context, chat) != null) {
                return configuration.onPressChatTitle?.call(context, chat);
              }

              return context.push(
                ChatUserStoryRoutes.chatProfileScreenPath(chat.id!, null),
              );
            },
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
        path: ChatUserStoryRoutes.newChatScreen,
        pageBuilder: (context, state) {
          var service = configuration.chatServiceBuilder?.call(context) ??
              configuration.chatService;
          var newChatScreen = NewChatScreen(
            options: configuration.chatOptionsBuilder(context),
            translations: configuration.translationsBuilder?.call(context) ??
                configuration.translations,
            service: service,
            onPressCreateChat: (user) async {
              configuration.onPressCreateChat?.call(user);
              if (configuration.onPressCreateChat != null) return;
              var chat = await configuration.chatService.chatOverviewService
                  .getChatByUser(user);
              if (chat.id == null) {
                chat = await configuration.chatService.chatOverviewService
                    .storeChatIfNot(
                  PersonalChatModel(
                    user: user,
                  ),
                );
              }
              if (context.mounted) {
                await context.push(
                  ChatUserStoryRoutes.chatDetailViewPath(chat.id ?? ''),
                );
              }
            },
            onPressCreateGroupChat: () async => context.push(
              ChatUserStoryRoutes.newGroupChatScreen,
            ),
          );
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
      GoRoute(
        path: ChatUserStoryRoutes.newGroupChatScreen,
        pageBuilder: (context, state) {
          var service = configuration.chatServiceBuilder?.call(context) ??
              configuration.chatService;
          var newGroupChatScreen = NewGroupChatScreen(
            options: configuration.chatOptionsBuilder(context),
            translations: configuration.translationsBuilder?.call(context) ??
                configuration.translations,
            service: service,
            onPressGroupChatOverview: (users) async => context.push(
              ChatUserStoryRoutes.newGroupChatOverviewScreen,
              extra: users,
            ),
          );
          return buildScreenWithoutTransition(
            context: context,
            state: state,
            child: configuration.chatPageBuilder?.call(
                  context,
                  newGroupChatScreen,
                ) ??
                Scaffold(
                  body: newGroupChatScreen,
                ),
          );
        },
      ),
      GoRoute(
        path: ChatUserStoryRoutes.newGroupChatOverviewScreen,
        pageBuilder: (context, state) {
          var service = configuration.chatServiceBuilder?.call(context) ??
              configuration.chatService;
          var users = state.extra! as List<ChatUserModel>;
          var newGroupChatOverviewScreen = NewGroupChatOverviewScreen(
            options: configuration.chatOptionsBuilder(context),
            translations: configuration.translationsBuilder?.call(context) ??
                configuration.translations,
            service: service,
            users: users,
            onPressCompleteGroupChatCreation: (users, groupChatName) async {
              configuration.onPressCompleteGroupChatCreation
                  ?.call(users, groupChatName);
              var chat = await configuration.chatService.chatOverviewService
                  .storeChatIfNot(
                GroupChatModel(
                  canBeDeleted: true,
                  title: groupChatName,
                  imageUrl: 'https://picsum.photos/200/300',
                  users: users,
                ),
              );
              if (context.mounted) {
                await context.push(
                  ChatUserStoryRoutes.chatDetailViewPath(chat.id ?? ''),
                );
              }
            },
          );
          return buildScreenWithoutTransition(
            context: context,
            state: state,
            child: configuration.chatPageBuilder?.call(
                  context,
                  newGroupChatOverviewScreen,
                ) ??
                Scaffold(
                  body: newGroupChatOverviewScreen,
                ),
          );
        },
      ),
      GoRoute(
        path: ChatUserStoryRoutes.chatProfileScreen,
        pageBuilder: (context, state) {
          var chatId = state.pathParameters['id'];
          var userId = state.pathParameters['userId'];
          var id = userId == 'null' ? null : userId;
          var service = configuration.chatServiceBuilder?.call(context) ??
              configuration.chatService;
          var profileScreen = ChatProfileScreen(
            translations: configuration.translationsBuilder?.call(context) ??
                configuration.translations,
            chatService: service,
            chatId: chatId!,
            userId: id,
            onTapUser: (user) async {
              if (configuration.onPressUserProfile != null) {
                return configuration.onPressUserProfile!.call(context, user);
              }

              return context.push(
                ChatUserStoryRoutes.chatProfileScreenPath(chatId, user.id),
              );
            },
          );
          return buildScreenWithoutTransition(
            context: context,
            state: state,
            child: configuration.chatPageBuilder?.call(
                  context,
                  profileScreen,
                ) ??
                Scaffold(
                  body: profileScreen,
                ),
          );
        },
      ),
    ];
