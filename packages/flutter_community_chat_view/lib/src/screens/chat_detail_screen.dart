// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';
import 'package:flutter_community_chat_view/flutter_community_chat_view.dart';
import 'package:flutter_community_chat_view/src/components/chat_bottom.dart';
import 'package:flutter_community_chat_view/src/components/chat_detail_row.dart';
import 'package:flutter_community_chat_view/src/components/chat_image.dart';

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({
    required this.chatOptions,
    required this.chat,
    required this.onMessageSubmit,
    this.chatMessages,
    this.onPressSelectImage,
    super.key,
  });

  final ChatModel chat;
  final ChatOptions chatOptions;
  final Stream<List<ChatMessageModel>>? chatMessages;
  final Function(ChatModel)? onPressSelectImage;
  final Future<void> Function(ChatModel chat, String text) onMessageSubmit;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (chat is PersonalChatModel) ...[
                ChatImage(
                  image: (chat as PersonalChatModel).user.imageUrl,
                  size: 36.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.5),
                  child: Text(
                    (chat as PersonalChatModel).user.name ?? '',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
              if (chat is GroupChatModel) ...[
                ChatImage(
                  image: (chat as GroupChatModel).imageUrl,
                  size: 36.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.5),
                  child: Text(
                    (chat as GroupChatModel).title,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ChatMessageModel>>(
                stream: chatMessages,
                builder: (BuildContext context, snapshot) => ListView(
                  reverse: true,
                  padding: const EdgeInsets.only(top: 24.0),
                  children: [
                    for (var message
                        in (snapshot.data ?? chat.messages ?? []).reversed)
                      ChatDetailRow(
                        message: message,
                      ),
                  ],
                ),
              ),
            ),
            ChatBottom(
              chat: chat,
              messageInputBuilder: chatOptions.messageInputBuilder,
              onPressSelectImage: onPressSelectImage,
              onMessageSubmit: onMessageSubmit,
            ),
          ],
        ),
      );
}
