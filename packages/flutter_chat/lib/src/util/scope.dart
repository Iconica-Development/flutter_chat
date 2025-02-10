import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/widgets.dart";
import "package:flutter_chat/src/config/chat_options.dart";
import "package:flutter_chat/src/services/pop_handler.dart";

///
class ChatScope extends InheritedWidget {
  ///
  const ChatScope({
    required this.userId,
    required this.options,
    required this.service,
    required this.popHandler,
    required super.child,
    super.key,
  });

  ///
  final String userId;

  ///
  final ChatOptions options;

  ///
  final ChatService service;

  ///
  final PopHandler popHandler;

  @override
  bool updateShouldNotify(ChatScope oldWidget) =>
      oldWidget.userId != userId || oldWidget.options != options;

  ///
  static ChatScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ChatScope>()!;
}
