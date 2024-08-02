import 'package:chat_repository_interface/chat_repository_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/src/config/chat_options.dart';
import 'package:flutter_profile/flutter_profile.dart';

class ChatProfileScreen extends StatelessWidget {
  const ChatProfileScreen({
    super.key,
    required this.options,
    required this.userId,
    required this.userModel,
    required this.chatModel,
    required this.onTapUser,
    required this.onPressStartChat,
  });

  final ChatOptions options;
  final String userId;
  final UserModel? userModel;
  final ChatModel? chatModel;
  final Function(UserModel)? onTapUser;
  final Function(UserModel)? onPressStartChat;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return options.builders.chatProfileScaffoldBuilder?.call(
          _AppBar(
            user: userModel,
            chat: chatModel,
            options: options,
          ) as AppBar,
          _Body(
            currentUser: userId,
            options: options,
            user: userModel,
            chat: chatModel,
            onTapUser: onTapUser,
            onPressStartChat: onPressStartChat,
          ),
          theme.scaffoldBackgroundColor,
        ) ??
        Scaffold(
          appBar: _AppBar(
            user: userModel,
            chat: chatModel,
            options: options,
          ),
          body: _Body(
            currentUser: userId,
            options: options,
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
            ? '${user!.fullname}'
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
    required this.user,
    required this.chat,
    required this.onPressStartChat,
    required this.onTapUser,
    required this.currentUser,
  });

  final ChatOptions options;
  final UserModel? user;
  final ChatModel? chat;
  final Function(UserModel)? onTapUser;
  final Function(UserModel)? onPressStartChat;
  final String currentUser;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Stack(
      children: [
        ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  options.builders.userAvatarBuilder?.call(
                        user ??
                            (
                              chat != null
                                  ? UserModel(
                                      id: UniqueKey().toString(),
                                      firstName: chat?.chatName,
                                      imageUrl: chat?.imageUrl,
                                    )
                                  : UserModel(
                                      id: UniqueKey().toString(),
                                      firstName:
                                          options.translations.groupNameEmpty,
                                    ),
                            ) as UserModel,
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
                      style: theme.textTheme.bodyMedium!
                          .copyWith(color: Colors.black),
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
                    Wrap(
                      children: [
                        ...chat!.users.map(
                          (tappedUser) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: 8,
                              right: 8,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                onTapUser?.call(tappedUser);
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  options.builders.userAvatarBuilder?.call(
                                        tappedUser,
                                        44,
                                      ) ??
                                      Avatar(
                                        boxfit: BoxFit.cover,
                                        user: User(
                                          firstName: tappedUser.firstName,
                                          lastName: tappedUser.lastName,
                                          imageUrl:
                                              tappedUser.imageUrl != null ||
                                                      tappedUser.imageUrl != ""
                                                  ? tappedUser.imageUrl
                                                  : null,
                                        ),
                                        size: 60,
                                      ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        if (user != null && user!.id != currentUser) ...[
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 24,
                horizontal: 80,
              ),
              child: FilledButton(
                onPressed: () {
                  onPressStartChat?.call(user!);
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
