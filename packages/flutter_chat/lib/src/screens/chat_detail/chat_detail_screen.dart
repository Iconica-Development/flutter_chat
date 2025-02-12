import "dart:async";
import "dart:typed_data";

import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_chat/src/config/chat_options.dart";
import "package:flutter_chat/src/config/screen_types.dart";
import "package:flutter_chat/src/screens/chat_detail/widgets/default_message_builder.dart";
import "package:flutter_chat/src/screens/creation/widgets/image_picker.dart";
import "package:flutter_chat/src/util/scope.dart";
import "package:flutter_hooks/flutter_hooks.dart";

/// Chat detail screen
/// Seen when a user clicks on a chat
class ChatDetailScreen extends StatefulHookWidget {
  /// Constructs a [ChatDetailScreen].
  const ChatDetailScreen({
    required this.chat,
    required this.onExit,
    required this.onPressChatTitle,
    required this.onPressUserProfile,
    required this.onUploadImage,
    required this.onMessageSubmit,
    required this.onReadChat,
    this.getChatTitle,
    super.key,
  });

  /// The chat model currently being viewed
  final ChatModel chat;

  /// Callback function triggered when the chat title is pressed.
  final Function(ChatModel) onPressChatTitle;

  /// Callback function triggered when the user profile is pressed.
  final Function(UserModel) onPressUserProfile;

  /// Callback function triggered when an image is uploaded.
  final Function(Uint8List image) onUploadImage;

  /// Callback function triggered when a message is submitted.
  final Function(String text) onMessageSubmit;

  /// Callback function triggered when the chat is read.
  final Function(ChatModel chat) onReadChat;

  /// Callback function to get the chat title
  final String Function(ChatModel chat)? getChatTitle;

  /// Callback for when the user wants to navigate back
  final VoidCallback onExit;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  String? chatTitle;

  @override
  void initState() {
    super.initState();
    if (widget.chat.isGroupChat) {
      chatTitle = widget.chat.chatName;
    }
    if (chatTitle != null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var chatScope = ChatScope.of(context);

      if (widget.chat.isGroupChat) {
        chatTitle = chatScope.options.translations.groupNameEmpty;
      } else {
        await _getTitle(chatScope);
      }
    });
  }

  Future<void> _getTitle(ChatScope chatScope) async {
    if (widget.getChatTitle != null) {
      chatTitle = widget.getChatTitle!.call(widget.chat);
    } else {
      var userId = widget.chat.users
          .firstWhere((element) => element != chatScope.userId);
      var user = await chatScope.service.getUser(userId: userId).first;

      chatTitle = user.fullname ?? chatScope.options.translations.anonymousUser;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var chatOptions = chatScope.options;
    var appBar = _AppBar(
      chatTitle: chatTitle,
      onPressChatTitle: widget.onPressChatTitle,
      chatModel: widget.chat,
    );

    var body = _Body(
      chat: widget.chat,
      onPressUserProfile: widget.onPressUserProfile,
      onUploadImage: widget.onUploadImage,
      onMessageSubmit: widget.onMessageSubmit,
      onReadChat: widget.onReadChat,
    );

    useEffect(() {
      chatScope.popHandler.add(widget.onExit);
      return () => chatScope.popHandler.remove(widget.onExit);
    });

    if (chatOptions.builders.baseScreenBuilder == null) {
      return Scaffold(
        appBar: appBar,
        body: body,
      );
    }

    return chatOptions.builders.baseScreenBuilder!.call(
      context,
      widget.mapScreenType,
      appBar,
      body,
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({
    required this.chatTitle,
    required this.onPressChatTitle,
    required this.chatModel,
  });

  final String? chatTitle;
  final Function(ChatModel) onPressChatTitle;
  final ChatModel chatModel;

  @override
  Widget build(BuildContext context) {
    var options = ChatScope.of(context).options;
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
        child: options.builders.chatTitleBuilder?.call(chatTitle ?? "") ??
            Text(
              chatTitle ?? "",
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
    required this.chat,
    required this.onPressUserProfile,
    required this.onUploadImage,
    required this.onMessageSubmit,
    required this.onReadChat,
  });

  final ChatModel chat;
  final Function(UserModel) onPressUserProfile;
  final Function(Uint8List image) onUploadImage;
  final Function(String message) onMessageSubmit;
  final Function(ChatModel chat) onReadChat;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final ScrollController controller = ScrollController();
  bool showIndicator = false;
  late int pageSize = 20;
  int page = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var chatScope = ChatScope.of(context);
      pageSize = chatScope.options.pageSize;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;
    var service = chatScope.service;

    void handleScroll(PointerMoveEvent event) {
      if (!showIndicator &&
          controller.offset >= controller.position.maxScrollExtent &&
          !controller.position.outOfRange) {
        setState(() {
          showIndicator = true;
          page++;
        });

        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() {
            showIndicator = false;
          });
        });
      }
    }

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Align(
                alignment: options.chatAlignment ?? Alignment.bottomCenter,
                child: StreamBuilder<List<MessageModel>?>(
                  stream: service.getMessages(
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
                      onPointerMove: handleScroll,
                      child: ListView(
                        shrinkWrap: true,
                        controller: controller,
                        physics: const AlwaysScrollableScrollPhysics(),
                        reverse: messages.isNotEmpty,
                        padding: const EdgeInsets.only(top: 24.0),
                        children: [
                          if (messages.isEmpty && !showIndicator) ...[
                            _ChatNoMessages(widget: widget),
                          ],
                          for (var (index, message) in messages.indexed) ...[
                            if (widget.chat.id == message.chatId) ...[
                              _ChatBubble(
                                key: ValueKey(message.id),
                                message: message,
                                previousMessage: index < messages.length - 1
                                    ? messages[index + 1]
                                    : null,
                                onPressUserProfile: widget.onPressUserProfile,
                              ),
                            ],
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            _ChatBottom(
              chat: widget.chat,
              onPressSelectImage: () async => onPressSelectImage.call(
                context,
                options,
                widget.onUploadImage,
              ),
              onMessageSubmit: widget.onMessageSubmit,
              options: options,
            ),
          ],
        ),
        if (showIndicator && options.enableLoadingIndicator) ...[
          options.builders.loadingWidgetBuilder.call(context) ??
              const SizedBox.shrink(),
        ],
      ],
    );
  }
}

