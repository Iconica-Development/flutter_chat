import "dart:async";
import "dart:typed_data";

import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_chat/src/config/screen_types.dart";
import "package:flutter_chat/src/screens/chat_detail/widgets/chat_bottom.dart";
import "package:flutter_chat/src/screens/chat_detail/widgets/chat_widgets.dart";
import "package:flutter_chat/src/screens/creation/widgets/default_image_picker.dart";
import "package:flutter_chat/src/util/scope.dart";
import "package:flutter_hooks/flutter_hooks.dart";

/// Chat detail screen
/// Seen when a user clicks on a chat
class ChatDetailScreen extends HookWidget {
  /// Constructs a [ChatDetailScreen].
  const ChatDetailScreen({
    required this.chatId,
    required this.onExit,
    required this.onPressChatTitle,
    required this.onPressUserProfile,
    required this.onUploadImage,
    required this.onMessageSubmit,
    required this.onReadChat,
    super.key,
  });

  /// The identifier of the chat that is being viewed.
  /// The chat will be fetched from the chat service.
  final String chatId;

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

  /// Callback for when the user wants to navigate back
  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;
    var service = chatScope.service;

    var chatTitle = useState<String?>(null);

    var chatStream = useMemoized(
      () => service.getChat(chatId: chatId),
      [chatId],
    );
    var chatSnapshot = useStream(chatStream);
    var chat = chatSnapshot.data;

    var allUsersStream = useMemoized(
      () => service.getAllUsersForChat(chatId: chatId),
      [chatId],
    );
    var usersSnapshot = useStream(allUsersStream);
    var allUsers = usersSnapshot.data ?? [];

    var chatIsloading =
        chatSnapshot.connectionState == ConnectionState.waiting ||
            usersSnapshot.connectionState == ConnectionState.waiting;

    useEffect(
      () {
        if (chat == null) return;
        chatTitle.value = _getChatTitle(
          chatScope: chatScope,
          chat: chat,
          allUsers: allUsers,
        );
        return;
      },
      [chat, allUsers],
    );

    useEffect(
      () {
        if (onExit == null) return null;
        chatScope.popHandler.add(onExit!);
        return () => chatScope.popHandler.remove(onExit!);
      },
      [onExit],
    );

    var appBar = _ChatAppBar(
      chatTitle: chatTitle.value,
      onPressChatTitle: onPressChatTitle,
      chatModel: chat,
      onPressBack: onExit,
    );

    var body = _ChatBody(
      chatId: chatId,
      chat: chat,
      chatUsers: allUsers,
      onPressUserProfile: onPressUserProfile,
      onUploadImage: onUploadImage,
      onMessageSubmit: onMessageSubmit,
      onReadChat: onReadChat,
      chatIsLoading: chatIsloading,
    );

    if (options.builders.chatScreenBuilder != null) {
      return options.builders.chatScreenBuilder!.call(
        context,
        chat,
        appBar,
        chatTitle.value,
        body,
      );
    }

    if (options.builders.baseScreenBuilder != null) {
      return options.builders.baseScreenBuilder!.call(
        context,
        mapScreenType,
        appBar,
        chatTitle.value,
        body,
      );
    }

    return Scaffold(
      appBar: appBar,
      body: body,
    );
  }

  String? _getChatTitle({
    required ChatScope chatScope,
    required ChatModel chat,
    required List<UserModel> allUsers,
  }) {
    var options = chatScope.options;
    var translations = options.translations;
    var title = options.chatTitleResolver?.call(chat);
    if (title != null) {
      return title;
    }

    if (chat.isGroupChat) {
      if (chat.chatName?.isNotEmpty ?? false) {
        return chat.chatName;
      }
      return translations.groupNameEmpty;
    }

    // For one-to-one, pick the 'other' user from the list
    var otherUser = allUsers
        .where(
          (u) => u.id != chatScope.userId,
        )
        .firstOrNull;

    return otherUser != null && otherUser.fullname != null
        ? otherUser.fullname
        : translations.anonymousUser;
  }
}

