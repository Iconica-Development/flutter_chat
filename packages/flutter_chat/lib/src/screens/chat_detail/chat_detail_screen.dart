import "dart:async";
import "dart:typed_data";

import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_chat/src/config/screen_types.dart";
import "package:flutter_chat/src/screens/chat_detail/widgets/chat_bottom.dart";
import "package:flutter_chat/src/screens/chat_detail/widgets/chat_widgets.dart";
import "package:flutter_chat/src/screens/creation/widgets/image_picker.dart";
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
    );

    if (options.builders.baseScreenBuilder == null) {
      return Scaffold(
        appBar: appBar,
        body: body,
      );
    }

    return options.builders.baseScreenBuilder!.call(
      context,
      mapScreenType,
      appBar,
      chatTitle.value,
      body,
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
  });

  final String chatId;
  final ChatModel? chat;
  final List<UserModel> chatUsers;
  final Function(UserModel) onPressUserProfile;
  final Function(Uint8List image) onUploadImage;
  final Function(String message) onMessageSubmit;
  final Function(ChatModel chat) onReadChat;

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;
    var service = chatScope.service;

    var page = useState(0);
    var showIndicator = useState(false);
    var controller = useScrollController();

    /// Trigger to load new page when scrolling to the bottom
    void handleScroll(PointerMoveEvent _) {
      if (!showIndicator.value &&
          controller.offset >= controller.position.maxScrollExtent &&
          !controller.position.outOfRange) {
        showIndicator.value = true;
        page.value++;

        Future.delayed(const Duration(seconds: 2), () {
          if (!controller.hasClients) return;
          showIndicator.value = false;
        });
      }
    }

    if (chat == null) {
      return const Center(child: CircularProgressIndicator());
    }

    var messagesStream = useMemoized(
      () => service.getMessages(
        chatId: chat!.id,
      ),
      [chat!.id, page.value],
    );
    var messagesSnapshot = useStream(messagesStream);
    var messages = messagesSnapshot.data?.reversed.toList() ?? [];

    if (messagesSnapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    var listViewChildren = messages.isEmpty && !showIndicator.value
        ? [
            ChatNoMessages(isGroupChat: chat!.isGroupChat),
          ]
        : [
            for (var (index, message) in messages.indexed) ...[
              if (chat!.id == message.chatId)
                ChatBubble(
                  key: ValueKey(message.id),
                  sender: chatUsers
                      .where(
                        (u) => u.id == message.senderId,
                      )
                      .firstOrNull,
                  message: message,
                  previousMessage:
                      index < messages.length - 1 ? messages[index + 1] : null,
                  onPressSender: onPressUserProfile,
                ),
            ],
          ];

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Listener(
                onPointerMove: handleScroll,
                child: ListView(
                  shrinkWrap: true,
                  controller: controller,
                  physics: const AlwaysScrollableScrollPhysics(),
                  reverse: messages.isNotEmpty,
                  padding: const EdgeInsets.only(top: 24.0),
                  children: listViewChildren,
                ),
              ),
            ),
            ChatBottomInputSection(
              chat: chat!,
              onPressSelectImage: () async => onPressSelectImage(
                context,
                options,
                onUploadImage,
              ),
              onMessageSubmit: onMessageSubmit,
            ),
          ],
        ),
        if (showIndicator.value && options.enableLoadingIndicator)
          options.builders.loadingWidgetBuilder(context) ??
              const SizedBox.shrink(),
      ],
    );
  }
}
