// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:flutter/material.dart";
import "package:flutter_chat_view/flutter_chat_view.dart";

class ChatBottom extends StatefulWidget {
  const ChatBottom({
    required this.chat,
    required this.onMessageSubmit,
    required this.messageInputBuilder,
    required this.translations,
    this.onPressSelectImage,
    this.iconColor,
    this.iconDisabledColor,
    super.key,
  });

  /// Callback function invoked when a message is submitted.
  final Future<void> Function(String text) onMessageSubmit;

  /// The builder function for the message input.
  final TextInputBuilder messageInputBuilder;

  /// Callback function invoked when the select image button is pressed.
  final VoidCallback? onPressSelectImage;

  /// The chat model.
  final ChatModel chat;

  /// The translations for the chat.
  final ChatTranslations translations;

  /// The color of the icons.
  final Color? iconColor;
  final Color? iconDisabledColor;

  @override
  State<ChatBottom> createState() => _ChatBottomState();
}

class _ChatBottomState extends State<ChatBottom> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _isTyping = false;
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    _textEditingController.addListener(() {
      if (_textEditingController.text.isEmpty) {
        setState(() {
          _isTyping = false;
        });
      } else {
        setState(() {
          _isTyping = true;
        });
      }
    });
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 16,
      ),
      child: SizedBox(
        height: 45,
        child: widget.messageInputBuilder(
          _textEditingController,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: widget.onPressSelectImage,
                icon: Icon(
                  Icons.image_outlined,
                  color: widget.iconColor,
                ),
              ),
              IconButton(
                disabledColor: widget.iconDisabledColor,
                color: widget.iconColor,
                onPressed: _isTyping && !_isSending
                    ? () async {
                        setState(() {
                          _isSending = true;
                        });

                        var value = _textEditingController.text;

                        if (value.isNotEmpty) {
                          await widget.onMessageSubmit(value);
                          _textEditingController.clear();
                        }

                        setState(() {
                          _isSending = false;
                        });
                      }
                    : null,
                icon: const Icon(
                  Icons.send,
                ),
              ),
            ],
          ),
          widget.translations,
          context,
        ),
      ),
    );
  }
}
