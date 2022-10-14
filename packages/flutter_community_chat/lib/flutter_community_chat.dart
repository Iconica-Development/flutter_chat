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
    this.chatOptions = const ChatOptions(),
    this.imagePickerTheme = const ImagePickerTheme(),
    super.key,
  });

  final CommunityChatInterface dataProvider;
  final ChatOptions chatOptions;
  final ImagePickerTheme imagePickerTheme;

  Future<void> _push(BuildContext context, Widget widget) =>
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => widget),
      );

  Future<void> _onPressStartChat(BuildContext context) =>
      dataProvider.getChatUsers().then((users) => _push(
            context,
            NewChatScreen(
              chatOptions: chatOptions,
              onPressCreateChat: (user) => dataProvider.createChat(
                PersonalChatModel(user: user),
              ),
              users: users,
            ),
          ));

  Future<void> _onPressChat(BuildContext context, ChatModel chat) => _push(
        context,
        ChatDetailScreen(
          chatOptions: chatOptions,
          chat: chat,
          chatMessages: dataProvider.getMessagesStream(chat),
          onPressSelectImage: (ChatModel chat) =>
              _onPressSelectImage(context, chat),
          onMessageSubmit: (ChatModel chat, String content) =>
              dataProvider.sendTextMessage(chat, content),
        ),
      );

  Future<void> _onPressSelectImage(BuildContext context, ChatModel chat) =>
      showModalBottomSheet<Uint8List?>(
        context: context,
        builder: (BuildContext context) =>
            chatOptions.imagePickerContainerBuilder(
          ImagePicker(
            customButton: chatOptions.closeImagePickerButtonBuilder(
              context,
              () => Navigator.of(context).pop(),
            ),
            imagePickerTheme: imagePickerTheme,
          ),
        ),
      ).then(
        (image) {
          if (image != null) {
            return dataProvider.sendImageMessage(chat, image);
          }
        },
      );

  @override
  Widget build(BuildContext context) => ChatScreen(
        chats: dataProvider.getChatsStream(),
        onPressStartChat: () => _onPressStartChat(context),
        onPressChat: (chat) => _onPressChat(context, chat),
        chatOptions: chatOptions,
      );
}
