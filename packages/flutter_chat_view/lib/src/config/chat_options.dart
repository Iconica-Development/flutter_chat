// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_chat_view/flutter_chat_view.dart';
import 'package:flutter_chat_view/src/components/chat_image.dart';
import 'package:flutter_image_picker/flutter_image_picker.dart';
import 'package:flutter_profile/flutter_profile.dart';

class ChatOptions {
  const ChatOptions({
    this.newChatButtonBuilder = _createNewChatButton,
    this.messageInputBuilder = _createMessageInput,
    this.chatRowContainerBuilder = _createChatRowContainer,
    this.imagePickerContainerBuilder = _createImagePickerContainer,
    this.scaffoldBuilder = _createScaffold,
    this.userAvatarBuilder = _createUserAvatar,
    this.groupAvatarBuilder = _createGroupAvatar,
    this.noChatsPlaceholderBuilder = _createNoChatsPlaceholder,
  });

  final ButtonBuilder newChatButtonBuilder;
  final TextInputBuilder messageInputBuilder;
  final ContainerBuilder chatRowContainerBuilder;
  final ImagePickerContainerBuilder imagePickerContainerBuilder;
  final ScaffoldBuilder scaffoldBuilder;
  final UserAvatarBuilder userAvatarBuilder;
  final GroupAvatarBuilder groupAvatarBuilder;
  final NoChatsPlaceholderBuilder noChatsPlaceholderBuilder;
}

Widget _createNewChatButton(
  BuildContext context,
  VoidCallback onPressed,
  ChatTranslations translations,
) =>
    Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
        ),
        onPressed: onPressed,
        child: Text(translations.newChatButton),
      ),
    );

Widget _createMessageInput(
  TextEditingController textEditingController,
  Widget suffixIcon,
  ChatTranslations translations,
) =>
    TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: translations.messagePlaceholder,
       
        suffixIcon: suffixIcon,
      ),
    );

Widget _createChatRowContainer(
  Widget chatRow,
) =>
    Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 15.0,
        horizontal: 10.0,
      ),
      child: chatRow,
    );

Widget _createImagePickerContainer(
  VoidCallback onClose,
  ChatTranslations translations,
) =>
    Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: ImagePicker(
        customButton: ElevatedButton(
          onPressed: onClose,
          child: Text(
            translations.cancelImagePickerBtn,
          ),
        ),
      ),
    );

Scaffold _createScaffold(
  AppBar appbar,
  Widget body,
) =>
    Scaffold(
      appBar: appbar,
      body: body,
    );

Widget _createUserAvatar(
  ChatUserModel user,
  double size,
) =>
    Avatar(
      user: User(
        firstName: user.firstName,
        lastName: user.lastName,
        imageUrl: user.imageUrl,
      ),
      size: size,
    );
Widget _createGroupAvatar(
  String groupName,
  String imageUrl,
  double size,
) =>
    ChatImage(
      image: imageUrl,
      size: size,
    );

Widget _createNoChatsPlaceholder(
  ChatTranslations translations,
) =>
    Center(
      child: Text(
        translations.noUsersFound,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );

typedef ButtonBuilder = Widget Function(
  BuildContext context,
  VoidCallback onPressed,
  ChatTranslations translations,
);

typedef TextInputBuilder = Widget Function(
  TextEditingController textEditingController,
  Widget suffixIcon,
  ChatTranslations translations,
);

typedef ContainerBuilder = Widget Function(
  Widget child,
);

typedef ImagePickerContainerBuilder = Widget Function(
  VoidCallback onClose,
  ChatTranslations translations,
);

typedef ScaffoldBuilder = Scaffold Function(
  AppBar appBar,
  Widget body,
);

typedef UserAvatarBuilder = Widget Function(
  ChatUserModel user,
  double size,
);

typedef GroupAvatarBuilder = Widget Function(
  String groupName,
  String imageUrl,
  double size,
);

typedef NoChatsPlaceholderBuilder = Widget Function(
  ChatTranslations translations,
);
