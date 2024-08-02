import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_chat/flutter_chat.dart";

/// A widget representing an entry point for a chat UI.
class FlutterChatEntryWidget extends StatefulWidget {
  /// Constructs a [FlutterChatEntryWidget].
  const FlutterChatEntryWidget({
    required this.userId,
    this.chatService,
    this.onTap,
    this.widgetSize = 75,
    this.backgroundColor = Colors.grey,
    this.icon = Icons.chat,
    this.iconColor = Colors.black,
    this.counterBackgroundColor = Colors.red,
    this.textStyle,
    super.key,
  });

  /// The chat service associated with the widget.
  final ChatService? chatService;

  /// The user ID of the person currently looking at the chat
  final String userId;

  /// Background color of the widget.
  final Color backgroundColor;

  /// Size of the widget.
  final double widgetSize;

  /// Background color of the counter.
  final Color counterBackgroundColor;

  /// Callback function triggered when the widget is tapped.
  final Function()? onTap;

  /// Icon to be displayed.
  final IconData icon;

  /// Color of the icon.
  final Color iconColor;

  /// Text style for the counter.
  final TextStyle? textStyle;

  @override
  State<FlutterChatEntryWidget> createState() => _FlutterChatEntryWidgetState();
}

/// State class for [FlutterChatEntryWidget].
class _FlutterChatEntryWidgetState extends State<FlutterChatEntryWidget> {
  ChatService? chatService;

  @override
  void initState() {
    super.initState();
    chatService ??= widget.chatService ?? ChatService();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () async =>
            widget.onTap?.call() ??
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => FlutterChatNavigatorUserstory(
                  userId: widget.userId,
                  chatService: chatService!,
                ),
              ),
            ),
        child: StreamBuilder<int>(
          stream: chatService!.getUnreadMessagesCount(userId: widget.userId),
          builder: (BuildContext context, snapshot) => Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.widgetSize,
                height: widget.widgetSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.backgroundColor,
                ),
                child: _AnimatedNotificationIcon(
                  icon: Icon(
                    widget.icon,
                    color: widget.iconColor,
                    size: widget.widgetSize / 1.5,
                  ),
                  notifications: snapshot.data ?? 0,
                ),
              ),
              Positioned(
                right: 0.0,
                top: 0.0,
                child: Container(
                  width: widget.widgetSize / 2,
                  height: widget.widgetSize / 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.counterBackgroundColor,
                  ),
                  child: Center(
                    child: Text(
                      "${snapshot.data ?? 0}",
                      style: widget.textStyle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

/// Stateful widget representing an animated notification icon.
class _AnimatedNotificationIcon extends StatefulWidget {
  const _AnimatedNotificationIcon({
    required this.notifications,
    required this.icon,
  });

  /// The number of notifications.
  final int notifications;

  /// The icon to be displayed.
  final Icon icon;

  @override
  State<_AnimatedNotificationIcon> createState() =>
      _AnimatedNotificationIconState();
}

/// State class for [_AnimatedNotificationIcon].
class _AnimatedNotificationIconState extends State<_AnimatedNotificationIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    if (widget.notifications != 0) {
      unawaited(_runAnimation());
    }
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _AnimatedNotificationIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.notifications != widget.notifications) {
      unawaited(_runAnimation());
    }
  }

  Future<void> _runAnimation() async {
    await _animationController.forward();
    await _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(
        turns: Tween(begin: 0.0, end: -.1)
            .chain(CurveTween(curve: Curves.elasticIn))
            .animate(_animationController),
        child: widget.icon,
      );
}
