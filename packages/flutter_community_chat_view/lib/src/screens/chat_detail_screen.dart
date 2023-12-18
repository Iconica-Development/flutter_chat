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
    required this.options,
    required this.onMessageSubmit,
    required this.onUploadImage,
    required this.onReadChat,
    required this.service,
    required this.chatUserService,
    required this.messageService,
    this.translations = const ChatTranslations(),
    this.chat,
    this.onPressChatTitle,
    this.iconColor,
    this.showTime = false,
    super.key,
  });

  final ChatModel? chat;

  /// The id of the current user that is viewing the chat.

  final ChatOptions options;
  final ChatTranslations translations;
  final Future<void> Function(Uint8List image) onUploadImage;
  final Future<void> Function(String text) onMessageSubmit;
  // called at the start of the screen to set the chat to read
  // or when a new message is received
  final Future<void> Function(ChatModel chat) onReadChat;
  final Function(BuildContext context, ChatModel chat)? onPressChatTitle;

  /// The color of the icon buttons in the chat bottom.
  final Color? iconColor;
  final bool showTime;
  final ChatService service;
  final ChatUserService chatUserService;
  final MessageService messageService;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  // stream listener that needs to be disposed later
  StreamSubscription<List<ChatMessageModel>>? _chatMessagesSubscription;
  Stream<List<ChatMessageModel>>? _chatMessages;
  ChatModel? chat;
  ChatUserModel? currentUser;

  @override
  void initState() {
    super.initState();
    // create a broadcast stream from the chat messages
    if (widget.chat != null) {
      _chatMessages = widget.messageService
          .getMessagesStream(widget.chat!)
          .asBroadcastStream();
    }
    _chatMessagesSubscription = _chatMessages?.listen((event) {
      // check if the last message is from the current user
      // if so, set the chat to read
      Future.delayed(Duration.zero, () async {
        currentUser = await widget.chatUserService.getCurrentUser();
      });
      if (event.isNotEmpty &&
          event.last.sender.id != currentUser?.id &&
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

    return FutureBuilder<ChatModel>(
      future: widget.service.getChatById(widget.chat?.id ?? ''),
      builder: (context, AsyncSnapshot<ChatModel> snapshot) {
        var chatModel = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: GestureDetector(
              onTap: () => widget.onPressChatTitle?.call(context, chatModel!),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: widget.chat == null
                    ? []
                    : [
                        if (chatModel is GroupChatModel) ...[
                          widget.options.groupAvatarBuilder(
                            chatModel.title,
                            chatModel.imageUrl,
                            36.0,
                          ),
                        ] else if (chatModel is PersonalChatModel) ...[
                          widget.options.userAvatarBuilder(
                            chatModel.user,
                            36.0,
                          ),
                        ] else
                          ...[],
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15.5),
                            child: Text(
                              (chatModel is GroupChatModel)
                                  ? chatModel.title
                                  : (chatModel is PersonalChatModel)
                                      ? chatModel.user.fullName ??
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
                  builder: (context, snapshot) {
                    var messages = snapshot.data ?? chatModel?.messages ?? [];
                    ChatMessageModel? previousMessage;

                    var messageWidgets = <Widget>[];

                    for (var message in messages) {
                      messageWidgets.add(
                        ChatDetailRow(
                          previousMessage: previousMessage,
                          showTime: widget.showTime,
                          translations: widget.translations,
                          message: message,
                          userAvatarBuilder: widget.options.userAvatarBuilder,
                        ),
                      );
                      previousMessage = message;
                    }

                    return ListView(
                      reverse: true,
                      padding: const EdgeInsets.only(top: 24.0),
                      children: messageWidgets.reversed.toList(),
                    );
                  },
                ),
              ),
              if (chatModel != null)
                ChatBottom(
                  chat: chatModel,
                  messageInputBuilder: widget.options.messageInputBuilder,
                  onPressSelectImage: onPressSelectImage,
                  onMessageSubmit: widget.onMessageSubmit,
                  translations: widget.translations,
                  iconColor: widget.iconColor,
                ),
            ],
          ),
        );
      },
    );
  }
}
