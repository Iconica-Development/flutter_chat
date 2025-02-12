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

/// The navigator wrapper
class NavigatorWrapper extends StatelessWidget {
  /// Constructs a [NavigatorWrapper].
  const NavigatorWrapper({
    required this.userId,
    required this.chatService,
    required this.chatOptions,
    this.onExit,
    super.key,
  });

  /// The user ID of the person starting the chat userstory
  final String userId;

  /// The chat service containing the chat repository and user repository
  final ChatService chatService;

  /// The chat userstory configuration
  final ChatOptions chatOptions;

  /// Callback for when the user wants to navigate back
  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) => chatScreen(context);

  /// The chat overview screen
  Widget chatScreen(BuildContext context) => ChatScreen(
        onExit: onExit,
        onPressChat: (chat) async => _routeToScreen(
          context,
          chatDetailScreen(
            context,
            chat,
            () => Navigator.of(context).pop(),
          ),
        ),
        onDeleteChat: (chat) async {
          await chatService.deleteChat(chatId: chat.id);
        },
        onPressStartChat: () async =>
            _routeToScreen(context, newChatScreen(context)),
      );

  /// The chat screen
  Widget chatDetailScreen(
    BuildContext context,
    ChatModel chat,
    VoidCallback? onExit,
  ) =>
      ChatDetailScreen(
        chat: chat,
        onExit: onExit,
        onReadChat: (chat) async => chatService.markAsRead(chatId: chat.id),
        onPressChatTitle: (chat) async {
          if (chat.isGroupChat) {
            return _routeToScreen(
              context,
              chatProfileScreen(context, null, chat),
            );
          }

          var otherUserId = chat.getOtherUser(userId);
          var otherUser = await chatService.getUser(userId: otherUserId).first;

          if (!context.mounted) return;
          return _routeToScreen(
            context,
            chatProfileScreen(context, otherUser, null),
          );
        },
        onPressUserProfile: (user) async =>
            _routeToScreen(context, chatProfileScreen(context, user, null)),
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

  /// The chat profile screen
  Widget chatProfileScreen(
    BuildContext context,
    UserModel? user,
    ChatModel? chat,
  ) =>
      ChatProfileScreen(
        userModel: user,
        chatModel: chat,
        onExit: () => Navigator.of(context).pop(),
        onTapUser: (userId) async {
          var user = await chatService.getUser(userId: userId).first;

          if (!context.mounted) return;
          await _routeToScreen(context, chatProfileScreen(context, user, null));
        },
        onPressStartChat: (userId) async {
          var chat = await _createChat(userId);

          if (!context.mounted) return;
          return _routeToScreen(
            context,
            chatDetailScreen(
              context,
              chat,
              () => Navigator.of(context).pop(),
            ),
          );
        },
      );

  /// The new chat screen
  Widget newChatScreen(BuildContext context) => NewChatScreen(
        onExit: () => Navigator.of(context).pop(),
        onPressCreateGroupChat: () async =>
            _routeToScreen(context, newGroupChatScreen(context)),
        onPressCreateChat: (user) async {
          var chat = await _createChat(user.id);

          if (!context.mounted) return;
          return _replaceCurrentScreen(
            context,
            chatDetailScreen(
              context,
              chat,
              () => Navigator.of(context).pop(),
            ),
          );
        },
      );

  /// The new group chat screen
  Widget newGroupChatScreen(BuildContext context) => NewGroupChatScreen(
        onExit: () => Navigator.of(context).pop(),
        onContinue: (users) async => _replaceCurrentScreen(
          context,
          newGroupChatOverview(context, users),
        ),
      );

  /// The new group chat overview screen
  Widget newGroupChatOverview(BuildContext context, List<UserModel> users) =>
      NewGroupChatOverview(
        users: users,
        onExit: () => Navigator.of(context).pop(),
        onComplete: (users, title, description, image) async {
          String? path;
          if (image != null) {
            path = await chatService.uploadImage(
              path: "groups/$title",
              image: image,
            );
          }
          var chat = await _createGroupChat(
            users,
            title,
            description,
            path,
          );

          if (!context.mounted) return;
          return _replaceCurrentScreen(
            context,
            chatDetailScreen(
              context,
              chat,
              () => Navigator.of(context).pop(),
            ),
          );
        },
      );

  /// Creates a group chat
  Future<ChatModel> _createGroupChat(
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

  /// Creates a chat
  Future<ChatModel> _createChat(String otherUserId) async {
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
}
