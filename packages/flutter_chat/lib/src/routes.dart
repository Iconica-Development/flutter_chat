import "dart:async";

import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_chat/src/screens/chat_detail/chat_detail_screen.dart";
import "package:flutter_chat/src/screens/chat_profile_screen.dart";
import "package:flutter_chat/src/screens/chat_screen.dart";
import "package:flutter_chat/src/screens/creation/new_chat_screen.dart";
import "package:flutter_chat/src/screens/creation/new_group_chat_overview.dart";
import "package:flutter_chat/src/screens/creation/new_group_chat_screen.dart";

/// Pushes the chat overview screen
MaterialPageRoute chatOverviewRoute({
  required String userId,
  required ChatService chatService,
  required VoidCallback? onExit,
}) =>
    MaterialPageRoute(
      builder: (context) => ChatScreen(
        onExit: onExit,
        onPressChat: (chat) async => _routeToScreen(
          context,
          chatDetailRoute(
            chatId: chat.id,
            userId: userId,
            chatService: chatService,
            onExit: () => Navigator.of(context).pop(),
          ).builder(context),
        ),
        onDeleteChat: (chat) async => chatService.deleteChat(chatId: chat.id),
        onPressStartChat: () async => _routeToScreen(
          context,
          _newChatRoute(
            userId: userId,
            chatService: chatService,
          ).builder(context),
        ),
      ),
    );

/// Pushes the chat detail screen
MaterialPageRoute chatDetailRoute({
  required String chatId,
  required String userId,
  required ChatService chatService,
  required VoidCallback? onExit,
}) =>
    MaterialPageRoute(
      builder: (context) => ChatDetailScreen(
        chatId: chatId,
        onExit: onExit,
        onReadChat: (chat) async => chatService.markAsRead(chatId: chat.id),
        onUploadImage: (data) async {
          var path = await chatService.uploadImage(
            path: "chats/$chatId-$userId-${DateTime.now()}",
            image: data,
            chatId: chatId,
          );
          await chatService.sendMessage(
            messageId: "$chatId-$userId-${DateTime.now()}",
            chatId: chatId,
            senderId: userId,
            imageUrl: path,
            imageData: data,
          );
        },
        onMessageSubmit: (text) async {
          await chatService.sendMessage(
            messageId: "$chatId-$userId-${DateTime.now()}",
            chatId: chatId,
            senderId: userId,
            text: text,
          );
        },
        onPressChatTitle: (chat) async {
          if (chat.isGroupChat) {
            await _routeToScreen(
              context,
              _chatProfileRoute(
                userId: userId,
                chatService: chatService,
                chat: chat,
                onExit: () => Navigator.of(context).pop(),
              ).builder(context),
            );
          } else {
            var otherUserId = chat.getOtherUser(userId);
            var otherUser =
                await chatService.getUser(userId: otherUserId).first;
            if (!context.mounted) return;
            await _routeToScreen(
              context,
              _chatProfileRoute(
                userId: userId,
                chatService: chatService,
                user: otherUser,
                onExit: () => Navigator.of(context).pop(),
              ).builder(context),
            );
          }
        },
        onPressUserProfile: (user) async => _routeToScreen(
          context,
          _chatProfileRoute(
            userId: userId,
            chatService: chatService,
            user: user,
            onExit: () => Navigator.of(context).pop(),
          ).builder(context),
        ),
      ),
    );

MaterialPageRoute _chatProfileRoute({
  required String userId,
  required ChatService chatService,
  required VoidCallback onExit,
  UserModel? user,
  ChatModel? chat,
}) =>
    MaterialPageRoute(
      builder: (context) => ChatProfileScreen(
        userModel: user,
        chatModel: chat,
        onExit: onExit,
        onTapUser: (userId) async {
          var user = await chatService.getUser(userId: userId).first;
          if (!context.mounted) return;
          await _routeToScreen(
            context,
            _chatProfileRoute(
              userId: userId,
              chatService: chatService,
              user: user,
              onExit: () => Navigator.of(context).pop(),
            ).builder(context),
          );
        },
        onPressStartChat: (userId) async {
          var chat = await _createChat(userId, chatService, userId);
          if (!context.mounted) return;
          await _routeToScreen(
            context,
            chatDetailRoute(
              chatId: chat.id,
              userId: userId,
              chatService: chatService,
              onExit: () => Navigator.of(context).pop(),
            ).builder(context),
          );
        },
      ),
    );

