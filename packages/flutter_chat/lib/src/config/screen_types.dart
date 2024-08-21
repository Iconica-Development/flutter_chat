import 'package:flutter/material.dart';
import 'package:flutter_chat/src/screens/chat_detail_screen.dart';
import 'package:flutter_chat/src/screens/chat_profile_screen.dart';
import 'package:flutter_chat/src/screens/chat_screen.dart';
import 'package:flutter_chat/src/screens/creation/new_chat_screen.dart';
import 'package:flutter_chat/src/screens/creation/new_group_chat_overview.dart';
import 'package:flutter_chat/src/screens/creation/new_group_chat_screen.dart';

enum ScreenType {
  chatScreen(screen: ChatScreen),
  chatDetailScreen(screen: ChatDetailScreen),
  chatProfileScreen(screen: ChatProfileScreen),
  newChatScreen(screen: NewChatScreen),
  newGroupChatScreen(screen: NewGroupChatScreen),
  newGroupChatOverview(screen: NewGroupChatOverview);

  const ScreenType({
    required this.screen,
  });

  final Type screen;
}

extension MapFromWidget on Widget {
  ScreenType get mapScreenType {
    return ScreenType.values.firstWhere((e) => e.screen == this.runtimeType);
  }
}
