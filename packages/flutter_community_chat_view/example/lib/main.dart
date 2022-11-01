// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_community_chat_view/flutter_community_chat.dart';

// void main() {
//   runApp(const MaterialApp(home: MyStatefulWidget()));
// }

// class MyStatefulWidget extends StatefulWidget {
//   const MyStatefulWidget({super.key});

//   @override
//   State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
// }

// class _MyStatefulWidgetState extends State<MyStatefulWidget> {
//   static final messages = [
//     ChatTextMessage(
//       sender: const ChatUser(
//         name: 'Piet Jansen',
//         image: 'https://xsgames.co/randomusers/avatar.php?g=female',
//       ),
//       text: 'Hoe gaat het?',
//       timestamp: DateTime.now(),
//     ),
//     ChatTextMessage(
//       sender: const ChatUser(
//         name: 'Jan Jansen',
//         image: 'https://xsgames.co/randomusers/avatar.php?g=male',
//       ),
//       text: 'Met mij gaat het goed, dankje!',
//       timestamp: DateTime.now(),
//     )
//   ];

//   static final chat = Chat(
//     title: 'Sjoerd Sjagerars',
//     image: 'https://xsgames.co/randomusers/avatar.php?g=female',
//     messages: messages,
//   );

//   Stream<List<Chat>> get chatStream => (() {
//         late StreamController<List<Chat>> controller;
//         controller = StreamController<List<Chat>>(
//           onListen: () {
//             controller.add([
//               chat,
//               chat,
//               chat,
//             ]);
//           },
//         );
//         return controller.stream;
//       })();

//   Stream<List<ChatMessage>> get messageStream => (() {
//         late StreamController<List<ChatMessage>> controller;
//         controller = StreamController<List<ChatMessage>>(
//           onListen: () {
//             controller.add(
//               messages,
//             );

//             Future.delayed(
//               const Duration(seconds: 5),
//               () => controller.add(
//                 [
//                   ...messages,
//                   ...messages,
//                 ],
//               ),
//             );
//           },
//         );
//         return controller.stream;
//       })();

//   @override
//   Widget build(BuildContext context) => ChatScreen(
//         chats: chatStream,
//         chatOptions: ChatOptions(
//           pressChatHandler: (context, chatOptions, chat) =>
//               Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) => ChatDetailScreen(
//                 chatOptions: chatOptions,
//                 chat: chat,
//                 chatMessages: messageStream,
//               ),
//             ),
//           ),
//           messageHandler: (chat, text) => Future.delayed(
//             const Duration(
//               milliseconds: 500,
//             ),
//             () => debugPrint('messageHandler with message: $text'),
//           ),
//           onPressSelectImage: (ChatModel chat) => Future.delayed(
//             const Duration(
//               milliseconds: 500,
//             ),
//             () => debugPrint('onPressSelectImage'),
//           ),
//           onPressStartChat: () => debugPrint('onPressStartChat'),
//         ),
//       );
// }
