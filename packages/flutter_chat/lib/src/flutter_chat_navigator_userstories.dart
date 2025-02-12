// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_chat/src/config/chat_options.dart";
import "package:flutter_chat/src/routes.dart";
import "package:flutter_chat/src/services/pop_handler.dart";
import "package:flutter_chat/src/util/scope.dart";

/// Base class for both chat navigator user stories.
abstract class BaseChatNavigatorUserstory extends StatefulWidget {
  /// Constructs a [BaseChatNavigatorUserstory].
  const BaseChatNavigatorUserstory({
    required this.userId,
    required this.options,
    this.onExit,
    super.key,
  });

  /// The user ID of the person starting the chat userstory.
  final String userId;

  /// The chat userstory configuration.
  final ChatOptions options;

  /// Callback for when the user wants to navigate back to a previous screen
  final VoidCallback? onExit;

  @override
  State<BaseChatNavigatorUserstory> createState();
}

abstract class _BaseChatNavigatorUserstoryState<
    T extends BaseChatNavigatorUserstory> extends State<T> {
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
          onPop: () => _popHandler.handlePop(),
          child: Navigator(
            key: _nestedNavigatorKey,
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (context) => buildInitialScreen(),
            ),
          ),
        ),
      );

  @override
  void didUpdateWidget(covariant T oldWidget) {
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

  /// Implemented by subclasses to provide the initial screen of the userstory.
  Widget buildInitialScreen();
}

/// Default Chat Userstory that starts at the chat list screen.
class FlutterChatNavigatorUserstory extends BaseChatNavigatorUserstory {
  /// Constructs a [FlutterChatNavigatorUserstory].
  const FlutterChatNavigatorUserstory({
    required super.userId,
    required super.options,
    super.onExit,
    super.key,
  });

  @override
  State<BaseChatNavigatorUserstory> createState() =>
      _FlutterChatNavigatorUserstoryState();
}

class _FlutterChatNavigatorUserstoryState
    extends _BaseChatNavigatorUserstoryState<FlutterChatNavigatorUserstory> {
  @override
  Widget buildInitialScreen() => NavigatorWrapper(
        userId: widget.userId,
        chatService: _service,
        chatOptions: widget.options,
        onExit: widget.onExit,
      );
}

/// Chat Userstory that starts directly in a chat detail screen.
class FlutterChatDetailNavigatorUserstory extends BaseChatNavigatorUserstory {
  /// Constructs a [FlutterChatDetailNavigatorUserstory].
  const FlutterChatDetailNavigatorUserstory({
    required super.userId,
    required super.options,
    required this.chat,
    super.onExit,
    super.key,
  });

  /// The chat to start in.
  final ChatModel chat;

  @override
  State<BaseChatNavigatorUserstory> createState() =>
      _FlutterChatDetailNavigatorUserstoryState();
}

class _FlutterChatDetailNavigatorUserstoryState
    extends _BaseChatNavigatorUserstoryState<
        FlutterChatDetailNavigatorUserstory> {
  @override
  Widget buildInitialScreen() => NavigatorWrapper(
        userId: widget.userId,
        chatService: _service,
        chatOptions: widget.options,
        onExit: widget.onExit,
      ).chatDetailScreen(
        context,
        widget.chat,
        widget.onExit,
      );
}