MaterialPageRoute _newChatRoute({
  required String userId,
  required ChatService chatService,
}) =>
    MaterialPageRoute(
      builder: (context) => NewChatScreen(
        onExit: () => Navigator.of(context).pop(),
        onPressCreateGroupChat: () async => _routeToScreen(
          context,
          _newGroupChatRoute(
            userId: userId,
            chatService: chatService,
          ).builder(context),
        ),
        onPressCreateChat: (user) async {
          var chat = await _createChat(user.id, chatService, userId);
          if (!context.mounted) return;
          await _replaceCurrentScreen(
            context,
            chatDetailRoute(
              chatId: chat.id,
              userId: userId,
              chatService: chatService,
              onExit: () => Navigator.of(context).pop(),
            ).builder(context),
          );
        },
      ),
    );

MaterialPageRoute _newGroupChatRoute({
  required String userId,
  required ChatService chatService,
}) =>
    MaterialPageRoute(
      builder: (context) => NewGroupChatScreen(
        onExit: () => Navigator.of(context).pop(),
        onContinue: (users) async => _replaceCurrentScreen(
          context,
          _newGroupChatOverviewRoute(
            userId: userId,
            chatService: chatService,
            users: users,
          ).builder(context),
        ),
      ),
    );

MaterialPageRoute _newGroupChatOverviewRoute({
  required String userId,
  required ChatService chatService,
  required List<UserModel> users,
}) =>
    MaterialPageRoute(
      builder: (context) => NewGroupChatOverview(
        users: users,
        onExit: () => Navigator.of(context).pop(),
        onComplete: (users, title, description, image) async {
          String? path;
          if (image != null) {
            path = await chatService.uploadImage(
              path: "groups/$title",
              image: image,
              chatId: "",
            );
          }
          var chat = await _createGroupChat(
            users,
            title,
            description,
            path,
            chatService,
            userId,
          );
          if (!context.mounted) return;
          await _replaceCurrentScreen(
            context,
            chatDetailRoute(
              chatId: chat.id,
              userId: userId,
              chatService: chatService,
              onExit: () => Navigator.of(context).pop(),
            ).builder(context),
          );
        },
      ),
    );

/// Helper function to create a chat
Future<ChatModel> _createChat(
  String otherUserId,
  ChatService chatService,
  String userId,
) async {
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
    await chatService.createChat(
      isGroupChat: false,
      users: [
        await chatService.getUser(userId: userId).first,
        await chatService.getUser(userId: otherUserId).first,
      ],
    );
    chat = await chatService.getChatByUser(
      currentUser: userId,
      otherUser: otherUserId,
    );
    if (chat == null) throw Exception("Chat not created");
  }
  return chat;
}

/// Helper function to create a group chat
Future<ChatModel> _createGroupChat(
  List<UserModel> userModels,
  String title,
  String description,
  String? imageUrl,
  ChatService chatService,
  String userId,
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

    chat = await chatService.getGroupChatByUser(
      currentUser: userId,
      otherUsers: otherUsers,
      chatName: title,
      description: description,
    );

    if (chat == null) {
      throw Exception("Group chat not created");
    }
  }

  return chat;
}

/// Routes to a new screen for the userstory
Future _routeToScreen(BuildContext context, Widget screen) async =>
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );

/// Replaces the current screen with a new screen for the userstory
Future _replaceCurrentScreen(BuildContext context, Widget screen) async =>
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => screen),
    );
