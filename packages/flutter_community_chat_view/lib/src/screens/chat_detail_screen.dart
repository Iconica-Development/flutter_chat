// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
    required this.pageSize,
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
  final int pageSize;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  // stream listener that needs to be disposed later
  ChatUserModel? currentUser;
  ScrollController controller = ScrollController();
  bool showIndicator = false;
  late MessageService messageSubscription;
  Stream<List<ChatMessageModel>>? stream;
  ChatMessageModel? previousMessage;
  List<Widget> detailRows = [];

  @override
  void initState() {
    super.initState();
    messageSubscription = widget.messageService;
    messageSubscription.addListener(onListen);
    if (widget.chat != null) {
      stream = widget.messageService.getMessagesStream(widget.chat!);
      stream?.listen((event) {});
      Future.delayed(Duration.zero, () async {
        if (detailRows.isEmpty) {
          await widget.messageService
              .fetchMoreMessage(widget.pageSize, widget.chat!);
        }
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.chat != null) {
        widget.onReadChat(widget.chat!);
      }
    });
  }

  void onListen() {
    var chatMessages = [];
    chatMessages = widget.messageService.getMessages();
    detailRows = [];
    previousMessage = null;
    for (var message in chatMessages) {
      detailRows.add(
        ChatDetailRow(
          showTime: true,
          message: message,
          translations: widget.translations,
          userAvatarBuilder: widget.options.userAvatarBuilder,
          previousMessage: previousMessage,
        ),
      );
      previousMessage = message;
    }
    detailRows = detailRows.reversed.toList();

    widget.onReadChat(widget.chat!);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    messageSubscription.removeListener(onListen);
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
                child: Listener(
                  onPointerMove: (event) async {
                    var isTop = controller.position.pixels ==
                        controller.position.maxScrollExtent;

                    if (showIndicator == false &&
                        !isTop &&
                        controller.position.userScrollDirection ==
                            ScrollDirection.reverse) {
                      setState(() {
                        showIndicator = true;
                      });
                      await widget.messageService
                          .fetchMoreMessage(widget.pageSize, widget.chat!);
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) {
                          setState(() {
                            showIndicator = false;
                          });
                        }
                      });
                    }
                  },
                  child: ListView(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: controller,
                    reverse: true,
                    padding: const EdgeInsets.only(top: 24.0),
                    children: [
                      ...detailRows,
                      if (showIndicator) ...[
                        const SizedBox(
                          height: 10,
                        ),
                        const Center(child: CircularProgressIndicator()),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ],
                  ),
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
