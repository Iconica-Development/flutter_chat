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
    this.iconDisabledColor,
    super.key,
  });

  final Future<void> Function(String text) onMessageSubmit;
  final TextInputBuilder messageInputBuilder;
  final VoidCallback? onPressSelectImage;
  final ChatModel chat;
  final ChatTranslations translations;
  final Color? iconColor;
  final Color? iconDisabledColor;

  @override
  State<ChatBottom> createState() => _ChatBottomState();
}

class _ChatBottomState extends State<ChatBottom> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _isTyping = false;
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
                disabledColor: widget.iconDisabledColor,
                color: widget.iconColor,
                onPressed: _isTyping
                    ? () async {
                        var value = _textEditingController.text;

                        if (value.isNotEmpty) {
                          await widget.onMessageSubmit(value);
                          _textEditingController.clear();
                        }
                      }
                    : null,
                icon: const Icon(
                  Icons.send,
                ),
              ),
            ],
          ),
          widget.translations,
        ),
      ),
    );
  }
}
