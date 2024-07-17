import "package:flutter/material.dart";
import "package:flutter_chat_view/flutter_chat_view.dart";
import "package:flutter_profile/flutter_profile.dart";

class ChatProfileScreen extends StatefulWidget {
  const ChatProfileScreen({
    required this.chatService,
    required this.chatId,
    required this.translations,
    required this.onTapUser,
    required this.options,
    required this.onPressStartChat,
    required this.currentUserId,
    this.userId,
    super.key,
  });

  /// Translations for the chat.
  final ChatTranslations translations;

  /// Chat service instance.
  final ChatService chatService;

  /// ID of the chat.
  final String chatId;

  /// ID of the user (optional).
  final String? userId;

  /// Callback function for tapping on a user.
  final Function(ChatUserModel user) onTapUser;

  /// Chat options.
  final ChatOptions options;

  /// Callback function for starting a chat.
  final Function(ChatUserModel user) onPressStartChat;

  /// The current user.
  final String currentUserId;

  @override
  State<ChatProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ChatProfileScreen> {
  @override
  Widget build(BuildContext context) {
    var hasUser = widget.userId == null;
    var theme = Theme.of(context);
    return FutureBuilder<dynamic>(
      future: hasUser
          // ignore: discarded_futures
          ? widget.chatService.chatOverviewService.getChatById(widget.chatId)
          // ignore: discarded_futures
          : widget.chatService.chatUserService.getUser(widget.userId!),
      builder: (context, snapshot) {
        var data = snapshot.data;
        User? user;

        if (data is ChatUserModel) {
          user = User(
            firstName: data.firstName,
            lastName: data.lastName,
            imageUrl: data.imageUrl,
          );
        }
        if (data is PersonalChatModel) {
          user = User(
            firstName: data.user.firstName,
            lastName: data.user.lastName,
            imageUrl: data.user.imageUrl,
          );
        } else if (data is GroupChatModel) {
          user = User(
            firstName: data.title,
            imageUrl: data.imageUrl,
          );
        }

        return Scaffold(
          appBar: AppBar(
            iconTheme: theme.appBarTheme.iconTheme ??
                const IconThemeData(color: Colors.white),
            title: Text(
              (data is ChatUserModel)
                  ? '${data.firstName ?? ''} ${data.lastName ?? ''}'
                  : (data is PersonalChatModel)
                      ? data.user.fullName ?? ""
                      : (data is GroupChatModel)
                          ? data.title
                          : "",
              style: theme.textTheme.headlineLarge,
            ),
          ),
          body: snapshot.hasData
              ? Stack(
                  children: [
                    ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            children: [
                              widget.options.userAvatarBuilder(
                                ChatUserModel(
                                  firstName: user!.firstName,
                                  lastName: user.lastName,
                                  imageUrl: user.imageUrl,
                                ),
                                60,
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          color: Colors.white,
                          thickness: 10,
                        ),
                        if (data is GroupChatModel) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.translations.groupProfileBioHeader,
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  data.bio ?? "",
                                  style: theme.textTheme.bodyMedium!
                                      .copyWith(color: Colors.black),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  widget.translations.chatProfileUsers,
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Wrap(
                                  children: [
                                    ...data.users.map(
                                      (user) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                          right: 8,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            widget.onTapUser.call(user);
                                          },
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              widget.options.userAvatarBuilder(
                                                user,
                                                44,
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
                    if (data is ChatUserModel &&
                        widget.currentUserId != data.id) ...[
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 80,
                          ),
                          child: FilledButton(
                            onPressed: () {
                              widget.onPressStartChat(data);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.translations.newChatButton,
                                  style: theme.textTheme.displayLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
