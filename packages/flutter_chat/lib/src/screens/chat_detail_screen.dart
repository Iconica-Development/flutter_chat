import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_repository_interface/chat_repository_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/src/screens/creation/widgets/image_picker.dart';
import 'package:flutter_chat/src/config/chat_options.dart';
import 'package:flutter_chat/src/services/date_formatter.dart';
import 'package:flutter_profile/flutter_profile.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({
    super.key,
    required this.userId,
    required this.chatService,
    required this.chatOptions,
    required this.chat,
    required this.onPressChatTitle,
    required this.onPressUserProfile,
    required this.onUploadImage,
    required this.onMessageSubmit,
    required this.onReadChat,
  });

  final String userId;
  final ChatService chatService;
  final ChatOptions chatOptions;
  final ChatModel chat;
  final Function(ChatModel) onPressChatTitle;
  final Function(UserModel) onPressUserProfile;
  final Function(Uint8List image) onUploadImage;
  final Function(String text) onMessageSubmit;
  final Function(ChatModel chat) onReadChat;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late String chatTitle;

  @override
  void initState() {
    if (widget.chat.isGroupChat) {
      chatTitle = widget.chat.chatName ??
          widget.chatOptions.translations.groupNameEmpty;
    } else {
      chatTitle = widget.chat.users
              .firstWhere((element) => element.id != widget.userId)
              .fullname ??
          widget.chatOptions.translations.anonymousUser;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return widget.chatOptions.builders.chatDetailScaffoldBuilder?.call(
          _AppBar(
            chatTitle: chatTitle,
            chatOptions: widget.chatOptions,
            onPressChatTitle: widget.onPressChatTitle,
            chatModel: widget.chat,
          ) as AppBar,
          _Body(
            chatService: widget.chatService,
            options: widget.chatOptions,
            chat: widget.chat,
            currentUserId: widget.userId,
            onPressUserProfile: widget.onPressUserProfile,
            onUploadImage: widget.onUploadImage,
            onMessageSubmit: widget.onMessageSubmit,
            onReadChat: widget.onReadChat,
          ),
          theme.scaffoldBackgroundColor,
        ) ??
        Scaffold(
          appBar: _AppBar(
            chatTitle: chatTitle,
            chatOptions: widget.chatOptions,
            onPressChatTitle: widget.onPressChatTitle,
            chatModel: widget.chat,
          ),
          body: _Body(
            chatService: widget.chatService,
            options: widget.chatOptions,
            chat: widget.chat,
            currentUserId: widget.userId,
            onPressUserProfile: widget.onPressUserProfile,
            onUploadImage: widget.onUploadImage,
            onMessageSubmit: widget.onMessageSubmit,
            onReadChat: widget.onReadChat,
          ),
        );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({
    required this.chatTitle,
    required this.chatOptions,
    required this.onPressChatTitle,
    required this.chatModel,
  });

  final String chatTitle;
  final ChatOptions chatOptions;
  final Function(ChatModel) onPressChatTitle;
  final ChatModel chatModel;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return AppBar(
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
        onTap: () => onPressChatTitle.call(chatModel),
        child: chatOptions.builders.chatTitleBuilder?.call(chatTitle) ??
            Text(
              chatTitle,
              overflow: TextOverflow.ellipsis,
            ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _Body extends StatefulWidget {
  const _Body({
    required this.chatService,
    required this.options,
    required this.chat,
    required this.currentUserId,
    required this.onPressUserProfile,
    required this.onUploadImage,
    required this.onMessageSubmit,
    required this.onReadChat,
  });

  final ChatService chatService;
  final ChatOptions options;
  final String currentUserId;
  final ChatModel chat;
  final Function(UserModel) onPressUserProfile;
  final Function(Uint8List image) onUploadImage;
  final Function(String message) onMessageSubmit;
  final Function(ChatModel chat) onReadChat;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  ScrollController controller = ScrollController();
  bool showIndicator = false;
  late int pageSize;
  var page = 0;

  @override
  void initState() {
    pageSize = widget.options.pageSize;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: StreamBuilder<List<MessageModel>?>(
                  stream: widget.chatService.getMessages(
                    userId: widget.currentUserId,
                    chatId: widget.chat.id,
                    pageSize: pageSize,
                    page: page,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    var messages = snapshot.data?.reversed.toList() ?? [];

                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      await widget.onReadChat(widget.chat);
                    });

                    return Listener(
                      onPointerMove: (event) {
                        if (!showIndicator &&
                            controller.offset >=
                                controller.position.maxScrollExtent &&
                            !controller.position.outOfRange) {
                          setState(() {
                            showIndicator = true;
                          });

                          setState(() {
                            page++;
                          });

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
                        controller: controller,
                        physics: const AlwaysScrollableScrollPhysics(),
                        reverse: messages.isNotEmpty,
                        padding: const EdgeInsets.only(top: 24.0),
                        children: [
                          if (messages.isEmpty && !showIndicator) ...[
                            Center(
                              child: Text(
                                widget.chat.isGroupChat
                                    ? widget.options.translations
                                        .writeFirstMessageInGroupChat
                                    : widget.options.translations
                                        .writeMessageToStartChat,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                          for (var i = 0; i < messages.length; i++) ...[
                            _ChatBubble(
                              key: ValueKey(messages[i].id),
                              message: messages[i],
                              previousMessage: i < messages.length - 1
                                  ? messages[i + 1]
                                  : null,
                              chatService: widget.chatService,
                              onPressUserProfile: widget.onPressUserProfile,
                              options: widget.options,
                            ),
                          ]
                        ],
                      ),
                    );
                  }),
            ),
            _ChatBottom(
              chat: widget.chat,
              onPressSelectImage: () async => onPressSelectImage.call(
                context,
                widget.options,
                widget.onUploadImage,
              ),
              onMessageSubmit: widget.onMessageSubmit,
              options: widget.options,
            ),
          ],
        ),
        if (showIndicator) ...[
          widget.options.builders.loadingWidgetBuilder?.call(context) ??
              const Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
        ],
      ],
    );
  }
}

class _ChatBottom extends StatefulWidget {
  const _ChatBottom({
    required this.chat,
    required this.onMessageSubmit,
    required this.options,
    this.onPressSelectImage,
  });

  /// Callback function invoked when a message is submitted.
  final Function(String text) onMessageSubmit;

  /// Callback function invoked when the select image button is pressed.
  final VoidCallback? onPressSelectImage;

  /// The chat model.
  final ChatModel chat;

  final ChatOptions options;

  @override
  State<_ChatBottom> createState() => _ChatBottomState();
}

class _ChatBottomState extends State<_ChatBottom> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _isTyping = false;
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

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
        child: widget.options.builders.messageInputBuilder?.call(
              _textEditingController,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: widget.onPressSelectImage,
                    icon: Icon(
                      Icons.image_outlined,
                      color: widget.options.iconEnabledColor,
                    ),
                  ),
                  IconButton(
                    disabledColor: widget.options.iconDisabledColor,
                    color: widget.options.iconEnabledColor,
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
              widget.options.translations,
            ) ??
            TextField(
              style: theme.textTheme.bodySmall,
              textCapitalization: TextCapitalization.sentences,
              controller: _textEditingController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(
                    color: Colors.black,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(
                    color: Colors.black,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 30,
                ),
                hintText: widget.options.translations.messagePlaceholder,
                hintStyle: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.textTheme.bodyMedium!.color!.withOpacity(0.5),
                ),
                fillColor: Colors.white,
                filled: true,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(25),
                  ),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: widget.onPressSelectImage,
                      icon: Icon(
                        Icons.image_outlined,
                        color: widget.options.iconEnabledColor,
                      ),
                    ),
                    IconButton(
                      disabledColor: widget.options.iconDisabledColor,
                      color: widget.options.iconEnabledColor,
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
              ),
            ),
      ),
    );
  }
}

