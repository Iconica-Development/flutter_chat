import 'package:flutter/material.dart';
import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';
import 'package:flutter_community_chat_view/flutter_community_chat_view.dart';

class ChatBottom extends StatefulWidget {
  const ChatBottom({
    required this.chat,
    required this.onMessageSubmit,
    required this.messageInputBuilder,
    this.onPressSelectImage,
    super.key,
  });

  final Future<void> Function(ChatModel chat, String text) onMessageSubmit;
  final TextInputBuilder messageInputBuilder;
  final Function(ChatModel)? onPressSelectImage;

  final ChatModel chat;

  @override
  State<ChatBottom> createState() => _ChatBottomState();
}

class _ChatBottomState extends State<ChatBottom> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 17,
        ),
        child: SizedBox(
          height: 45,
          child: widget.messageInputBuilder(
            _textEditingController,
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.onPressSelectImage != null)
                    IconButton(
                      onPressed: () => widget.onPressSelectImage!(widget.chat),
                      icon: const Icon(
                        Icons.image,
                      ),
                    ),
                  IconButton(
                    onPressed: () {
                      var value = _textEditingController.text;

                      if (value.isNotEmpty) {
                        widget.onMessageSubmit(widget.chat, value);
                        _textEditingController.clear();
                      }
                    },
                    icon: const Icon(
                      Icons.send,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
