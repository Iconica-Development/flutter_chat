// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:async";
import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_chat_view/flutter_chat_view.dart";
import "package:flutter_chat_view/src/components/chat_bottom.dart";
import "package:flutter_chat_view/src/components/chat_detail_row.dart";
import "package:flutter_chat_view/src/components/image_loading_snackbar.dart";

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({
    required this.options,
    required this.onMessageSubmit,
    required this.onUploadImage,
    required this.onReadChat,
    required this.service,
    required this.pageSize,
    required this.chatId,
    required this.textfieldBottomPadding,
    required this.onPressChatTitle,
    required this.onPressUserProfile,
    this.chatTitleBuilder,
    this.usernameBuilder,
    this.loadingWidgetBuilder,
    this.translations = const ChatTranslations.empty(),
    this.iconColor,
    this.iconDisabledColor,
    this.showTime = false,
    super.key,
  });

  final String chatId;

  /// The id of the current user that is viewing the chat.

  final ChatOptions options;
  final ChatTranslations translations;
  final Future<void> Function(Uint8List image) onUploadImage;
  final Future<void> Function(String text) onMessageSubmit;
  // called at the start of the screen to set the chat to read
  // or when a new message is received
  final Future<void> Function(ChatModel chat) onReadChat;
  final Function(BuildContext context, ChatModel chat) onPressChatTitle;

  /// The color of the icon buttons in the chat bottom.
  final Color? iconColor;
  final bool showTime;
  final ChatService service;
  final int pageSize;
  final double textfieldBottomPadding;
  final Color? iconDisabledColor;
  final Function(ChatUserModel user) onPressUserProfile;
  // ignore: avoid_positional_boolean_parameters
  final Widget? Function(BuildContext context)? loadingWidgetBuilder;
  final Widget Function(String userFullName)? usernameBuilder;
  final Widget Function(String chatTitle)? chatTitleBuilder;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  // stream listener that needs to be disposed later
  ChatUserModel? currentUser;
  ScrollController controller = ScrollController();
  bool showIndicator = false;
  late ChatDetailService messageSubscription;
  Stream<List<ChatMessageModel>>? stream;
  ChatMessageModel? previousMessage;
  List<Widget> detailRows = [];
  ChatModel? chat;

  @override
  void initState() {
    super.initState();
    messageSubscription = widget.service.chatDetailService;
    messageSubscription.addListener(onListen);
    Future.delayed(Duration.zero, () async {
      chat =
          await widget.service.chatOverviewService.getChatById(widget.chatId);

      if (detailRows.isEmpty && context.mounted) {
        await widget.service.chatDetailService.fetchMoreMessage(
          widget.pageSize,
          chat!.id!,
        );
      }
      stream = widget.service.chatDetailService.getMessagesStream(chat!.id!);
      stream?.listen((event) {});

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await widget.onReadChat(chat!);
      });
    });
  }

  void onListen() {
    var chatMessages = [];
    chatMessages = widget.service.chatDetailService.getMessages();
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
          onPressUserProfile: widget.onPressUserProfile,
          usernameBuilder: widget.usernameBuilder,
        ),
      );
      previousMessage = message;
    }
    detailRows = detailRows.reversed.toList();

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await widget.onReadChat(chat!);
      });

      setState(() {});
    }
  }

  @override
  void dispose() {
    messageSubscription.removeListener(onListen);
    widget.service.chatDetailService.stopListeningForMessages();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    Future<void> onPressSelectImage() async => showModalBottomSheet<Uint8List?>(
          context: context,
          builder: (BuildContext context) =>
              widget.options.imagePickerContainerBuilder(
            () => Navigator.of(context).pop(),
            widget.translations,
            context,
          ),
        ).then(
          (image) async {
            if (image == null) return;
            var messenger = ScaffoldMessenger.of(context)
              ..showSnackBar(
                getImageLoadingSnackbar(widget.translations),
              )
              ..activate();
            await widget.onUploadImage(image);
            Future.delayed(const Duration(seconds: 1), () {
              messenger.hideCurrentSnackBar();
            });
          },
        );

    return FutureBuilder<ChatModel>(
      // ignore: discarded_futures
      future: widget.service.chatOverviewService.getChatById(widget.chatId),
      builder: (context, AsyncSnapshot<ChatModel> snapshot) {
        var chatModel = snapshot.data;
        var chatTitle = (chatModel is GroupChatModel)
            ? chatModel.title
            : (chatModel is PersonalChatModel)
                ? chatModel.user.firstName ?? widget.translations.anonymousUser
                : "";

        return Scaffold(
          appBar: AppBar(
            backgroundColor: theme.appBarTheme.backgroundColor,
            iconTheme: theme.appBarTheme.iconTheme ??
                const IconThemeData(color: Colors.white),
            centerTitle: true,
            leading: GestureDetector(
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Icon(
                Icons.arrow_back_ios,
              ),
            ),
            title: GestureDetector(
              onTap: () => widget.onPressChatTitle.call(context, chatModel!),
              child: widget.chatTitleBuilder?.call(chatTitle) ??
                  Text(
                    chatTitle,
                    style: theme.appBarTheme.titleTextStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
            ),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Listener(
                      onPointerMove: (event) async {
                        if (!showIndicator &&
                            controller.offset >=
                                controller.position.maxScrollExtent &&
                            !controller.position.outOfRange) {
                          setState(() {
                            showIndicator = true;
                          });
                          await widget.service.chatDetailService
                              .fetchMoreMessage(
                            widget.pageSize,
                            widget.chatId,
                          );
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
                        reverse: detailRows.isNotEmpty,
                        padding: const EdgeInsets.only(top: 24.0),
                        children: [
                          if (detailRows.isEmpty && !showIndicator) ...[
                            Center(
                              child: Text(
                                (chatModel is GroupChatModel)
                                    ? widget.translations
                                        .writeFirstMessageInGroupChat
                                    : widget
                                        .translations.writeMessageToStartChat,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                          ...detailRows,
                        ],
                      ),
                    ),
                  ),
                  if (chatModel != null) ...[
                    ChatBottom(
                      chat: chatModel,
                      messageInputBuilder: widget.options.messageInputBuilder,
                      onPressSelectImage: onPressSelectImage,
                      onMessageSubmit: widget.onMessageSubmit,
                      translations: widget.translations,
                      iconColor: widget.iconColor,
                      iconDisabledColor: widget.iconDisabledColor,
                    ),
                  ],
                  SizedBox(
                    height: widget.textfieldBottomPadding,
                  ),
                ],
              ),
              if (showIndicator) ...[
                widget.loadingWidgetBuilder?.call(context) ??
                    const Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Center(child: CircularProgressIndicator()),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
              ],
            ],
          ),
        );
      },
    );
  }
}
