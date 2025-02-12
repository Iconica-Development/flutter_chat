import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_chat/src/config/chat_options.dart";
import "package:flutter_chat/src/config/screen_types.dart";
import "package:flutter_chat/src/util/scope.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:flutter_profile/flutter_profile.dart";

/// The chat profile screen
/// Seen when a user taps on a chat profile
/// Also used for group chats
class ChatProfileScreen extends HookWidget {
  /// Constructs a [ChatProfileScreen]
  const ChatProfileScreen({
    required this.onExit,
    required this.userModel,
    required this.chatModel,
    required this.onTapUser,
    required this.onPressStartChat,
    super.key,
  });

  /// The user model of the persons profile to be viewed
  final UserModel? userModel;

  /// The chat model of the chat being viewed
  final ChatModel? chatModel;

  /// Callback function triggered when a user is tapped
  final Function(String)? onTapUser;

  /// Callback function triggered when the start chat button is pressed
  final Function(String)? onPressStartChat;

  /// Callback for when the user wants to navigate back
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;
    var service = chatScope.service;
    var userId = chatScope.userId;

    useEffect(() {
      chatScope.popHandler.add(onExit);
      return () => chatScope.popHandler.remove(onExit);
    });

    if (options.builders.baseScreenBuilder == null) {
      return Scaffold(
        appBar: _AppBar(
          user: userModel,
          chat: chatModel,
          options: options,
        ),
        body: _Body(
          currentUser: userId,
          options: options,
          service: service,
          user: userModel,
          chat: chatModel,
          onTapUser: onTapUser,
          onPressStartChat: onPressStartChat,
        ),
      );
    }

    return options.builders.baseScreenBuilder!.call(
      context,
      mapScreenType,
      _AppBar(
        user: userModel,
        chat: chatModel,
        options: options,
      ),
      _Body(
        currentUser: userId,
        options: options,
        service: service,
        user: userModel,
        chat: chatModel,
        onTapUser: onTapUser,
        onPressStartChat: onPressStartChat,
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({
    required this.user,
    required this.chat,
    required this.options,
  });

  final UserModel? user;
  final ChatModel? chat;
  final ChatOptions options;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return AppBar(
      iconTheme: theme.appBarTheme.iconTheme ??
          const IconThemeData(color: Colors.white),
      title: Text(
        user != null
            ? "${user!.fullname}"
            : chat != null
                ? chat?.chatName ?? options.translations.groupNameEmpty
                : "",
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _Body extends StatelessWidget {
  const _Body({
    required this.options,
    required this.service,
    required this.user,
    required this.chat,
    required this.onPressStartChat,
    required this.onTapUser,
    required this.currentUser,
  });

  final ChatOptions options;
  final ChatService service;
  final UserModel? user;
  final ChatModel? chat;
  final Function(String)? onTapUser;
  final Function(String)? onPressStartChat;
  final String currentUser;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    var chatUserDisplay = Wrap(
      children: [
        ...chat!.users.map(
          (tappedUser) => Padding(
            padding: const EdgeInsets.only(
              bottom: 8,
              right: 8,
            ),
            child: InkWell(
              onTap: () {
                onTapUser?.call(tappedUser);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder<UserModel>(
                    future: service.getUser(userId: tappedUser).first,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      var user = snapshot.data;

                      if (user == null) {
                        return const SizedBox.shrink();
                      }

                      return options.builders.userAvatarBuilder?.call(
                            context,
                            user,
                            44,
                          ) ??
                          Avatar(
                            boxfit: BoxFit.cover,
                            user: User(
                              firstName: user.firstName,
                              lastName: user.lastName,
                              imageUrl:
                                  user.imageUrl != null || user.imageUrl != ""
                                      ? user.imageUrl
                                      : null,
                            ),
                            size: 60,
                          );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    var targetUser = user ??
        (
          chat != null
              ? UserModel(
                  id: UniqueKey().toString(),
                  firstName: chat?.chatName,
                  imageUrl: chat?.imageUrl,
                )
              : UserModel(
                  id: UniqueKey().toString(),
                  firstName: options.translations.groupNameEmpty,
                ),
        ) as UserModel;
    return Stack(
      children: [
        ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  options.builders.userAvatarBuilder?.call(
                        context,
                        targetUser,
                        60,
                      ) ??
                      Avatar(
                        boxfit: BoxFit.cover,
                        user: user != null
                            ? User(
                                firstName: user?.firstName,
                                lastName: user?.lastName,
                                imageUrl: user?.imageUrl != null ||
                                        user?.imageUrl != ""
                                    ? user?.imageUrl
                                    : null,
                              )
                            : chat != null
                                ? User(
                                    firstName: chat?.chatName,
                                    imageUrl: chat?.imageUrl != null ||
                                            chat?.imageUrl != ""
                                        ? chat?.imageUrl
                                        : null,
                                  )
                                : User(
                                    firstName:
                                        options.translations.groupNameEmpty,
                                  ),
                        size: 60,
                      ),
                ],
              ),
            ),
            const Divider(
              color: Colors.white,
              thickness: 10,
            ),
            if (chat != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      options.translations.groupProfileBioHeader,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      chat!.description ?? "",
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      options.translations.chatProfileUsers,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    chatUserDisplay,
                  ],
                ),
              ),
            ],
          ],
        ),
        if (user?.id != currentUser) ...[
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 24,
                horizontal: 80,
              ),
              child: FilledButton(
                onPressed: () {
                  onPressStartChat?.call(user!.id);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      options.translations.newChatButton,
                      style: theme.textTheme.displayLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