class _ChatBubble extends StatefulWidget {
  const _ChatBubble({
    required this.message,
    required this.chatService,
    required this.onPressUserProfile,
    required this.options,
    this.previousMessage,
    super.key,
  });
  final ChatOptions options;
  final ChatService chatService;
  final MessageModel message;
  final MessageModel? previousMessage;
  final Function(UserModel user) onPressUserProfile;

  @override
  State<_ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<_ChatBubble> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var translations = widget.options.translations;
    var dateFormatter = DateFormatter(options: widget.options);

    var isNewDate = widget.previousMessage != null &&
        widget.message.timestamp.day != widget.previousMessage?.timestamp.day;
    var isSameSender = widget.previousMessage == null ||
        widget.previousMessage?.senderId != widget.message.senderId;
    var isSameMinute = widget.previousMessage != null &&
        widget.message.timestamp.minute ==
            widget.previousMessage?.timestamp.minute;
    var hasHeader = isNewDate || isSameSender;
    return StreamBuilder<UserModel>(
        stream: widget.chatService.getUser(userId: widget.message.senderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var user = snapshot.data!;

          return Padding(
            padding: EdgeInsets.only(
              top: isNewDate || isSameSender ? 25.0 : 0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isNewDate || isSameSender) ...[
                  GestureDetector(
                    onTap: () => widget.onPressUserProfile(user),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: user.imageUrl?.isNotEmpty ?? false
                          ? _ChatImage(
                              image: user.imageUrl!,
                            )
                          : widget.options.builders.userAvatarBuilder?.call(
                                user,
                                40,
                              ) ??
                              Avatar(
                                key: ValueKey(user.id),
                                boxfit: BoxFit.cover,
                                user: User(
                                  firstName: user.firstName,
                                  lastName: user.lastName,
                                  imageUrl: user.imageUrl != ""
                                      ? user.imageUrl
                                      : null,
                                ),
                                size: 40,
                              ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(
                    width: 50,
                  ),
                ],
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (isNewDate || isSameSender) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: widget.options.builders.usernameBuilder
                                        ?.call(
                                      user.fullname ?? "",
                                    ) ??
                                    Text(
                                      user.fullname ??
                                          translations.anonymousUser,
                                      style: theme.textTheme.titleMedium,
                                    ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text(
                                  dateFormatter.format(
                                    date: widget.message.timestamp,
                                    showFullDate: true,
                                  ),
                                  style: theme.textTheme.labelSmall,
                                ),
                              ),
                            ],
                          ),
                        ],
                        Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: widget.message.isTextMessage()
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        widget.message.text ?? "",
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ),
                                    if (widget.options.showTimes &&
                                        !isSameMinute &&
                                        !isNewDate &&
                                        !hasHeader)
                                      Text(
                                        dateFormatter
                                            .format(
                                              date: widget.message.timestamp,
                                              showFullDate: true,
                                            )
                                            .split(" ")
                                            .last,
                                        style: theme.textTheme.labelSmall,
                                        textAlign: TextAlign.end,
                                      ),
                                  ],
                                )
                              : widget.message.isImageMessage()
                                  ? CachedNetworkImage(
                                      imageUrl: widget.message.imageUrl ?? "",
                                    )
                                  : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class _ChatImage extends StatelessWidget {
  const _ChatImage({
    required this.image,
  });

  final String image;

  @override
  Widget build(BuildContext context) => Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(40.0),
        ),
        width: 40,
        height: 40,
        child: image.isNotEmpty
            ? CachedNetworkImage(
                fadeInDuration: Duration.zero,
                imageUrl: image,
                fit: BoxFit.cover,
              )
            : null,
      );
}
