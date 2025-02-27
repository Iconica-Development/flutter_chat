import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_chat/flutter_chat.dart";
import "package:flutter_chat/src/screens/chat_detail/widgets/default_loader.dart";
import "package:flutter_chat/src/screens/creation/widgets/default_image_picker.dart";

/// The chat builders
class ChatBuilders {
  /// The chat builders constructor
  const ChatBuilders({
    this.chatMessagesErrorBuilder,
    this.baseScreenBuilder,
    this.chatScreenBuilder,
    this.messageInputBuilder,
    this.chatRowContainerBuilder,
    this.groupAvatarBuilder,
    this.imagePickerContainerBuilder,
    this.userAvatarBuilder,
    this.deleteChatDialogBuilder,
    this.newChatButtonBuilder,
    this.noUsersPlaceholderBuilder,
    this.chatTitleBuilder,
    this.chatMessageBuilder = DefaultChatMessageBuilder.builder,
    this.imagePickerBuilder = DefaultImagePickerDialog.builder,
    this.usernameBuilder,
    this.loadingWidgetBuilder = DefaultChatLoadingOverlay.builder,
    this.loadingChatMessageBuilder = DefaultChatMessageLoader.builder,
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

  /// The chat screen builder
  /// This builder is used instead of the [baseScreenBuilder] when building the
  /// chat screen. While the chat is still loading the [chat] will be null
  final ChatScreenBuilder? chatScreenBuilder;

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
  final ChatMessageBuilder chatMessageBuilder;

  /// The username builder
  final Widget Function(String userFullName)? usernameBuilder;

  /// The image picker container builder
  final ImagePickerContainerBuilder? imagePickerContainerBuilder;

  /// A way to provide your own image picker implementation
  /// If not provided the [DefaultImagePicker.builder] will be used which
  /// shows a modal buttom sheet with the option for a camera or gallery image
  final ImagePickerBuilder imagePickerBuilder;

  /// The loading widget builder
  /// This is used to build the loading widget that is displayed on the chat
  /// screen when loading the chat
  final WidgetBuilder loadingWidgetBuilder;

  /// The loading widget builder for chat messages
  /// This is displayed in the list of chat messages when loading more messages
  /// can be above and below the list
  final WidgetBuilder loadingChatMessageBuilder;

  /// Errorbuilder for when messages are not loading correctly on the detail
  /// screen of a chat.
  final ChatErrorBuilder? chatMessagesErrorBuilder;
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

/// Builder definition for providing an image picker implementation
typedef ImagePickerBuilder = Future<Uint8List?> Function(
  BuildContext context,
);

/// The text input builder
typedef TextInputBuilder = Widget Function(
  BuildContext context, {
  required TextEditingController textEditingController,
  required Widget suffixIcon,
  required ChatTranslations translations,
  required VoidCallback onSubmit,
  required bool enabled,
});

/// The base screen builder
/// [title] is the title of the screen and can be null while loading
typedef BaseScreenBuilder = Widget Function(
  BuildContext context,
  ScreenType screenType,
  PreferredSizeWidget appBar,
  String? title,
  Widget body,
);

/// The chat screen builder
typedef ChatScreenBuilder = Widget Function(
  BuildContext context,
  ChatModel? chat,
  PreferredSizeWidget appBar,
  String? title,
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
/// [sender] is the sender of the message and null if no user sent the message
typedef ChatMessageBuilder = Widget? Function(
  BuildContext context,
  MessageModel message,
  MessageModel? previousMessage,
  UserModel? sender,
  Function(UserModel sender) onPressSender,
  String semanticIdTitle,
  String semanticIdText,
  String semanticIdTime,
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

/// Builder for when there is an error on a chatscreen
typedef ChatErrorBuilder = Widget Function(
  BuildContext context,
  Object error,
  StackTrace stackTrace,
  ChatOptions options,
);
