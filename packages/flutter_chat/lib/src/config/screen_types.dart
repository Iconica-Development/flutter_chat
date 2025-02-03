import "package:flutter/material.dart";
import "package:flutter_chat/src/screens/chat_detail/chat_detail_screen.dart";
import "package:flutter_chat/src/screens/chat_profile_screen.dart";
import "package:flutter_chat/src/screens/chat_screen.dart";
import "package:flutter_chat/src/screens/creation/new_chat_screen.dart";
import "package:flutter_chat/src/screens/creation/new_group_chat_overview.dart";
import "package:flutter_chat/src/screens/creation/new_group_chat_screen.dart";

/// Type of screen, used in custom screen builders
enum ScreenType {
  /// Screen displaying an overview of chats
  chatScreen(screen: ChatScreen),

  /// Screen displaying a single chat
  chatDetailScreen(screen: ChatDetailScreen),

  /// Screen displaying the profile of a user within a chat
  chatProfileScreen(screen: ChatProfileScreen),

  /// Screen with a form to create a new chat
  newChatScreen(screen: NewChatScreen),

  /// Screen with a form to create a new group chat
  newGroupChatScreen(screen: NewGroupChatScreen),

  /// Screen displaying all group chats
  newGroupChatOverview(screen: NewGroupChatOverview);

  const ScreenType({
    required Type screen,
  }) : _screen = screen;

  final Type _screen;
}

/// Extension for mapping widgets to [ScreenType]s
extension MapFromWidget on Widget {
  /// returns corresponding [ScreenType]
  ScreenType get mapScreenType =>
      ScreenType.values.firstWhere((e) => e._screen == runtimeType);
}
