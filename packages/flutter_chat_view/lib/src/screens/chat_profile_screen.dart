import "package:flutter/material.dart";
import "package:flutter_chat_view/flutter_chat_view.dart";
import "package:flutter_profile/flutter_profile.dart";

class ChatProfileScreen extends StatefulWidget {
  const ChatProfileScreen({
    required this.chatService,
    required this.chatId,
    required this.translations,
    required this.onTapUser,
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
            backgroundColor: theme.appBarTheme.backgroundColor,
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
              style: theme.appBarTheme.titleTextStyle,
            ),
          ),
          body: snapshot.hasData
              ? ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Avatar(
                        user: user,
                      ),
                    ),
                    const Divider(
                      color: Colors.white,
                      thickness: 10,
                    ),
                    if (data is GroupChatModel) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 100,
                          vertical: 20,
                        ),
                        child: Text(
                          widget.translations.chatProfileUsers,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...data.users.map((e) {
                        var user = User(
                          firstName: e.firstName ?? "",
                          lastName: e.lastName ?? "",
                          imageUrl: e.imageUrl,
                        );
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: GestureDetector(
                            onTap: () {
                              widget.onTapUser.call(e);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Avatar(
                                  user: user,
                                ),
                                Text(
                                  user.firstName!,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
