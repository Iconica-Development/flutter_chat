import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_chat/src/config/chat_options.dart";
import "package:flutter_chat/src/config/chat_translations.dart";
import "package:flutter_chat/src/config/screen_types.dart";
import "package:flutter_chat/src/services/date_formatter.dart";
import "package:flutter_chat/src/util/scope.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:flutter_profile/flutter_profile.dart";

/// The chat screen
/// Seen when a user is chatting
class ChatScreen extends HookWidget {
  /// Constructs a [ChatScreen]
  const ChatScreen({
    required this.onPressChat,
    required this.onDeleteChat,
    required this.onExit,
    this.onPressStartChat,
    super.key,
  });

  /// Callback function for starting a chat.
  final Function()? onPressStartChat;

  /// Callback function for pressing on a chat.
  final void Function(ChatModel chat) onPressChat;

  /// Callback function for deleting a chat.
  final void Function(ChatModel chat) onDeleteChat;

  /// Callback for when the user wants to navigate back
  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;
    var service = chatScope.service;

    useEffect(() {
      if (onExit == null) return null;
      chatScope.popHandler.add(onExit!);
      return () => chatScope.popHandler.remove(onExit!);
    });

    if (options.builders.baseScreenBuilder == null) {
      return Scaffold(
        appBar: _AppBar(
          chatOptions: options,
          chatService: service,
        ),
        body: _Body(
          chatOptions: options,
          chatService: service,
          onPressChat: onPressChat,
          onPressStartChat: onPressStartChat,
          onDeleteChat: onDeleteChat,
        ),
      );
    }

