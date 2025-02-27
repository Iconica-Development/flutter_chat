import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_accessibility/flutter_accessibility.dart";
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
    var translations = options.translations;

    useEffect(() {
      if (onExit == null) return null;
      chatScope.popHandler.add(onExit!);
      return () => chatScope.popHandler.remove(onExit!);
    });

    if (options.builders.baseScreenBuilder == null) {
      return Scaffold(
        appBar: const _AppBar(),
        body: _Body(
          onPressChat: onPressChat,
          onPressStartChat: onPressStartChat,
          onDeleteChat: onDeleteChat,
        ),
      );
    }

    return options.builders.baseScreenBuilder!.call(
      context,
      mapScreenType,
      const _AppBar(),
      translations.chatsTitle,
      _Body(
        onPressChat: onPressChat,
        onPressStartChat: onPressStartChat,
        onDeleteChat: onDeleteChat,
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var service = chatScope.service;
    var options = chatScope.options;
    var translations = options.translations;
    var theme = Theme.of(context);

    return AppBar(
      title: Text(
        translations.chatsTitle,
      ),
      actions: [
        StreamBuilder<int>(
          stream: service.getUnreadMessagesCount(),
          builder: (BuildContext context, snapshot) => Align(
            alignment: Alignment.centerRight,
            child: Visibility(
              visible: (snapshot.data ?? 0) > 0,
              child: Padding(
                padding: const EdgeInsets.only(right: 22.0),
                child: CustomSemantics(
                  identifier: options.semantics.chatUnreadMessages,
                  value: "${snapshot.data ?? 0} ${translations.chatsUnread}",
                  child: Text(
                    "${snapshot.data ?? 0} ${translations.chatsUnread}",
                    style: theme.textTheme.bodySmall,
                  ),
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
    required this.onPressChat,
    required this.onDeleteChat,
    this.onPressStartChat,
  });

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
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;
    var service = chatScope.service;
    var translations = options.translations;
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
                stream: service.getChats(),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                          (snapshot.data?.isEmpty ?? true) ||
                      (snapshot.data != null && snapshot.data!.isEmpty)) {
                    if (options.onNoChats != null && !_hasCalledOnNoChats) {
                      _hasCalledOnNoChats = true; // Set the flag to true
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        // ignore: avoid_dynamic_calls
                        await options.onNoChats!.call();
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
                      for (var (index, ChatModel chat)
                          in (snapshot.data ?? []).indexed) ...[
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
                            builder: (context) {
                              var semantics = options.semantics;

                              var chatItem = _ChatItem(
                                chat: chat,
                                onPressChat: widget.onPressChat,
                                semanticIdTitle:
                                    semantics.chatsChatTitle(index),
                                semanticIdSubTitle:
                                    semantics.chatsChatSubTitle(index),
                                semanticIdLastUsed:
                                    semantics.chatsChatLastUsed(index),
                                semanticIdUnreadMessages:
                                    semantics.chatsChatUnreadMessages(index),
                                semanticIdButton:
                                    semantics.chatsOpenChatButton(index),
                              );

                              return !chat.canBeDeleted
                                  ? Dismissible(
                                      confirmDismiss: (_) async {
                                        await options.builders
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
                                      child: chatItem,
                                    )
                                  : chatItem;
                            },
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
          options.builders.newChatButtonBuilder?.call(
                context,
                widget.onPressStartChat!,
                translations,
              ) ??
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 4,
                ),
                child: CustomSemantics(
                  identifier: options.semantics.chatsStartChatButton,
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
              ),
      ],
    );
  }
}

class _ChatItem extends StatelessWidget {
  const _ChatItem({
    required this.chat,
    required this.onPressChat,
    required this.semanticIdTitle,
    required this.semanticIdSubTitle,
    required this.semanticIdLastUsed,
    required this.semanticIdUnreadMessages,
    required this.semanticIdButton,
  });

  final ChatModel chat;
  final Function(ChatModel chat) onPressChat;
  final String semanticIdTitle;
  final String semanticIdSubTitle;
  final String semanticIdLastUsed;
  final String semanticIdUnreadMessages;
  final String semanticIdButton;

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;
    var dateFormatter = DateFormatter(
      options: options,
    );
    var theme = Theme.of(context);

    var chatListItem = _ChatListItem(
      chat: chat,
      dateFormatter: dateFormatter,
      semanticIdTitle: semanticIdTitle,
      semanticIdSubTitle: semanticIdSubTitle,
      semanticIdLastUsed: semanticIdLastUsed,
      semanticIdUnreadMessages: semanticIdUnreadMessages,
    );

    return CustomSemantics(
      identifier: semanticIdButton,
      buttonWithVariableText: true,
      child: InkWell(
        onTap: () {
          onPressChat(chat);
        },
        child: options.builders.chatRowContainerBuilder?.call(
              context,
              chatListItem,
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
                child: chatListItem,
              ),
            ),
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  const _ChatListItem({
    required this.chat,
    required this.dateFormatter,
    required this.semanticIdTitle,
    required this.semanticIdSubTitle,
    required this.semanticIdLastUsed,
    required this.semanticIdUnreadMessages,
  });

  final ChatModel chat;
  final DateFormatter dateFormatter;
  final String semanticIdTitle;
  final String semanticIdSubTitle;
  final String semanticIdLastUsed;
  final String semanticIdUnreadMessages;

  @override
  Widget build(BuildContext context) {
    var scope = ChatScope.of(context);
    var service = scope.service;
    var options = scope.options;
    var currentUserId = scope.userId;
    var translations = options.translations;
    if (chat.isGroupChat) {
      return StreamBuilder<MessageModel?>(
        stream: chat.lastMessage != null
            ? service.getMessage(
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
            semanticIdTitle: semanticIdTitle,
            semanticIdSubTitle: semanticIdSubTitle,
            semanticIdLastUsed: semanticIdLastUsed,
            semanticIdUnreadMessages: semanticIdUnreadMessages,
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
      stream: service.getUser(userId: otherUser),
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
              ? service.getMessage(
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
              semanticIdTitle: semanticIdTitle,
              semanticIdSubTitle: semanticIdSubTitle,
              semanticIdLastUsed: semanticIdLastUsed,
              semanticIdUnreadMessages: semanticIdUnreadMessages,
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

  var scope = ChatScope.of(context);

  var options = scope.options;

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
            child: CustomSemantics(
              identifier: options.semantics.chatsDeleteConfirmButton,
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
          ),
        ],
      ),
    ),
  );
}

class _ChatRow extends StatelessWidget {
  const _ChatRow({
    required this.title,
    required this.semanticIdTitle,
    required this.semanticIdSubTitle,
    required this.semanticIdLastUsed,
    required this.semanticIdUnreadMessages,
    this.unreadMessages = 0,
    this.lastUsed,
    this.subTitle,
    this.avatar,
  });

  /// The title of the chat.
  final String title;
  final String semanticIdTitle;

  /// The number of unread messages in the chat.
  final int unreadMessages;
  final String semanticIdUnreadMessages;

  /// The last time the chat was used.
  final String? lastUsed;
  final String semanticIdLastUsed;

  /// The subtitle of the chat.
  final String? subTitle;
  final String semanticIdSubTitle;

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
                CustomSemantics(
                  identifier: semanticIdTitle,
                  value: title,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (subTitle != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: CustomSemantics(
                      identifier: semanticIdSubTitle,
                      value: subTitle,
                      child: Text(
                        subTitle!,
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
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
                child: CustomSemantics(
                  identifier: semanticIdLastUsed,
                  value: lastUsed,
                  child: Text(
                    lastUsed!,
                    style: theme.textTheme.labelSmall,
                  ),
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
                  child: CustomSemantics(
                    identifier: semanticIdUnreadMessages,
                    value: unreadMessages.toString(),
                    child: Text(
                      unreadMessages.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                      ),
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
