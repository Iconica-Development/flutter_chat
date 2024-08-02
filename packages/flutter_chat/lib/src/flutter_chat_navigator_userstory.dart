// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:flutter/material.dart";
import "package:flutter_chat/flutter_chat.dart";
import "package:flutter_chat/src/screens/chat_detail_screen.dart";
import "package:flutter_chat/src/screens/chat_profile_screen.dart";
import "package:flutter_chat/src/screens/chat_screen.dart";
import "package:flutter_chat/src/screens/creation/new_chat_screen.dart";
import "package:flutter_chat/src/screens/creation/new_group_chat_overview.dart";
import "package:flutter_chat/src/screens/creation/new_group_chat_screen.dart";

class FlutterChatNavigatorUserstory extends StatefulWidget {
  const FlutterChatNavigatorUserstory({
    super.key,
    required this.userId,
    this.chatService,
    this.chatOptions,
  });

  final String userId;

  final ChatService? chatService;
  final ChatOptions? chatOptions;

  @override
  State<FlutterChatNavigatorUserstory> createState() =>
      _FlutterChatNavigatorUserstoryState();
}

class _FlutterChatNavigatorUserstoryState
    extends State<FlutterChatNavigatorUserstory> {
  late ChatService chatService;
  late ChatOptions chatOptions;

  @override
  void initState() {
    chatService = widget.chatService ?? ChatService();
    chatOptions = widget.chatOptions ?? ChatOptions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => chatScreen();

  Widget chatScreen() {
    return ChatScreen(
      userId: widget.userId,
      chatService: chatService,
      chatOptions: chatOptions,
      onPressChat: (chat) {
        return route(chatDetailScreen(chat));
      },
      onDeleteChat: (chat) {
        chatService.deleteChat(chatId: chat.id);
      },
      onPressStartChat: () {
        return route(newChatScreen());
      },
    );
  }

  Widget chatDetailScreen(ChatModel chat) => ChatDetailScreen(
        userId: widget.userId,
        chatService: chatService,
        chatOptions: chatOptions,
        chat: chat,
        onReadChat: (chat) => chatService.markAsRead(
          chatId: chat.id,
        ),
        onPressChatTitle: (chat) {
          if (chat.isGroupChat) {
            return route(chatProfileScreen(null, chat));
          }

          var otherUser = chat.getOtherUser(widget.userId);

          return route(chatProfileScreen(otherUser, null));
        },
        onPressUserProfile: (user) {
          return route(chatProfileScreen(user, null));
        },
        onUploadImage: (data) async {
          var path = await chatService.uploadImage(path: 'chats', image: data);

          chatService.sendMessage(
            chatId: chat.id,
            senderId: widget.userId,
            imageUrl: path,
          );
        },
        onMessageSubmit: (text) {
          chatService.sendMessage(
            chatId: chat.id,
            senderId: widget.userId,
            text: text,
          );
        },
      );

  Widget chatProfileScreen(UserModel? user, ChatModel? chat) =>
      ChatProfileScreen(
        options: chatOptions,
        userId: widget.userId,
        userModel: user,
        chatModel: chat,
        onTapUser: (user) {
          route(chatProfileScreen(user, null));
        },
        onPressStartChat: (user) async {
          var chat = await createChat(user.id);
          return route(chatDetailScreen(chat));
        },
      );

  Widget newChatScreen() => NewChatScreen(
        userId: widget.userId,
        chatService: chatService,
        chatOptions: chatOptions,
        onPressCreateGroupChat: () {
          return route(newGroupChatScreen());
        },
        onPressCreateChat: (user) async {
          var chat = await createChat(user.id);
          return route(chatDetailScreen(chat));
        },
      );

  Widget newGroupChatScreen() => NewGroupChatScreen(
        userId: widget.userId,
        chatService: chatService,
        chatOptions: chatOptions,
        onContinue: (users) {
          return route(newGroupChatOverview(users));
        },
      );

  Widget newGroupChatOverview(List<UserModel> users) => NewGroupChatOverview(
        options: chatOptions,
        users: users,
        onComplete: (users, title, description, image) async {
          String? path;
          if (image != null) {
            path = await chatService.uploadImage(path: 'groups', image: image);
          }
          var chat = await createGroupChat(
            users,
            title,
            description,
            path,
          );
          return route(chatDetailScreen(chat));
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
        currentUser: widget.userId,
        otherUsers: userModels,
        chatName: title,
        description: description,
      );
    } catch (e) {
      chat = null;
    }

    if (chat == null) {
      var currentUser = await chatService.getUser(userId: widget.userId).first;
      var otherUsers = await Future.wait(
        userModels.map((e) => chatService.getUser(userId: e.id).first),
      );

      chat = await chatService.createChat(
        users: [currentUser, ...otherUsers],
        chatName: title,
        description: description,
        imageUrl: imageUrl,
      ).first;
    }

    return chat;
  }

  Future<ChatModel> createChat(String otherUserId) async {
    ChatModel? chat;

    try {
      chat = await chatService.getChatByUser(
        currentUser: widget.userId,
        otherUser: otherUserId,
      );
    } catch (e) {
      chat = null;
    }

    if (chat == null) {
      var currentUser = await chatService.getUser(userId: widget.userId).first;
      var otherUser = await chatService.getUser(userId: otherUserId).first;

      chat = await chatService.createChat(
        users: [currentUser, otherUser],
      ).first;
    }

    return chat;
  }

  void route(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
