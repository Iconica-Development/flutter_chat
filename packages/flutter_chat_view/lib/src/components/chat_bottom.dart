// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_chat_view/flutter_chat_view.dart';

class ChatBottom extends StatefulWidget {
  const ChatBottom({
    required this.chat,
    required this.onMessageSubmit,
    required this.messageInputBuilder,
    required this.translations,
    this.onPressSelectImage,
    this.iconColor,
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
                  IconButton(
                    onPressed: widget.onPressSelectImage,
                    icon: Icon(
                      Icons.image,
                      color: widget.iconColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      var value = _textEditingController.text;

                      if (value.isNotEmpty) {
                        await widget.onMessageSubmit(value);
                        _textEditingController.clear();
                      }
                    },
                    icon: Icon(
                      Icons.send,
                      color: widget.iconColor,
                    ),
                  ),
                ],
              ),
            ),
            widget.translations,
          ),
        ),
      );
}
