import 'package:chat_repository_interface/chat_repository_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/src/config/chat_translations.dart';

class ChatBuilders {
  const ChatBuilders({
    this.chatScreenScaffoldBuilder,
    this.newChatScreenScaffoldBuilder,
    this.newGroupChatScreenScaffoldBuilder,
    this.newGroupChatOverviewScaffoldBuilder,
    this.chatProfileScaffoldBuilder,
    this.messageInputBuilder,
    this.chatDetailScaffoldBuilder,
    this.chatRowContainerBuilder,
    this.groupAvatarBuilder,
    this.imagePickerContainerBuilder,
    this.userAvatarBuilder,
    this.deleteChatDialogBuilder,
    this.newChatButtonBuilder,
    this.noUsersPlaceholderBuilder,
    this.chatTitleBuilder,
    this.usernameBuilder,
    this.loadingWidgetBuilder,
  });

  final ScaffoldBuilder? chatScreenScaffoldBuilder;
  final ScaffoldBuilder? newChatScreenScaffoldBuilder;
  final ScaffoldBuilder? newGroupChatOverviewScaffoldBuilder;
  final ScaffoldBuilder? newGroupChatScreenScaffoldBuilder;
  final ScaffoldBuilder? chatDetailScaffoldBuilder;
  final ScaffoldBuilder? chatProfileScaffoldBuilder;

  final TextInputBuilder? messageInputBuilder;

  final ContainerBuilder? chatRowContainerBuilder;

  final GroupAvatarBuilder? groupAvatarBuilder;

  final UserAvatarBuilder? userAvatarBuilder;

  final Future<bool?> Function(BuildContext, ChatModel)?
      deleteChatDialogBuilder;

  final ButtonBuilder? newChatButtonBuilder;

  final NoUsersPlaceholderBuilder? noUsersPlaceholderBuilder;

  final Widget Function(String chatTitle)? chatTitleBuilder;

  final Widget Function(String userFullName)? usernameBuilder;

  final ImagePickerContainerBuilder? imagePickerContainerBuilder;

  final Widget? Function(BuildContext context)? loadingWidgetBuilder;
}

typedef ButtonBuilder = Widget Function(
  BuildContext context,
  VoidCallback onPressed,
  ChatTranslations translations,
);

typedef ImagePickerContainerBuilder = Widget Function(
  VoidCallback onClose,
  ChatTranslations translations,
  BuildContext context,
);

typedef TextInputBuilder = Widget Function(
  TextEditingController textEditingController,
  Widget suffixIcon,
  ChatTranslations translations,
);

typedef ScaffoldBuilder = Scaffold Function(
  AppBar appBar,
  Widget body,
  Color backgroundColor,
);

typedef ContainerBuilder = Widget Function(
  Widget child,
);

typedef GroupAvatarBuilder = Widget Function(
  String groupName,
  String? imageUrl,
  double size,
);

typedef UserAvatarBuilder = Widget Function(
  UserModel user,
  double size,
);

typedef NoUsersPlaceholderBuilder = Widget Function(
  ChatTranslations translations,
);
