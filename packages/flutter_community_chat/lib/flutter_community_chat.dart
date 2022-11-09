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

class CommunityChat extends StatefulWidget {
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

  @override
  State<CommunityChat> createState() => _CommunityChatState();
}

class _CommunityChatState extends State<CommunityChat> {
  bool _isFetchingUsers = false;

  Future<void> _push(BuildContext context, Widget widget) =>
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => widget),
      );

  Future<void> _onPressStartChat(BuildContext context) async {
    if (!_isFetchingUsers) {
      _isFetchingUsers = true;
      await widget.dataProvider.getChatUsers().then(
        (users) {
          _isFetchingUsers = false;
          _push(
            context,
            NewChatScreen(
              options: widget.options,
              translations: widget.translations,
              onPressCreateChat: (user) {
                _onPressChat(
                  context,
                  PersonalChatModel(user: user),
                );
              },
              users: users,
            ),
          );
        },
      );
    }
  }

  Future<void> _onPressChat(BuildContext context, ChatModel chat) async {
    widget.dataProvider.setChat(chat);
    _push(
      context,
      ChatDetailScreen(
        options: widget.options,
        translations: widget.translations,
        chat: chat,
        chatMessages: widget.dataProvider.getMessagesStream(),
        onPressSelectImage: (ChatModel chat) =>
            _onPressSelectImage(context, chat),
        onMessageSubmit: (ChatModel chat, String content) =>
            widget.dataProvider.sendTextMessage(content),
      ),
    );
  }

  void _beforeUploadingImage() => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(minutes: 1),
          content: Row(
            children: [
              const SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(color: Colors.grey),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(widget.translations.imageUploading),
              ),
            ],
          ),
        ),
      );

  _afterUploadingImage() => ScaffoldMessenger.of(context).hideCurrentSnackBar();

  Future<void> _onPressSelectImage(BuildContext context, ChatModel chat) =>
      showModalBottomSheet<Uint8List?>(
        context: context,
        builder: (BuildContext context) =>
            widget.options.imagePickerContainerBuilder(
          ImagePicker(
            customButton: widget.options.closeImagePickerButtonBuilder(
              context,
              () => Navigator.of(context).pop(),
              widget.translations,
            ),
            imagePickerTheme: widget.imagePickerTheme,
            imagePickerConfig: widget.imagePickerConfig,
          ),
        ),
      ).then(
        (image) async {
          _beforeUploadingImage();

          if (image != null) {
            await widget.dataProvider.sendImageMessage(image);
          }

          _afterUploadingImage();
        },
      );

  @override
  Widget build(BuildContext context) => ChatScreen(
        chats: widget.dataProvider.getChatsStream(),
        onPressStartChat: () => _onPressStartChat(context),
        onPressChat: (chat) => _onPressChat(context, chat),
        options: widget.options,
        translations: widget.translations,
      );
}