/// The app bar widget for the chat detail screen
class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar({
    required this.chatTitle,
    required this.chatModel,
    required this.onPressChatTitle,
    this.onPressBack,
  });

  final String? chatTitle;
  final ChatModel? chatModel;
  final Function(ChatModel) onPressChatTitle;
  final VoidCallback? onPressBack;

  @override
  Widget build(BuildContext context) {
    var options = ChatScope.of(context).options;
    var theme = Theme.of(context);

    VoidCallback? onPressChatTitle;
    if (chatModel != null) {
      onPressChatTitle = () => this.onPressChatTitle(chatModel!);
    }

    Widget? appBarIcon;
    if (onPressBack != null) {
      appBarIcon = InkWell(
        onTap: onPressBack,
        child: const Icon(Icons.arrow_back_ios),
      );
    }

    return AppBar(
      iconTheme: theme.appBarTheme.iconTheme,
      centerTitle: true,
      leading: appBarIcon,
      title: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: onPressChatTitle,
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

/// Body for the chat detail screen
/// Displays messages, a scrollable list, and a bottom input field.
class _ChatBody extends HookWidget {
  const _ChatBody({
    required this.chatId,
    required this.chat,
    required this.chatUsers,
    required this.onPressUserProfile,
    required this.onUploadImage,
    required this.onMessageSubmit,
    required this.onReadChat,
    required this.chatIsLoading,
  });

  final String chatId;
  final ChatModel? chat;
  final List<UserModel> chatUsers;
  final Function(UserModel) onPressUserProfile;
  final Function(Uint8List image) onUploadImage;
  final Function(String text) onMessageSubmit;
  final Function(ChatModel chat) onReadChat;
  final bool chatIsLoading;

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var service = chatScope.service;
    var options = chatScope.options;

    var isLoadingOlder = useState(false);
    var isLoadingNewer = useState(false);
    var autoScrollEnabled = useState(true);

    var messagesStream = useMemoized(
      () => service.getMessages(chatId: chatId),
      [chatId],
    );
    var messagesSnapshot = useStream(messagesStream);
    var messages = messagesSnapshot.data ?? [];

    var scrollController = useScrollController();

    Future<void> loadOlderMessages() async {
      if (messages.isEmpty || isLoadingOlder.value) return;
      isLoadingOlder.value = true;

      var oldestMsg = messages.first;
      var oldOffset = scrollController.offset;
      var oldMaxScroll = scrollController.position.maxScrollExtent;
      var oldCount = messages.length;

      try {
        debugPrint("loading old messages from message: ${oldestMsg.id}");
        await Future.wait([
          service.loadOldMessagesBefore(firstMessage: oldestMsg),
          Future.delayed(
            options.paginationControls.loadingOldMessageMinDuration,
          ),
        ]);
      } finally {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          if (!scrollController.hasClients) {
            isLoadingOlder.value = false;
            return;
          }
          var newCount = messages.length;
          if (newCount > oldCount) {
            var newMaxScroll = scrollController.position.maxScrollExtent;
            var diff = newMaxScroll - oldMaxScroll;
            scrollController.jumpTo(oldOffset + diff);
          }
          isLoadingOlder.value = false;
        });
      }
    }

    Future<void> loadNewerMessages() async {
      if (messages.isEmpty || isLoadingNewer.value) return;
      isLoadingNewer.value = true;

      var newestMsg = messages.last;
      try {
        debugPrint("loading new messages from message: ${newestMsg.id}");
        await Future.wait([
          service.loadNewMessagesAfter(lastMessage: newestMsg),
          Future.delayed(
            options.paginationControls.loadingNewMessageMinDuration,
          ),
        ]);
      } finally {
        if (context.mounted) {
          isLoadingNewer.value = false;
        }
      }
    }

    useEffect(() {
      void onScroll() {
        if (!scrollController.hasClients) return;

        var offset = scrollController.offset;
        var maxScroll = scrollController.position.maxScrollExtent;
        var threshold = options.paginationControls.scrollOffset;

        var distanceFromBottom = maxScroll - offset;

        if (distanceFromBottom > 50) {
          autoScrollEnabled.value = false;
        } else {
          autoScrollEnabled.value = true;
        }

        if (offset <= threshold && !isLoadingOlder.value) {
          unawaited(loadOlderMessages());
        }

        if (distanceFromBottom <= threshold && !isLoadingNewer.value) {
          unawaited(loadNewerMessages());
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [
      scrollController,
      isLoadingOlder.value,
      isLoadingNewer.value,
      chat,
    ]);

    useEffect(
      () {
        var disposed = false;

        /// Continuously scroll to the bottom of the chat
        Future<void> scrollLoop() async {
          while (!disposed && autoScrollEnabled.value) {
            await Future.delayed(const Duration(milliseconds: 500));
            if (disposed || !autoScrollEnabled.value) break;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (disposed || !autoScrollEnabled.value) return;
              if (scrollController.hasClients) {
                scrollController.jumpTo(
                  scrollController.position.maxScrollExtent,
                );
              }
            });
          }
        }

        unawaited(scrollLoop());

        return () => disposed = true;
      },
      [autoScrollEnabled.value],
    );

    var userMap = <String, UserModel>{};
    for (var u in chatUsers) {
      userMap[u.id] = u;
    }

    var topSpinner = (isLoadingOlder.value &&
            options.paginationControls.loadingIndicatorForOldMessages)
        ? options.builders.loadingChatMessageBuilder.call(context)
        : const SizedBox.shrink();

    var bottomSpinner = (isLoadingNewer.value &&
            options.paginationControls.loadingIndicatorForNewMessages)
        ? options.builders.loadingChatMessageBuilder.call(context)
        : const SizedBox.shrink();

    var bubbleChildren = <Widget>[];
    if (messages.isEmpty) {
      bubbleChildren
          .add(ChatNoMessages(isGroupChat: chat?.isGroupChat ?? false));
    } else {
      for (var (index, msg) in messages.indexed) {
        var prevMsg = index > 0 ? messages[index - 1] : null;

        bubbleChildren.add(
          ChatBubble(
            message: msg,
            previousMessage: prevMsg,
            sender: userMap[msg.senderId],
            onPressSender: onPressUserProfile,
          ),
        );
      }
    }

    var listViewChildren = [
      topSpinner,
      ...bubbleChildren,
      bottomSpinner,
    ];

    return Column(
      children: [
        if (chatIsLoading && options.enableLoadingIndicator) ...[
          Expanded(child: options.builders.loadingWidgetBuilder.call(context)),
        ] else ...[
          Expanded(
            child: ListView.builder(
              reverse: false,
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 24),
              itemCount: listViewChildren.length,
              itemBuilder: (context, index) => listViewChildren[index],
            ),
          ),
        ],
        ChatBottomInputSection(
          chat: chat,
          isLoading: chatIsLoading,
          onPressSelectImage: () async => onPressSelectImage(
            context,
            options,
            onUploadImage,
          ),
          onMessageSubmit: onMessageSubmit,
        ),
      ],
    );
  }
}
