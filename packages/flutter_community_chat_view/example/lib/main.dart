// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_community_chat_view/flutter_community_chat_view.dart';

void main() {
  runApp(const MaterialApp(home: MyStatefulWidget()));
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  static final messages = [
    ChatTextMessageModel(
      sender: ChatUserModel(
        firstName: 'Piet',
        lastName: 'Jansen',
        imageUrl: 'https://xsgames.co/randomusers/avatar.php?g=female',
      ),
      text: 'Hoe gaat het?',
      timestamp: DateTime.now(),
    ),
    ChatTextMessageModel(
      sender: ChatUserModel(
        firstName: 'Jan',
        lastName: 'Jansen',
        imageUrl: 'https://xsgames.co/randomusers/avatar.php?g=male',
      ),
      text: 'Met mij gaat het goed, dankje!',
      timestamp: DateTime.now(),
    )
  ];

  static final chat = PersonalChatModel(
    user: ChatUserModel(
      firstName: 'Sjoerd',
      lastName: 'Sjagerars',
      imageUrl:  'https://xsgames.co/randomusers/avatar.php?g=female',
    ),
    messages: messages,
  );

  Stream<List<PersonalChatModel>> get chatStream => (() {
        late StreamController<List<PersonalChatModel>> controller;
        controller = StreamController<List<PersonalChatModel>>(
          onListen: () {
            controller.add([
              chat,
              chat,
              chat,
            ]);
          },
        );
        return controller.stream;
      })();

  Stream<List<ChatTextMessageModel>> get messageStream => (() {
        late StreamController<List<ChatTextMessageModel>> controller;
        controller = StreamController<List<ChatTextMessageModel>>(
          onListen: () {
            controller.add(
              messages,
            );

            Future.delayed(
              const Duration(seconds: 5),
              () => controller.add(
                [
                  ...messages,
                  ...messages,
                ],
              ),
            );
          },
        );
        return controller.stream;
      })();

  @override
  Widget build(BuildContext context) {
    var options = const ChatOptions();
    return ChatScreen(
      chats: chatStream,
      options: options,
      onPressChat: (chat) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatDetailScreen(
            chat: chat,
            chatMessages: messageStream,
            options: options,
            onMessageSubmit: (text) async {
              return Future.delayed(
                const Duration(
                  milliseconds: 500,
                ),
                () => debugPrint('onMessageSubmit'),
              );
            },
            onUploadImage: (image) async {},
          ),
        ),
      ),
      onDeleteChat: (chat) => Future.delayed(
        const Duration(
          milliseconds: 500,
        ),
        () => debugPrint('onDeleteChat'),
      ),
      onPressStartChat: () => debugPrint('onPressStartChat'),
    );
  }
}