class _ChatNoMessages extends StatelessWidget {
  const _ChatNoMessages({
    required this.widget,
  });

  final _Body widget;

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;
    var translations = options.translations;
    var theme = Theme.of(context);

    return Center(
      child: Text(
        widget.chat.isGroupChat
            ? translations.writeFirstMessageInGroupChat
            : translations.writeMessageToStartChat,
        style: theme.textTheme.bodySmall,
      ),
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
      setState(() {
        _isTyping = _textEditingController.text.isNotEmpty;
      });
    });

    Future<void> sendMessage() async {
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

    Future<void> Function()? onClickSendMessage;
    if (_isTyping && !_isSending) {
      onClickSendMessage = () async => sendMessage();
    }

    var messageSendButtons = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
          onPressed: onClickSendMessage,
          icon: const Icon(
            Icons.send_rounded,
          ),
        ),
      ],
    );

    var defaultInputField = TextField(
      textAlign: TextAlign.start,
      textAlignVertical: TextAlignVertical.center,
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
        hintStyle: theme.textTheme.bodyMedium,
        fillColor: Colors.white,
        filled: true,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
          borderSide: BorderSide.none,
        ),
        suffixIcon: messageSendButtons,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 16,
      ),
      child: SizedBox(
        height: 45,
        child: widget.options.builders.messageInputBuilder?.call(
              context,
              _textEditingController,
              messageSendButtons,
              widget.options.translations,
            ) ??
            defaultInputField,
      ),
    );
  }
}

class _ChatBubble extends StatefulWidget {
  const _ChatBubble({
    required this.message,
    required this.onPressUserProfile,
    this.previousMessage,
    super.key,
  });
  final MessageModel message;
  final MessageModel? previousMessage;
  final Function(UserModel user) onPressUserProfile;

  @override
  State<_ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<_ChatBubble> {
  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;
    var service = chatScope.service;
    return StreamBuilder<UserModel>(
      stream: service.getUser(userId: widget.message.senderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        var user = snapshot.data!;

        return options.builders.chatMessageBuilder.call(
              context,
              widget.message,
              widget.previousMessage,
              user,
              widget.onPressUserProfile,
            ) ??
            DefaultChatMessageBuilder(
              message: widget.message,
              previousMessage: widget.previousMessage,
              user: user,
              onPressUserProfile: widget.onPressUserProfile,
            );
      },
    );
  }
}
