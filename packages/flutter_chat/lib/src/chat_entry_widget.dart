import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat/flutter_chat.dart';
import 'package:flutter_chat_local/local_chat_service.dart';

class ChatEntryWidget extends StatefulWidget {
  const ChatEntryWidget({
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

  final ChatService? chatService;
  final Color backgroundColor;
  final double widgetSize;
  final Color counterBackgroundColor;
  final Function()? onTap;
  final IconData icon;
  final Color iconColor;
  final TextStyle? textStyle;

  @override
  State<ChatEntryWidget> createState() => _ChatEntryWidgetState();
}

class _ChatEntryWidgetState extends State<ChatEntryWidget> {
  ChatService? chatService;

  @override
  void initState() {
    super.initState();
    chatService ??= widget.chatService ?? LocalChatService();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () async =>
            widget.onTap?.call() ??
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => chatNavigatorUserStory(
                  context,
                  configuration: ChatUserStoryConfiguration(
                    chatService: chatService!,
                    chatOptionsBuilder: (ctx) => const ChatOptions(),
                  ),
                ),
              ),
            ),
        child: StreamBuilder<int>(
          stream: chatService!.chatOverviewService.getUnreadChatsCountStream(),
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
                      '${snapshot.data ?? 0}',
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

class _AnimatedNotificationIcon extends StatefulWidget {
  const _AnimatedNotificationIcon({
    required this.notifications,
    required this.icon,
  });

  final int notifications;
  final Icon icon;

  @override
  State<_AnimatedNotificationIcon> createState() =>
      _AnimatedNotificationIconState();
}

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
    super.dispose();
    _animationController.dispose();
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
