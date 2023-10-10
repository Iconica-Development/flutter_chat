// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_community_chat_view/flutter_community_chat_view.dart';
import 'package:flutter_community_chat_view/src/components/chat_bottom.dart';
import 'package:flutter_community_chat_view/src/components/chat_detail_row.dart';
import 'package:flutter_community_chat_view/src/components/image_loading_snackbar.dart';

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({
    required this.options,
    required this.onMessageSubmit,
    required this.onUploadImage,
    this.translations = const ChatTranslations(),
    this.chat,
    this.chatMessages,
    this.onPressChatTitle,
    this.iconColor,
    super.key,
  });

  final ChatModel? chat;
  final ChatOptions options;
  final ChatTranslations translations;
  final Stream<List<ChatMessageModel>>? chatMessages;
  final Future<void> Function(Uint8List image) onUploadImage;
  final Future<void> Function(String text) onMessageSubmit;
  final VoidCallback? onPressChatTitle;

  /// The color of the icon buttons in the chat bottom.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    Future<void> onPressSelectImage() => showModalBottomSheet<Uint8List?>(
          context: context,
          builder: (BuildContext context) =>
              options.imagePickerContainerBuilder(
            () => Navigator.of(context).pop(),
            translations,
          ),
        ).then(
          (image) async {
            var messenger = ScaffoldMessenger.of(context)
              ..showSnackBar(
                getImageLoadingSnackbar(translations),
              );

            if (image != null) {
              await onUploadImage(image);
            }

            messenger.hideCurrentSnackBar();
          },
        );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: GestureDetector(
          onTap: onPressChatTitle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: chat == null
                ? []
                : [
                    if (chat is GroupChatModel) ...[
                      options.groupAvatarBuilder(
                        (chat! as GroupChatModel).imageUrl,
                        36.0,
                      ),
                    ] else if (chat is PersonalChatModel) ...[
                      options.userAvatarBuilder(
                        (chat! as PersonalChatModel).user,
                        36.0,
                      ),
                    ] else
                      ...[],
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.5),
                        child: Text(
                          (chat is GroupChatModel)
                              ? (chat! as GroupChatModel).title
                              : (chat is PersonalChatModel)
                                  ? (chat! as PersonalChatModel).user.fullName
                                  : '',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
          ),
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
                      in (snapshot.data ?? chat?.messages ?? []).reversed)
                    ChatDetailRow(
                      message: message,
                    ),
                ],
              ),
            ),
          ),
          if (chat != null)
            ChatBottom(
              chat: chat!,
              messageInputBuilder: options.messageInputBuilder,
              onPressSelectImage: onPressSelectImage,
              onMessageSubmit: onMessageSubmit,
              translations: translations,
              iconColor: iconColor,
            ),
        ],
      ),
    );
  }
}
