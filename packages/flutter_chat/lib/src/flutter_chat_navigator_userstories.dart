// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_chat/src/config/chat_options.dart";
import "package:flutter_chat/src/routes.dart";
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
    required this.options,
    super.key,
  });

  /// The user ID of the person currently looking at the chat
  final String userId;

  /// The chat options
  final ChatOptions options;

  @override
  State<FlutterChatNavigatorUserstory> createState() =>
      _FlutterChatNavigatorUserstoryState();
}

class _FlutterChatNavigatorUserstoryState
    extends State<FlutterChatNavigatorUserstory> {
  late ChatService _service = ChatService(
    userId: widget.userId,
    chatRepository: widget.options.chatRepository,
    userRepository: widget.options.userRepository,
  );

  late final PopHandler _popHandler = PopHandler();

  final GlobalKey<NavigatorState> _nestedNavigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) => ChatScope(
        userId: widget.userId,
        options: widget.options,
        service: _service,
        popHandler: _popHandler,
        child: NavigatorPopHandler(
          // ignore: deprecated_member_use
          onPop: () => _popHandler.handlePop(),
          child: Navigator(
            key: _nestedNavigatorKey,
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (context) => NavigatorWrapper(
                userId: widget.userId,
                chatService: _service,
                chatOptions: widget.options,
              ),
            ),
          ),
        ),
      );

  @override
  void didUpdateWidget(covariant FlutterChatNavigatorUserstory oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userId != widget.userId ||
        oldWidget.options != widget.options) {
      setState(() {
        _service = ChatService(
          userId: widget.userId,
          chatRepository: widget.options.chatRepository,
          userRepository: widget.options.userRepository,
        );
      });
    }
  }
}
