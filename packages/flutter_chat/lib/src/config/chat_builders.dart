import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_chat/src/config/chat_translations.dart";

/// The chat builders
class ChatBuilders {
  /// The chat builders constructor
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

  /// The chat screen scaffold builder
  final ScaffoldBuilder? chatScreenScaffoldBuilder;

  /// The new chat screen scaffold builder
  final ScaffoldBuilder? newChatScreenScaffoldBuilder;

  /// The new group chat overview scaffold builder
  final ScaffoldBuilder? newGroupChatOverviewScaffoldBuilder;

  /// The new group chat screen scaffold builder
  final ScaffoldBuilder? newGroupChatScreenScaffoldBuilder;

  /// The chat detail scaffold builder
  final ScaffoldBuilder? chatDetailScaffoldBuilder;

  /// The chat profile scaffold builder
  final ScaffoldBuilder? chatProfileScaffoldBuilder;

  /// The message input builder
  final TextInputBuilder? messageInputBuilder;

  /// The chat row container builder
  final ContainerBuilder? chatRowContainerBuilder;

  /// The group avatar builder
  final GroupAvatarBuilder? groupAvatarBuilder;

  /// The user avatar builder
  final UserAvatarBuilder? userAvatarBuilder;

  /// The delete chat dialog builder
  final Future<bool?> Function(BuildContext, ChatModel)?
      deleteChatDialogBuilder;

  /// The new chat button builder
  final ButtonBuilder? newChatButtonBuilder;

  /// The no users placeholder builder
  final NoUsersPlaceholderBuilder? noUsersPlaceholderBuilder;

  /// The chat title builder
  final Widget Function(String chatTitle)? chatTitleBuilder;

  /// The username builder
  final Widget Function(String userFullName)? usernameBuilder;

  /// The image picker container builder
  final ImagePickerContainerBuilder? imagePickerContainerBuilder;

  /// The loading widget builder
  final Widget? Function(BuildContext context)? loadingWidgetBuilder;
}

/// The button builder
typedef ButtonBuilder = Widget Function(
  BuildContext context,
  VoidCallback onPressed,
  ChatTranslations translations,
);

/// The image picker container builder
typedef ImagePickerContainerBuilder = Widget Function(
  BuildContext context,
  VoidCallback onClose,
  ChatTranslations translations,
);

/// The text input builder
typedef TextInputBuilder = Widget Function(
  BuildContext context,
  TextEditingController textEditingController,
  Widget suffixIcon,
  ChatTranslations translations,
);

/// The scaffold builder
typedef ScaffoldBuilder = Scaffold Function(
  BuildContext context,
  PreferredSizeWidget appBar,
  Widget body,
  Color backgroundColor,
);

/// The container builder
typedef ContainerBuilder = Widget Function(
  BuildContext context,
  Widget child,
);

/// The group avatar builder
typedef GroupAvatarBuilder = Widget Function(
  BuildContext context,
  String groupName,
  String? imageUrl,
  double size,
);

/// The user avatar builder
typedef UserAvatarBuilder = Widget Function(
  BuildContext context,
  UserModel user,
  double size,
);

/// The no users placeholder builder
typedef NoUsersPlaceholderBuilder = Widget Function(
  BuildContext context,
  ChatTranslations translations,
);