    return options.builders.baseScreenBuilder!.call(
      context,
      mapScreenType,
      _AppBar(
        chatOptions: options,
        chatService: service,
      ),
      _Body(
        chatOptions: options,
        chatService: service,
        onPressChat: onPressChat,
        onPressStartChat: onPressStartChat,
        onDeleteChat: onDeleteChat,
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({
    required this.chatOptions,
    required this.chatService,
  });

  final ChatOptions chatOptions;
  final ChatService chatService;

  @override
  Widget build(BuildContext context) {
    var translations = chatOptions.translations;
    var theme = Theme.of(context);

    return AppBar(
      title: Text(
        translations.chatsTitle,
      ),
      actions: [
        StreamBuilder<int>(
          stream: chatService.getUnreadMessagesCount(),
          builder: (BuildContext context, snapshot) => Align(
            alignment: Alignment.centerRight,
            child: Visibility(
              visible: (snapshot.data ?? 0) > 0,
              child: Padding(
                padding: const EdgeInsets.only(right: 22.0),
                child: Text(
                  "${snapshot.data ?? 0} ${translations.chatsUnread}",
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(
        kToolbarHeight,
      );
}

class _Body extends StatefulWidget {
  const _Body({
    required this.chatOptions,
    required this.chatService,
    required this.onPressChat,
    required this.onDeleteChat,
    this.onPressStartChat,
  });

  final ChatOptions chatOptions;
  final ChatService chatService;
  final Function(ChatModel chat) onPressChat;
  final Function()? onPressStartChat;
  final Function(ChatModel) onDeleteChat;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final ScrollController controller = ScrollController();
  bool _hasCalledOnNoChats = false;

  @override
  Widget build(BuildContext context) {
    var translations = widget.chatOptions.translations;
    var theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: controller,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
            children: [
              StreamBuilder<List<ChatModel>?>(
                stream: widget.chatService.getChats(),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                          (snapshot.data?.isEmpty ?? true) ||
                      (snapshot.data != null && snapshot.data!.isEmpty)) {
                    if (widget.chatOptions.onNoChats != null &&
                        !_hasCalledOnNoChats) {
                      _hasCalledOnNoChats = true; // Set the flag to true
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        // ignore: avoid_dynamic_calls
                        await widget.chatOptions.onNoChats!.call();
                      });
                    }
                    return Center(
                      child: Text(
                        translations.noChatsFound,
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (ChatModel chat in snapshot.data ?? []) ...[
                        DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: theme.dividerColor,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Builder(
                            builder: (context) => !chat.canBeDeleted
                                ? Dismissible(
                                    confirmDismiss: (_) async {
                                      await widget.chatOptions.builders
                                              .deleteChatDialogBuilder
                                              ?.call(context, chat) ??
                                          _deleteDialog(
                                            chat,
                                            translations,
                                            // ignore: use_build_context_synchronously
                                            context,
                                          );
                                      return _deleteDialog(
                                        chat,
                                        translations,
                                        // ignore: use_build_context_synchronously
                                        context,
                                      );
                                    },
                                    onDismissed: (_) {
                                      widget.onDeleteChat(chat);
                                    },
                                    secondaryBackground: const ColoredBox(
                                      color: Colors.red,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    background: const ColoredBox(
                                      color: Colors.red,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    key: ValueKey(
                                      chat.id,
                                    ),
                                    child: _ChatItem(
                                      service: widget.chatService,
                                      chat: chat,
                                      chatOptions: widget.chatOptions,
                                      onPressChat: widget.onPressChat,
                                    ),
                                  )
                                : _ChatItem(
                                    service: widget.chatService,
                                    chat: chat,
                                    chatOptions: widget.chatOptions,
                                    onPressChat: widget.onPressChat,
                                  ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        if (widget.onPressStartChat != null)
          widget.chatOptions.builders.newChatButtonBuilder?.call(
                context,
                widget.onPressStartChat!,
                translations,
              ) ??
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 4,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    fixedSize: const Size(254, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(56),
                    ),
                  ),
                  onPressed: widget.onPressStartChat,
                  child: Text(
                    translations.newChatButton,
                    style: theme.textTheme.displayLarge,
                  ),
                ),
              ),
      ],
    );
  }
}

class _ChatItem extends StatelessWidget {
  const _ChatItem({
    required this.chat,
    required this.chatOptions,
    required this.service,
    required this.onPressChat,
  });

  final ChatModel chat;
  final ChatOptions chatOptions;
  final ChatService service;
  final Function(ChatModel chat) onPressChat;

  @override
  Widget build(BuildContext context) {
    var dateFormatter = DateFormatter(
      options: chatOptions,
    );
    var theme = Theme.of(context);
    return InkWell(
      onTap: () {
        onPressChat(chat);
      },
      child: chatOptions.builders.chatRowContainerBuilder?.call(
            context,
            _ChatListItem(
              chat: chat,
              options: chatOptions,
              dateFormatter: dateFormatter,
              chatService: service,
            ),
          ) ??
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor,
                  width: 0.5,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _ChatListItem(
                chat: chat,
                options: chatOptions,
                dateFormatter: dateFormatter,
                chatService: service,
              ),
            ),
          ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  const _ChatListItem({
    required this.chat,
    required this.options,
    required this.dateFormatter,
    required this.chatService,
  });

  final ChatModel chat;
  final ChatOptions options;
  final DateFormatter dateFormatter;
  final ChatService chatService;

  @override
  Widget build(BuildContext context) {
    var scope = ChatScope.of(context);
    var currentUserId = scope.userId;
    var translations = options.translations;
    if (chat.isGroupChat) {
      return StreamBuilder<MessageModel?>(
        stream: chat.lastMessage != null
            ? chatService.getMessage(
                chatId: chat.id,
                messageId: chat.lastMessage!,
              )
            : const Stream.empty(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var data = snapshot.data;

          var showUnreadMessageCount =
              data != null && data.senderId != currentUserId;

          return _ChatRow(
            title: chat.chatName ?? translations.groupNameEmpty,
            unreadMessages:
                showUnreadMessageCount ? chat.unreadMessageCount : 0,
            subTitle: data != null
                ? data.isTextMessage
                    ? data.text
                    : "📷 "
                        "${translations.image}"
                : "",
            avatar: options.builders.groupAvatarBuilder?.call(
                  context,
                  chat.chatName ?? translations.groupNameEmpty,
                  chat.imageUrl,
                  40.0,
                ) ??
                Avatar(
                  boxfit: BoxFit.cover,
                  user: User(
                    firstName: chat.chatName,
                    lastName: null,
                    imageUrl: chat.imageUrl != null || chat.imageUrl != ""
                        ? chat.imageUrl
                        : null,
                  ),
                  size: 40.0,
                ),
            lastUsed: chat.lastUsed != null
                ? dateFormatter.format(
                    date: chat.lastUsed!,
                  )
                : null,
          );
        },
      );
    }
    var otherUser = chat.users.firstWhere(
      (element) => element != currentUserId,
    );

    return StreamBuilder<UserModel>(
      stream: chatService.getUser(userId: otherUser),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        var otherUser = snapshot.data;

        if (otherUser == null) {
          return const SizedBox();
        }

        return StreamBuilder<MessageModel?>(
          stream: chat.lastMessage != null
              ? chatService.getMessage(
                  chatId: chat.id,
                  messageId: chat.lastMessage!,
                )
              : const Stream.empty(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            var data = snapshot.data;

            var showUnreadMessageCount =
                data != null && data.senderId != currentUserId;

            return _ChatRow(
              unreadMessages:
                  showUnreadMessageCount ? chat.unreadMessageCount : 0,
              avatar: options.builders.userAvatarBuilder?.call(
                    context,
                    otherUser,
                    40.0,
                  ) ??
                  Avatar(
                    boxfit: BoxFit.cover,
                    user: User(
                      firstName: otherUser.firstName,
                      lastName: otherUser.lastName,
                      imageUrl:
                          otherUser.imageUrl != null || otherUser.imageUrl != ""
                              ? otherUser.imageUrl
                              : null,
                    ),
                    size: 40.0,
                  ),
              title: otherUser.fullname ?? translations.anonymousUser,
              subTitle: data != null
                  ? data.isTextMessage
                      ? data.text
                      : "📷 "
                          "${translations.image}"
                  : "",
              lastUsed: chat.lastUsed != null
                  ? dateFormatter.format(
                      date: chat.lastUsed!,
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}

Future<bool?> _deleteDialog(
  ChatModel chat,
  ChatTranslations translations,
  BuildContext context,
) async {
  var theme = Theme.of(context);

  return showModalBottomSheet<bool>(
    context: context,
    builder: (BuildContext context) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            translations.deleteChatModalTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            translations.deleteChatModalDescription,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: FilledButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(true);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    translations.deleteChatModalConfirm,
                    style: theme.textTheme.displayLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ChatRow extends StatelessWidget {
  const _ChatRow({
    required this.title,
    this.unreadMessages = 0,
    this.lastUsed,
    this.subTitle,
    this.avatar,
  });

  /// The title of the chat.
  final String title;

  /// The number of unread messages in the chat.
  final int unreadMessages;

  /// The last time the chat was used.
  final String? lastUsed;

  /// The subtitle of the chat.
  final String? subTitle;

  /// The avatar associated with the chat.
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: avatar,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                if (subTitle != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Text(
                      subTitle!,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (lastUsed != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  lastUsed!,
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ],
            if (unreadMessages > 0) ...[
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    unreadMessages.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
