// ignore_for_file: discarded_futures

import 'package:flutter/material.dart';
import 'package:flutter_chat_view/flutter_chat_view.dart';
import 'package:flutter_chat_view/src/services/profile_service.dart';
import 'package:flutter_profile/flutter_profile.dart';

class ChatProfileScreen extends StatefulWidget {
  const ChatProfileScreen({
    required this.chatService,
    required this.chatId,
    required this.translations,
    required this.onTapUser,
    this.userId,
    super.key,
  });

  final ChatTranslations translations;
  final ChatService chatService;
  final String chatId;
  final String? userId;
  final Function(String userId) onTapUser;

  @override
  State<ChatProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ChatProfileScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var hasUser = widget.userId == null;
    return FutureBuilder<dynamic>(
      future: hasUser
          ? widget.chatService.chatOverviewService.getChatById(widget.chatId)
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
            title: Text(
              (data is ChatUserModel)
                  ? '${data.firstName ?? ''} ${data.lastName ?? ''}'
                  : (data is PersonalChatModel)
                      ? data.user.fullName ?? ''
                      : (data is GroupChatModel)
                          ? data.title
                          : '',
            ),
          ),
          body: snapshot.hasData
              ? ListView(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 200,
                      width: size.width,
                      child: ProfilePage(
                        user: user!,
                        itemBuilderOptions: ItemBuilderOptions(
                          readOnly: true,
                        ),
                        service: ChatProfileService(),
                      ),
                    ),
                    if (data is GroupChatModel) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 100),
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
                          firstName: e.firstName ?? '',
                          lastName: e.lastName ?? '',
                          imageUrl: e.imageUrl,
                        );
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: GestureDetector(
                            onTap: () => widget.onTapUser.call(e.id!),
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
