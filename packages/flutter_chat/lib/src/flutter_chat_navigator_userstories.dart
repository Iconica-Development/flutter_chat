// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause
import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_chat/src/config/chat_options.dart";
import "package:flutter_chat/src/routes.dart";
import "package:flutter_chat/src/services/pop_handler.dart";
import "package:flutter_chat/src/util/scope.dart";
import "package:flutter_hooks/flutter_hooks.dart";

/// Default Chat Userstory that starts at the chat list screen.
class FlutterChatNavigatorUserstory extends _BaseChatNavigatorUserstory {
  /// Constructs a [FlutterChatNavigatorUserstory].
  const FlutterChatNavigatorUserstory({
    required super.userId,
    required super.options,
    super.onExit,
    super.key,
  });

  @override
  MaterialPageRoute buildInitialRoute(
    BuildContext context,
    ChatService service,
    PopHandler popHandler,
  ) =>
      chatOverviewRoute(
        userId: userId,
        chatService: service,
        chatOptions: options,
        onExit: onExit,
      );
}

/// Chat Userstory that starts directly in a chat detail screen.
class FlutterChatDetailNavigatorUserstory extends _BaseChatNavigatorUserstory {
  /// Constructs a [FlutterChatDetailNavigatorUserstory].
  const FlutterChatDetailNavigatorUserstory({
    required super.userId,
    required super.options,
    required this.chatId,
    super.onExit,
    super.key,
  });

  /// The identifier of the chat to start in.
  /// The [ChatModel] will be fetched from the [ChatRepository]
  final String chatId;

  @override
  MaterialPageRoute buildInitialRoute(
    BuildContext context,
    ChatService service,
    PopHandler popHandler,
  ) =>
      chatDetailRoute(
        chatId: chatId,
        userId: userId,
        chatService: service,
        chatOptions: options,
        onExit: onExit,
      );
}

/// Base hook widget for chat navigator userstories.
abstract class _BaseChatNavigatorUserstory extends HookWidget {
  /// Constructs a [_BaseChatNavigatorUserstory].
  const _BaseChatNavigatorUserstory({
    required this.userId,
    required this.options,
    this.onExit,
    super.key,
  });

  /// The user ID of the person starting the chat userstory.
  final String userId;

  /// The chat userstory configuration.
  final ChatOptions options;

  /// Callback for when the user wants to navigate back.
  final VoidCallback? onExit;

  /// Implemented by subclasses to provide the initial route of the userstory.
  MaterialPageRoute buildInitialRoute(
    BuildContext context,
    ChatService service,
    PopHandler popHandler,
  );

  @override
  Widget build(BuildContext context) {
    var service = useMemoized(
      () => ChatService(
        userId: userId,
        chatRepository: options.chatRepository,
        userRepository: options.userRepository,
      ),
      [userId, options],
    );

    var popHandler = useMemoized(PopHandler.new, []);
    var nestedNavigatorKey = useMemoized(GlobalKey<NavigatorState>.new, []);

    return ChatScope(
      userId: userId,
      options: options,
      service: service,
      popHandler: popHandler,
      child: NavigatorPopHandler(
        onPop: () => popHandler.handlePop(),
        child: Navigator(
          key: nestedNavigatorKey,
          onGenerateInitialRoutes: (_, __) => [
            buildInitialRoute(context, service, popHandler),
          ],
        ),
      ),
    );
  }
}
