import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_chat/src/config/chat_translations.dart";
import "package:flutter_chat/src/config/screen_types.dart";

/// The chat builders
class ChatBuilders {
  /// The chat builders constructor
  const ChatBuilders({
    this.baseScreenBuilder,
    this.messageInputBuilder,
    this.chatRowContainerBuilder,
    this.groupAvatarBuilder,
    this.imagePickerContainerBuilder,
    this.userAvatarBuilder,
    this.deleteChatDialogBuilder,
    this.newChatButtonBuilder,
    this.noUsersPlaceholderBuilder,
    this.chatTitleBuilder,
    this.chatMessageBuilder,
    this.usernameBuilder,
    this.loadingWidgetBuilder,
  });

  /// The base screen builder
  /// This builder is used to build the base screen for the chat
  /// You can switch on the [screenType] to build different screens
  /// ```dart
  ///   baseScreenBuilder: (context, screenType, appBar, body) {
  ///     switch (screenType) {
  ///       case ScreenType.chatScreen:
  ///         return Scaffold(
  ///           appBar: appBar,
  ///           body: body,
  ///         );
  ///       case ScreenType.chatDetailScreen:
  ///       // And so on....
  /// ```
  final BaseScreenBuilder? baseScreenBuilder;

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

  /// The chat message builder
  final ChatMessageBuilder? chatMessageBuilder;

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

/// The base screen builder
typedef BaseScreenBuilder = Widget Function(
  BuildContext context,
  ScreenType screenType,
  PreferredSizeWidget appBar,
  Widget body,
);

/// The container builder
typedef ContainerBuilder = Widget Function(
  BuildContext context,
  Widget child,
);

/// The chat message builder
/// This builder is used to override the default chat message widget
/// If null is returned, the default chat message widget will be used so you can
/// override for specific cases
/// [previousMessage] is the previous message in the chat
typedef ChatMessageBuilder = Widget? Function(
  BuildContext context,
  MessageModel message,
  MessageModel? previousMessage,
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
