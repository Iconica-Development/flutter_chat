import 'package:chat_repository_interface/chat_repository_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/src/config/chat_options.dart';
import 'package:flutter_chat/src/config/chat_translations.dart';
import 'package:flutter_chat/src/services/date_formatter.dart';
import "package:flutter_profile/flutter_profile.dart";

class ChatScreen extends StatelessWidget {
  const ChatScreen({
    super.key,
    required this.userId,
    required this.chatService,
    required this.chatOptions,
    required this.onPressChat,
    required this.onDeleteChat,
    this.onPressStartChat,
  });

  final String userId;
  final ChatService chatService;
  final ChatOptions chatOptions;

  /// Callback function for starting a chat.
  final Function()? onPressStartChat;

  /// Callback function for pressing on a chat.
  final void Function(ChatModel chat) onPressChat;

  final void Function(ChatModel chat) onDeleteChat;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return chatOptions.builders.chatScreenScaffoldBuilder?.call(
          _AppBar(
            userId: userId,
            chatOptions: chatOptions,
            chatService: chatService,
          ) as AppBar,
          _Body(
            userId: userId,
            chatOptions: chatOptions,
            chatService: chatService,
            onPressChat: onPressChat,
            onPressStartChat: onPressStartChat,
            onDeleteChat: onDeleteChat,
          ),
          theme.scaffoldBackgroundColor,
        ) ??
        Scaffold(
          appBar: _AppBar(
            userId: userId,
            chatOptions: chatOptions,
            chatService: chatService,
          ),
          body: _Body(
            userId: userId,
            chatOptions: chatOptions,
            chatService: chatService,
            onPressChat: onPressChat,
            onPressStartChat: onPressStartChat,
            onDeleteChat: onDeleteChat,
          ),
        );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({
    required this.userId,
    required this.chatOptions,
    required this.chatService,
  });

  final String userId;
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
          stream: chatService.getUnreadMessagesCount(userId: userId),
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
    required this.userId,
    required this.chatOptions,
    required this.chatService,
    required this.onPressChat,
    required this.onDeleteChat,
    this.onPressStartChat,
  });

  final String userId;
  final ChatOptions chatOptions;
  final ChatService chatService;
  final Function(ChatModel chat) onPressChat;
  final Function()? onPressStartChat;
  final Function(ChatModel) onDeleteChat;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  ScrollController controller = ScrollController();
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
                stream: widget.chatService.getChats(userId: widget.userId),
                builder: (BuildContext context, snapshot) {
                  // if the stream is done, empty and noChats is set we should call that
                  if (snapshot.connectionState == ConnectionState.done &&
                          (snapshot.data?.isEmpty ?? true) ||
                      (snapshot.data != null && snapshot.data!.isEmpty)) {
                    if (widget.chatOptions.onNoChats != null &&
                        !_hasCalledOnNoChats) {
                      _hasCalledOnNoChats = true; // Set the flag to true
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
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
                      for (ChatModel chat in (snapshot.data ?? [])) ...[
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
                                      widget.chatOptions.builders
                                              .deleteChatDialogBuilder
                                              ?.call(context, chat) ??
                                          _deleteDialog(
                                            chat,
                                            translations,
                                            context,
                                          );
                                      return _deleteDialog(
                                        chat,
                                        translations,
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
                                      chat.id.toString(),
                                    ),
                                    child: ChatListItem(
                                      chat: chat,
                                      chatOptions: widget.chatOptions,
                                      userId: widget.userId,
                                      onPressChat: widget.onPressChat,
                                    ),
                                  )
                                : ChatListItem(
                                    chat: chat,
                                    chatOptions: widget.chatOptions,
                                    userId: widget.userId,
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
                  onPressed: widget.onPressStartChat!,
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

class ChatListItem extends StatelessWidget {
  const ChatListItem({
    required this.chat,
    required this.chatOptions,
    required this.userId,
    required this.onPressChat,
    super.key,
  });

  final ChatModel chat;
  final ChatOptions chatOptions;
  final String userId;
  final Function(ChatModel chat) onPressChat;

  @override
  Widget build(BuildContext context) {
    var dateFormatter = DateFormatter(
      options: chatOptions,
    );
    var theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        onPressChat(chat);
      },
      child: chatOptions.builders.chatRowContainerBuilder?.call(
            _ChatListItem(
              chat: chat,
              options: chatOptions,
              dateFormatter: dateFormatter,
              currentUserId: userId,
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
                currentUserId: userId,
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
    required this.currentUserId,
  });

  final ChatModel chat;
  final ChatOptions options;
  final DateFormatter dateFormatter;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    var translations = options.translations;
    if (chat.isGroupChat) {
      return _ChatRow(
        title: chat.chatName ?? translations.groupNameEmpty,
        unreadMessages: chat.unreadMessageCount,
        subTitle: chat.lastMessage != null
            ? chat.lastMessage!.isTextMessage()
                ? chat.lastMessage!.text
                : "📷 "
                    "${translations.image}"
            : "",
        avatar: options.builders.groupAvatarBuilder?.call(
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
    }
    var otherUser = chat.users.firstWhere(
      (element) => element.id != currentUserId,
    );

    return _ChatRow(
      unreadMessages: chat.unreadMessageCount,
      avatar: options.builders.userAvatarBuilder?.call(
            otherUser,
            40.0,
          ) ??
          Avatar(
            boxfit: BoxFit.cover,
            user: User(
              firstName: otherUser.firstName,
              lastName: otherUser.lastName,
              imageUrl: otherUser.imageUrl != null || otherUser.imageUrl != ""
                  ? otherUser.imageUrl
                  : null,
            ),
            size: 40.0,
          ),
      title: otherUser.fullname ?? translations.anonymousUser,
      subTitle: chat.lastMessage != null
          ? chat.lastMessage!.isTextMessage()
              ? chat.lastMessage!.text
              : "📷 "
                  "${translations.image}"
          : "",
      lastUsed: chat.lastUsed != null
          ? dateFormatter.format(
              date: chat.lastUsed!,
            )
          : null,
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
    super.key,
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
                      style: unreadMessages > 0
                          ? theme.textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.w800,
                            )
                          : theme.textTheme.bodySmall,
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
