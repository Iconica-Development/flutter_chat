// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:async";

import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_chat/src/config/chat_options.dart";
import "package:flutter_chat/src/screens/chat_detail/chat_detail_screen.dart";
import "package:flutter_chat/src/screens/chat_profile_screen.dart";
import "package:flutter_chat/src/screens/chat_screen.dart";
import "package:flutter_chat/src/screens/creation/new_chat_screen.dart";
import "package:flutter_chat/src/screens/creation/new_group_chat_overview.dart";
import "package:flutter_chat/src/screens/creation/new_group_chat_screen.dart";
import "package:flutter_chat/src/services/pop_handler.dart";
import "package:flutter_chat/src/util/scope.dart";

/// The flutter chat navigator userstory
/// [userId] is the id of the user
/// [chatService] is the chat service
/// [chatOptions] are the chat options
/// This widget is the entry point for the chat UI
class FlutterChatNavigatorUserstory extends StatefulWidget {
  /// Constructs a [FlutterChatNavigatorUserstory].
  const FlutterChatNavigatorUserstory({
    required this.userId,
    this.chatService,
    this.chatOptions,
    super.key,
  });

  /// The user ID of the person currently looking at the chat
  final String userId;

  /// The chat service associated with the widget.
  final ChatService? chatService;

  /// The chat options
  final ChatOptions? chatOptions;

  @override
  State<FlutterChatNavigatorUserstory> createState() =>
      _FlutterChatNavigatorUserstoryState();
}

class _FlutterChatNavigatorUserstoryState
    extends State<FlutterChatNavigatorUserstory> {
  late ChatService _service = widget.chatService ?? ChatService();

  late final PopHandler _popHandler = PopHandler();

  @override
  Widget build(BuildContext context) => ChatScope(
        userId: widget.userId,
        options: widget.chatOptions ?? const ChatOptions(),
        service: _service,
        popHandler: _popHandler,
        child: NavigatorPopHandler(
          // ignore: deprecated_member_use
          onPop: _popHandler.handlePop,
          child: Navigator(
            key: const ValueKey(
              "chat_navigator",
            ),
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (context) => _NavigatorWrapper(
                userId: widget.userId,
                chatService: _service,
                chatOptions: widget.chatOptions ?? const ChatOptions(),
              ),
            ),
          ),
        ),
      );

  @override
  void didUpdateWidget(covariant FlutterChatNavigatorUserstory oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userId != widget.userId ||
        oldWidget.chatOptions != widget.chatOptions) {
      setState(() {
        _service = widget.chatService ?? ChatService();
      });
    }
  }
}

class _NavigatorWrapper extends StatelessWidget {
  const _NavigatorWrapper({
    required this.userId,
    required this.chatService,
    required this.chatOptions,
  });

  final String userId;
  final ChatService chatService;
  final ChatOptions chatOptions;

  @override
  Widget build(BuildContext context) => chatScreen(context);

  Widget chatScreen(BuildContext context) => ChatScreen(
        userId: userId,
        chatService: chatService,
        chatOptions: chatOptions,
        onPressChat: (chat) => route(context, chatDetailScreen(context, chat)),
        onDeleteChat: (chat) async {
          await chatService.deleteChat(chatId: chat.id);
        },
        onPressStartChat: () => route(context, newChatScreen(context)),
      );

  Widget chatDetailScreen(BuildContext context, ChatModel chat) =>
      ChatDetailScreen(
        chat: chat,
        onReadChat: (chat) async =>
            chatService.markAsRead(chatId: chat.id, userId: userId),
        onPressChatTitle: (chat) async {
          if (chat.isGroupChat) {
            return route(context, chatProfileScreen(context, null, chat));
          }

          var otherUserId = chat.getOtherUser(userId);
          var otherUser = await chatService.getUser(userId: otherUserId).first;

          if (!context.mounted) return;
          return route(context, chatProfileScreen(context, otherUser, null));
        },
        onPressUserProfile: (user) =>
            route(context, chatProfileScreen(context, user, null)),
        onUploadImage: (data) async {
          var path = await chatService.uploadImage(
            path: "chats/${chat.id}-$userId-${DateTime.now()}",
            image: data,
          );

          await chatService.sendMessage(
            messageId: "${chat.id}-$userId-${DateTime.now()}",
            chatId: chat.id,
            senderId: userId,
            imageUrl: path,
          );
        },
        onMessageSubmit: (text) async {
          await chatService.sendMessage(
            messageId: "${chat.id}-$userId-${DateTime.now()}",
            chatId: chat.id,
            senderId: userId,
            text: text,
          );
        },
      );

