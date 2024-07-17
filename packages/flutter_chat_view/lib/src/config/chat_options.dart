// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:flutter/material.dart";
import "package:flutter_chat_view/flutter_chat_view.dart";
import "package:flutter_image_picker/flutter_image_picker.dart";
import "package:flutter_profile/flutter_profile.dart";

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
) {
  var theme = Theme.of(context);
  return Padding(
    padding: const EdgeInsets.symmetric(
      vertical: 24,
      horizontal: 4,
    ),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        fixedSize: const Size(254, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(56),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        translations.newChatButton,
        style: theme.textTheme.displayLarge,
      ),
    ),
  );
}

Widget _createMessageInput(
  TextEditingController textEditingController,
  Widget suffixIcon,
  ChatTranslations translations,
  BuildContext context,
) {
  var theme = Theme.of(context);
  return TextField(
    style: theme.textTheme.bodySmall,
    textCapitalization: TextCapitalization.sentences,
    controller: textEditingController,
    decoration: InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(
          color: Colors.black,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(
          color: Colors.black,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 30,
      ),
      hintText: translations.messagePlaceholder,
      hintStyle: theme.textTheme.bodyMedium!.copyWith(
        color: theme.textTheme.bodyMedium!.color!.withOpacity(0.5),
      ),
      fillColor: Colors.white,
      filled: true,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffixIcon,
    ),
  );
}

Widget _createChatRowContainer(
  Widget chatRow,
  BuildContext context,
) {
  var theme = Theme.of(context);
  return DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.transparent,
      border: Border(
        bottom: BorderSide(
          color: theme.dividerColor,
          width: 0.5,
        ),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: chatRow,
    ),
  );
}

Widget _createImagePickerContainer(
  VoidCallback onClose,
  ChatTranslations translations,
  BuildContext context,
) {
  var theme = Theme.of(context);
  return Container(
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
        selectImageIcon: const Icon(
          Icons.insert_drive_file_rounded,
          size: 60,
        ),
      ),
      customButton: TextButton(
        onPressed: onClose,
        child: Text(
          translations.cancelImagePickerBtn,
          style: theme.textTheme.bodyMedium!.copyWith(
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ),
  );
}

Scaffold _createScaffold(
  AppBar appbar,
  Widget body,
  Color backgroundColor,
) =>
    Scaffold(
      appBar: appbar,
      body: body,
      backgroundColor: backgroundColor,
    );

Widget _createUserAvatar(
  ChatUserModel user,
  double size,
) =>
    Avatar(
      boxfit: BoxFit.cover,
      user: User(
        firstName: user.firstName,
        lastName: user.lastName,
        imageUrl: user.imageUrl != "" ? user.imageUrl : null,
      ),
      size: size,
    );

Widget _createGroupAvatar(
  String groupName,
  String? imageUrl,
  double size,
) =>
    Avatar(
      boxfit: BoxFit.cover,
      user: User(
        firstName: groupName,
        lastName: null,
        imageUrl: imageUrl != "" ? imageUrl : null,
      ),
      size: size,
    );

Widget _createNoChatsPlaceholder(
  ChatTranslations translations,
  BuildContext context,
) {
  var theme = Theme.of(context);
  return Center(
    child: Text(
      translations.noChatsFound,
      textAlign: TextAlign.center,
      style: theme.textTheme.bodySmall,
    ),
  );
}

Widget _createNoUsersPlaceholder(
  ChatTranslations translations,
  BuildContext context,
) {
  var theme = Theme.of(context);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Align(
      alignment: Alignment.topCenter,
      child: Text(
        translations.noUsersFound,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall,
      ),
    ),
  );
}

typedef ButtonBuilder = Widget Function(
  BuildContext context,
  VoidCallback onPressed,
  ChatTranslations translations,
);

typedef TextInputBuilder = Widget Function(
  TextEditingController textEditingController,
  Widget suffixIcon,
  ChatTranslations translations,
  BuildContext context,
);

typedef ContainerBuilder = Widget Function(
  Widget child,
  BuildContext context,
);

typedef ImagePickerContainerBuilder = Widget Function(
  VoidCallback onClose,
  ChatTranslations translations,
  BuildContext context,
);

typedef ScaffoldBuilder = Scaffold Function(
  AppBar appBar,
  Widget body,
  Color backgroundColor,
);

typedef UserAvatarBuilder = Widget Function(
  ChatUserModel user,
  double size,
);

typedef GroupAvatarBuilder = Widget Function(
  String groupName,
  String? imageUrl,
  double size,
);

typedef NoChatsPlaceholderBuilder = Widget Function(
  ChatTranslations translations,
  BuildContext context,
);

typedef NoUsersPlaceholderBuilder = Widget Function(
  ChatTranslations translations,
  BuildContext context,
);
