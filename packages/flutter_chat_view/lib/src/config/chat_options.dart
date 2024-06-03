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
    this.noUsersPlaceholderBuilder = _createNoUsersPlaceholder,
    this.paddingAroundChatList,
  });

  /// Builder function for the new chat button.
  final ButtonBuilder newChatButtonBuilder;

  /// Builder function for the message input field.
  final TextInputBuilder messageInputBuilder;

  /// Builder function for the container wrapping each chat row.
  final ContainerBuilder chatRowContainerBuilder;

  /// Builder function for the container wrapping the image picker.
  final ImagePickerContainerBuilder imagePickerContainerBuilder;

  /// Builder function for the scaffold containing the chat view.
  final ScaffoldBuilder scaffoldBuilder;

  /// Builder function for the user avatar.
  final UserAvatarBuilder userAvatarBuilder;

  /// Builder function for the group avatar.
  final GroupAvatarBuilder groupAvatarBuilder;

  /// Builder function for the placeholder shown when no chats are available.
  final NoChatsPlaceholderBuilder noChatsPlaceholderBuilder;

  /// Builder function for the placeholder shown when no users are available.
  final NoUsersPlaceholderBuilder noUsersPlaceholderBuilder;

  /// The padding around the chat list.
  final EdgeInsets? paddingAroundChatList;
}

Widget _createNewChatButton(
  BuildContext context,
  VoidCallback onPressed,
  ChatTranslations translations,
) =>
    Padding(
      padding: const EdgeInsets.fromLTRB(5, 24, 5, 24),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          fixedSize: const Size(254, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(56),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          translations.newChatButton,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
    );

Widget _createMessageInput(
  TextEditingController textEditingController,
  Widget suffixIcon,
  ChatTranslations translations,
) =>
    TextField(
      textCapitalization: TextCapitalization.sentences,
      controller: textEditingController,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26.5),
          borderSide: const BorderSide(
            color: Colors.black,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26.5),
          borderSide: const BorderSide(
            color: Colors.black,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 30,
        ),
        hintText: translations.messagePlaceholder,
        hintStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
        fillColor: Colors.white,
        filled: true,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(26.5),
          ),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
      ),
    );

Widget _createChatRowContainer(
  Widget chatRow,
) =>
    Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: 10.0,
      ),
      child: chatRow,
    );

Widget _createImagePickerContainer(
  VoidCallback onClose,
  ChatTranslations translations,
  BuildContext context,
) =>
    Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: ImagePicker(
        imagePickerTheme: ImagePickerTheme(
          title: translations.imagePickerTitle,
          titleTextSize: 16,
          titleAlignment: TextAlign.center,
          iconSize: 60.0,
          makePhotoText: translations.takePicture,
          selectImageText: translations.uploadFile,
        ),
        customButton: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
          ),
          onPressed: onClose,
          child: Text(
            translations.cancelImagePickerBtn,
            style: const TextStyle(color: Colors.white),
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
        translations.noChatsFound,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );

Widget _createNoUsersPlaceholder(
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
  BuildContext context,
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

typedef NoUsersPlaceholderBuilder = Widget Function(
  ChatTranslations translations,
);