  Widget chatProfileScreen(
    BuildContext context,
    UserModel? user,
    ChatModel? chat,
  ) =>
      ChatProfileScreen(
        service: chatService,
        options: chatOptions,
        userId: userId,
        userModel: user,
        chatModel: chat,
        onTapUser: (userId) async {
          var user = await chatService.getUser(userId: userId).first;

          if (!context.mounted) return;
          route(context, chatProfileScreen(context, user, null));
        },
        onPressStartChat: (userId) async {
          var chat = await createChat(userId);

          if (!context.mounted) return;
          return route(context, chatDetailScreen(context, chat));
        },
      );

  Widget newChatScreen(BuildContext context) => NewChatScreen(
        userId: userId,
        chatService: chatService,
        chatOptions: chatOptions,
        onPressCreateGroupChat: () =>
            route(context, newGroupChatScreen(context)),
        onPressCreateChat: (user) async {
          var chat = await createChat(user.id);

          if (!context.mounted) return;
          return route(context, chatDetailScreen(context, chat));
        },
      );

  Widget newGroupChatScreen(BuildContext context) => NewGroupChatScreen(
        userId: userId,
        chatService: chatService,
        chatOptions: chatOptions,
        onContinue: (users) =>
            route(context, newGroupChatOverview(context, users)),
      );

  Widget newGroupChatOverview(BuildContext context, List<UserModel> users) =>
      NewGroupChatOverview(
        options: chatOptions,
        users: users,
        onComplete: (users, title, description, image) async {
          String? path;
          if (image != null) {
            path = await chatService.uploadImage(
              path: "groups/$title",
              image: image,
            );
          }
          var chat = await createGroupChat(
            users,
            title,
            description,
            path,
          );

          if (!context.mounted) return;
          return route(context, chatDetailScreen(context, chat));
        },
      );

  Future<ChatModel> createGroupChat(
    List<UserModel> userModels,
    String title,
    String description,
    String? imageUrl,
  ) async {
    ChatModel? chat;
    try {
      chat = await chatService.getGroupChatByUser(
        currentUser: userId,
        otherUsers: userModels,
        chatName: title,
        description: description,
      );
    } on Exception catch (_) {
      chat = null;
    }

    if (chat == null) {
      var currentUser = await chatService.getUser(userId: userId).first;
      var otherUsers = await Future.wait(
        userModels.map((e) => chatService.getUser(userId: e.id).first),
      );

      await chatService.createChat(
        isGroupChat: true,
        users: [currentUser, ...otherUsers],
        chatName: title,
        description: description,
        imageUrl: imageUrl,
      );

      var chat = await chatService.getGroupChatByUser(
        currentUser: userId,
        otherUsers: otherUsers,
        chatName: title,
        description: description,
      );

      if (chat == null) {
        throw Exception("Chat not created");
      }

      return chat;
    }

    return chat;
  }

  Future<ChatModel> createChat(String otherUserId) async {
    ChatModel? chat;

    try {
      chat = await chatService.getChatByUser(
        currentUser: userId,
        otherUser: otherUserId,
      );
    } on Exception catch (_) {
      chat = null;
    }

    if (chat == null) {
      var currentUser = await chatService.getUser(userId: userId).first;
      var otherUser = await chatService.getUser(userId: otherUserId).first;

      await chatService.createChat(
        isGroupChat: false,
        users: [currentUser, otherUser],
      );

      var chat = await chatService.getChatByUser(
        currentUser: userId,
        otherUser: otherUserId,
      );

      if (chat == null) {
        throw Exception("Chat not created");
      }

      return chat;
    }

    return chat;
  }

  void route(BuildContext context, Widget screen) {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => screen),
      ),
    );
  }
}
