// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_community_chat_view/flutter_community_chat_view.dart';
import 'package:flutter_community_chat_view/src/components/chat_bottom.dart';
import 'package:flutter_community_chat_view/src/components/chat_detail_row.dart';
import 'package:flutter_community_chat_view/src/components/image_loading_snackbar.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({
    required this.userId,
    required this.options,
    required this.onMessageSubmit,
    required this.onUploadImage,
    required this.onReadChat,
    this.translations = const ChatTranslations(),
    this.chat,
    this.chatMessages,
    this.onPressChatTitle,
    this.iconColor,
    super.key,
  });

  final ChatModel? chat;

  /// The id of the current user that is viewing the chat.
  final String userId;

  final ChatOptions options;
  final ChatTranslations translations;
  final Stream<List<ChatMessageModel>>? chatMessages;
  final Future<void> Function(Uint8List image) onUploadImage;
  final Future<void> Function(String text) onMessageSubmit;
  // called at the start of the screen to set the chat to read
  // or when a new message is received
  final Future<void> Function(ChatModel chat) onReadChat;
  final VoidCallback? onPressChatTitle;

  /// The color of the icon buttons in the chat bottom.
  final Color? iconColor;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  // stream listener that needs to be disposed later
  StreamSubscription<List<ChatMessageModel>>? _chatMessagesSubscription;
  Stream<List<ChatMessageModel>>? _chatMessages;

  @override
  void initState() {
    super.initState();
    // create a broadcast stream from the chat messages
    _chatMessages = widget.chatMessages?.asBroadcastStream();
    _chatMessagesSubscription = _chatMessages?.listen((event) {
      // check if the last message is from the current user
      // if so, set the chat to read
      if (event.isNotEmpty &&
          event.last.sender.id != widget.userId &&
          widget.chat != null) {
        widget.onReadChat(widget.chat!);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.chat != null) {
        widget.onReadChat(widget.chat!);
      }
    });
  }

  @override
  void dispose() {
    _chatMessagesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> onPressSelectImage() => showModalBottomSheet<Uint8List?>(
          context: context,
          builder: (BuildContext context) =>
              widget.options.imagePickerContainerBuilder(
            () => Navigator.of(context).pop(),
            widget.translations,
          ),
        ).then(
          (image) async {
            var messenger = ScaffoldMessenger.of(context)
              ..showSnackBar(
                getImageLoadingSnackbar(widget.translations),
              );

            if (image != null) {
              await widget.onUploadImage(image);
            }

            messenger.hideCurrentSnackBar();
          },
        );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: GestureDetector(
          onTap: widget.onPressChatTitle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: widget.chat == null
                ? []
                : [
                    if (widget.chat is GroupChatModel) ...[
                      widget.options.groupAvatarBuilder(
                        (widget.chat! as GroupChatModel).title,
                        (widget.chat! as GroupChatModel).imageUrl,
                        36.0,
                      ),
                    ] else if (widget.chat is PersonalChatModel) ...[
                      widget.options.userAvatarBuilder(
                        (widget.chat! as PersonalChatModel).user,
                        36.0,
                      ),
                    ] else
                      ...[],
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.5),
                        child: Text(
                          (widget.chat is GroupChatModel)
                              ? (widget.chat! as GroupChatModel).title
                              : (widget.chat is PersonalChatModel)
                                  ? (widget.chat! as PersonalChatModel)
                                          .user
                                          .fullName ??
                                      widget.translations.anonymousUser
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
              stream: _chatMessages,
              builder: (BuildContext context, snapshot) {
                var messages = snapshot.data ?? widget.chat?.messages ?? [];
                ChatMessageModel? lastMessage;
                var messageWidgets = <Widget>[];

                for (var message in messages) {
                  var isFirstMessage = lastMessage == null ||
                      lastMessage.sender.id != message.sender.id;
                  messageWidgets.add(
                    ChatDetailRow(
                      translations: widget.translations,
                      message: message,
                      isFirstMessage: isFirstMessage,
                      userAvatarBuilder: widget.options.userAvatarBuilder,
                    ),
                  );
                  lastMessage = message;
                }

                return ListView(
                  reverse: true,
                  padding: const EdgeInsets.only(top: 24.0),
                  children: messageWidgets.reversed.toList(),
                );
              },
            ),
          ),
          if (widget.chat != null)
            ChatBottom(
              chat: widget.chat!,
              messageInputBuilder: widget.options.messageInputBuilder,
              onPressSelectImage: onPressSelectImage,
              onMessageSubmit: widget.onMessageSubmit,
              translations: widget.translations,
              iconColor: widget.iconColor,
            ),
        ],
      ),
    );
  }
}
