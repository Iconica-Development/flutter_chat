// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

library flutter_community_chat;

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';
import 'package:flutter_community_chat_view/flutter_community_chat_view.dart';
import 'package:flutter_image_picker/flutter_image_picker.dart';
export 'package:flutter_community_chat_view/flutter_community_chat_view.dart';

class CommunityChat extends StatelessWidget {
  const CommunityChat({
    required this.dataProvider,
    this.options = const ChatOptions(),
    this.translations = const ChatTranslations(),
    this.imagePickerTheme = const ImagePickerTheme(),
    this.imagePickerConfig = const ImagePickerConfig(),
    super.key,
  });

  final CommunityChatInterface dataProvider;
  final ChatOptions options;
  final ChatTranslations translations;
  final ImagePickerTheme imagePickerTheme;
  final ImagePickerConfig imagePickerConfig;

  Future<void> _push(BuildContext context, Widget widget) =>
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => widget),
      );

  Future<void> _onPressStartChat(BuildContext context) =>
      dataProvider.getChatUsers().then((users) => _push(
            context,
            NewChatScreen(
              options: options,
              translations: translations,
              onPressCreateChat: (user) {
                _onPressChat(
                  context,
                  PersonalChatModel(user: user),
                );
              },
              users: users,
            ),
          ));

  Future<void> _onPressChat(BuildContext context, ChatModel chat) async {
    dataProvider.setChat(chat);
    _push(
      context,
      ChatDetailScreen(
        options: options,
        translations: translations,
        chat: chat,
        chatMessages: dataProvider.getMessagesStream(),
        onPressSelectImage: (ChatModel chat) =>
            _onPressSelectImage(context, chat),
        onMessageSubmit: (ChatModel chat, String content) =>
            dataProvider.sendTextMessage(content),
      ),
    );
  }

  Future<void> _onPressSelectImage(BuildContext context, ChatModel chat) =>
      showModalBottomSheet<Uint8List?>(
        context: context,
        builder: (BuildContext context) => options.imagePickerContainerBuilder(
          ImagePicker(
            customButton: options.closeImagePickerButtonBuilder(
              context,
              () => Navigator.of(context).pop(),
              translations,
            ),
            imagePickerTheme: imagePickerTheme,
            imagePickerConfig: imagePickerConfig,
          ),
        ),
      ).then(
        (image) {
          if (image != null) {
            return dataProvider.sendImageMessage(image);
          }
        },
      );

  @override
  Widget build(BuildContext context) => ChatScreen(
        chats: dataProvider.getChatsStream(),
        onPressStartChat: () => _onPressStartChat(context),
        onPressChat: (chat) => _onPressChat(context, chat),
        options: options,
        translations: translations,
      );
}
