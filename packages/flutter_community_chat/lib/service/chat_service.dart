import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_community_chat/ui/components/image_loading_snackbar.dart';
import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';
import 'package:flutter_community_chat_view/flutter_community_chat_view.dart';
import 'package:flutter_image_picker/flutter_image_picker.dart';

abstract class ChatService {
  ChatService({
    required this.options,
    required this.imagePickerConfig,
    required this.dataProvider,
  });

  final CommunityChatInterface dataProvider;
  final ChatOptions options;
  final ImagePickerConfig imagePickerConfig;
  bool _isFetchingUsers = false;

  ImagePickerTheme imagePickerTheme(BuildContext context) =>
      const ImagePickerTheme();

  ChatTranslations translations(BuildContext context);

  Future<void> _push(BuildContext context, Widget widget) =>
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => widget),
      );

  void _pop(BuildContext context) => Navigator.of(context).pop();

  Future<void> onPressStartChat(BuildContext context) async {
    if (!_isFetchingUsers) {
      _isFetchingUsers = true;
      await dataProvider.getChatUsers().then(
        (users) {
          _isFetchingUsers = false;
          _push(
            context,
            buildNewChatScreen(context, users),
          );
        },
      );
    }
  }

  Widget buildNewChatScreen(
    BuildContext context,
    List<ChatUserModel> users,
  ) =>
      NewChatScreen(
        options: options,
        translations: translations(context),
        onPressCreateChat: (user) => onPressChat(
          context,
          PersonalChatModel(user: user),
          popBeforePush: true,
        ),
        users: users,
      );

  Future<void> onPressChat(
    BuildContext context,
    ChatModel chat, {
    bool popBeforePush = false,
  }) =>
      dataProvider.setChat(chat).then((_) {
        if (popBeforePush) {
          _pop(context);
        }
        _push(
          context,
          buildChatDetailScreen(context, chat),
        );
      });

  Widget buildChatDetailScreen(
    BuildContext context,
    ChatModel chat,
  ) =>
      ChatDetailScreen(
        options: options,
        translations: translations(context),
        chat: chat,
        chatMessages: dataProvider.getMessagesStream(),
        onPressSelectImage: (ChatModel chat) => onPressSelectImage(
          context,
          chat,
        ),
        onMessageSubmit: (ChatModel chat, String content) =>
            dataProvider.sendTextMessage(content),
      );

  Future<void> onPressSelectImage(
    BuildContext context,
    ChatModel chat,
  ) =>
      showModalBottomSheet<Uint8List?>(
        context: context,
        builder: (BuildContext context) => options.imagePickerContainerBuilder(
          ImagePicker(
            customButton: options.closeImagePickerButtonBuilder(
              context,
              () => Navigator.of(context).pop(),
              translations(context),
            ),
            imagePickerConfig: imagePickerConfig,
            imagePickerTheme: imagePickerTheme(context),
          ),
        ),
      ).then(
        (image) async {
          var messenger = ScaffoldMessenger.of(context);

          messenger.showSnackBar(
            getImageLoadingSnackbar(
              translations(context),
            ),
          );

          if (image != null) {
            await dataProvider.sendImageMessage(image);
          }

          messenger.hideCurrentSnackBar();
        },
      );

  Future<void> deleteChat(ChatModel chat) => dataProvider.deleteChat(chat);
}
