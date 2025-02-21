import "package:cached_network_image/cached_network_image.dart";
import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_chat/src/config/chat_builders.dart";
import "package:flutter_chat/src/config/chat_translations.dart";

/// The chat options
/// Use this class to configure the chat options.
class ChatOptions {
  /// The chat options constructor
  ChatOptions({
    this.dateformat,
    this.groupChatEnabled = true,
    this.enableLoadingIndicator = true,
    this.translations = const ChatTranslations.empty(),
    this.builders = const ChatBuilders(),
    this.spacing = const ChatSpacing(),
    this.paginationControls = const ChatPaginationControls(),
    this.messageTheme,
    this.messageThemeResolver = _defaultMessageThemeResolver,
    this.chatTitleResolver,
    this.senderTitleResolver,
    this.iconEnabledColor,
    this.iconDisabledColor,
    this.chatAlignment,
    this.onNoChats,
    this.imageProviderResolver = _defaultImageProviderResolver,
    ChatRepositoryInterface? chatRepository,
    UserRepositoryInterface? userRepository,
  })  : chatRepository = chatRepository ?? LocalChatRepository(),
        userRepository = userRepository ?? LocalUserRepository();

  /// The implementation for communication with persistance layer for chats
  final ChatRepositoryInterface chatRepository;

  /// The implementation for communication with persistance layer for users
  final UserRepositoryInterface userRepository;

  /// [dateformat] is a function that formats the date.
  // ignore: avoid_positional_boolean_parameters
  final String Function(bool showFullDate, DateTime date)? dateformat;

  /// [translations] is the chat translations.
  final ChatTranslations translations;

  /// [builders] is the chat builders.
  final ChatBuilders builders;

  //// The spacing between elements of the chat
  final ChatSpacing spacing;

  /// The pagination settings for the chat
  final ChatPaginationControls paginationControls;

  /// [groupChatEnabled] is a boolean that indicates if group chat is enabled.
  final bool groupChatEnabled;

  /// [iconEnabledColor] is the color of the enabled icon.
  /// Defaults to the [IconThemeData.color] of the current [Theme]
  final Color? iconEnabledColor;

  /// [iconDisabledColor] is the color of the disabled icon.
  /// Defaults to the [ThemeData.disabledColor] of the current [Theme]
  final Color? iconDisabledColor;

  /// The default [MessageTheme] for the chat messages.
  /// If not set, the default values are based on the current [Theme].
  final MessageTheme? messageTheme;

  /// If [messageThemeResolver] is set and returns null for a message,
  /// the [messageTheme] will be used.
  final MessageThemeResolver messageThemeResolver;

  /// If [chatTitleResolver] is set, it will be used to get the title of
  /// the chat in the ChatDetailScreen.
  final ChatTitleResolver? chatTitleResolver;

  /// If [senderTitleResolver] is set, it will be used to get the title of
  /// the sender in a chat message. If not set, the [sender.firstName] is used.
  /// [sender] can be null if the message is an event.
  final SenderTitleResolver? senderTitleResolver;

  /// The alignment of the chatmessages in the ChatDetailScreen.
  /// Defaults to [Alignment.bottomCenter]
  final Alignment? chatAlignment;

  /// Enable the loading indicator that is over the entire chat screen while
  /// loading messages. Defaults to false. The streambuilder for chat messages
  /// already shows a loading indicator. So this is an additional loading that
  /// can be used for more customization.
  final bool enableLoadingIndicator;

  /// [onNoChats] is a function that is triggered when there are no chats.
  final Function? onNoChats;

  /// If [imageProviderResolver] is set, it will be used to get the images for
  /// the images in the entire userstory. If not provided, CachedNetworkImage
  /// will be used.
  final ImageProviderResolver imageProviderResolver;
}

/// Typedef for the chatTitleResolver function that is used to get a title for
/// a chat.
typedef ChatTitleResolver = String? Function(ChatModel chat);

/// Typedef for the senderTitleResolver function that is used to get a title for
/// a sender.
typedef SenderTitleResolver = String? Function(UserModel? user);

/// Typedef for the imageProviderResolver function that is used to get images
/// for the userstory.
typedef ImageProviderResolver = ImageProvider Function(
  BuildContext context,
  Uri image,
);

/// Typedef for the messageThemeResolver function that is used to get a
/// [MessageTheme] for a message. This can return null so you can fall back to
/// default values for some messages.
typedef MessageThemeResolver = MessageTheme? Function(
  BuildContext context,
  MessageModel message,
  MessageModel? previousMessage,
  UserModel? sender,
);

/// The message theme
class MessageTheme {
  /// The message theme constructor
  const MessageTheme({
    this.backgroundColor,
    this.nameColor,
    this.borderColor,
    this.textColor,
    this.timeTextColor,
    this.borderRadius,
    this.messageAlignment,
    this.messageSidePadding,
    this.textAlignment,
    this.showName,
    this.showTime,
    this.showFullDate,
  });

  /// Creates a [MessageTheme] from a [ThemeData]
  factory MessageTheme.fromTheme(ThemeData theme) => MessageTheme(
        backgroundColor: theme.colorScheme.primary,
        nameColor: theme.colorScheme.onPrimary,
        borderColor: theme.colorScheme.primary,
        textColor: theme.colorScheme.onPrimary,
        timeTextColor: theme.colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(12),
        textAlignment: TextAlign.start,
        messageSidePadding: 144.0,
        messageAlignment: null,
        showName: null,
        showTime: true,
        showFullDate: null,
      );

  /// The alignment of the message in the chat
  /// By default, the current user is aligned to the right and the other senders
  /// are aligned to the left.
  final TextAlign? messageAlignment;

  /// The alignment of the text in the message
  /// Defaults to [TextAlign.start]
  final TextAlign? textAlignment;

  /// The color of the message text
  /// Defaults to [ThemeData.colorScheme.onPrimary]
  final Color? textColor;

  /// The color of the text displaying the time
  /// Defaults to [ThemeData.colorScheme.onPrimary]
  final Color? timeTextColor;

  /// The color of the sender name
  /// Defaults to [ThemeData.colorScheme.onPrimary]
  final Color? nameColor;

  /// The color of the message container background
  /// Defaults to [ThemeData.colorScheme.primary]
  final Color? backgroundColor;

  /// The color of the border around the message
  /// Defaults to [ThemeData.colorScheme.primaryColor]
  final Color? borderColor;

  /// The border radius of the message container
  /// Defaults to [BorderRadius.circular(12)]
  final BorderRadius? borderRadius;

  /// The padding on the side of the message
  /// If not set, the padding is 144.0
  final double? messageSidePadding;

  /// If the name of the sender should be shown above the message
  /// If not set the name will be shown if the previous message was not from the
  /// same sender.
  final bool? showName;

  /// If the time of the message should be shown below the message
  /// Defaults to true
  final bool? showTime;

  /// If the full date should be shown with the time in the message
  /// If not set the date will be shown if the previous message was not on the
  /// same day.
  /// If [showTime] is false, this value is ignored.
  final bool? showFullDate;

  /// Creates a copy of the current object with the provided values
  MessageTheme copyWith({
    Color? backgroundColor,
    Color? nameColor,
    Color? borderColor,
    Color? textColor,
    Color? timeTextColor,
    BorderRadius? borderRadius,
    double? messageSidePadding,
    TextAlign? messageAlignment,
    TextAlign? textAlignment,
    bool? showName,
    bool? showTime,
    bool? showFullDate,
  }) =>
      MessageTheme(
        backgroundColor: backgroundColor ?? this.backgroundColor,
        nameColor: nameColor ?? this.nameColor,
        borderColor: borderColor ?? this.borderColor,
        textColor: textColor ?? this.textColor,
        timeTextColor: timeTextColor ?? this.timeTextColor,
        borderRadius: borderRadius ?? this.borderRadius,
        messageSidePadding: messageSidePadding ?? this.messageSidePadding,
        messageAlignment: messageAlignment ?? this.messageAlignment,
        textAlignment: textAlignment ?? this.textAlignment,
        showName: showName ?? this.showName,
        showTime: showTime ?? this.showTime,
        showFullDate: showFullDate ?? this.showFullDate,
      );

  /// If a value is null in the first object, the value from the second object
  /// is used.
  MessageTheme operator |(MessageTheme other) => MessageTheme(
        backgroundColor: backgroundColor ?? other.backgroundColor,
        nameColor: nameColor ?? other.nameColor,
        borderColor: borderColor ?? other.borderColor,
        textColor: textColor ?? other.textColor,
        timeTextColor: timeTextColor ?? other.timeTextColor,
        borderRadius: borderRadius ?? other.borderRadius,
        messageSidePadding: messageSidePadding ?? other.messageSidePadding,
        messageAlignment: messageAlignment ?? other.messageAlignment,
        textAlignment: textAlignment ?? other.textAlignment,
        showName: showName ?? other.showName,
        showTime: showTime ?? other.showTime,
        showFullDate: showFullDate ?? other.showFullDate,
      );
}

MessageTheme? _defaultMessageThemeResolver(
  BuildContext context,
  MessageModel message,
  MessageModel? previousMessage,
  UserModel? sender,
) =>
    null;

ImageProvider _defaultImageProviderResolver(
  BuildContext context,
  Uri image,
) =>
    CachedNetworkImageProvider(image.toString());

/// All configurable paddings and whitespaces within the userstory
class ChatSpacing {
  /// Creates a ChatSpacing object
  const ChatSpacing({
    this.chatBetweenMessagesPadding = 16.0,
    this.chatSidePadding = 20.0,
  });

  /// The padding between the chat messages and the screen edge
  final double chatSidePadding;

  /// The padding between different chat messages if they are not from the same
  /// sender.
  final double chatBetweenMessagesPadding;
}

/// The chat pagination controls
/// Use this to define how sensitive the chat pagination should be.
class ChatPaginationControls {
  /// The chat pagination controls constructor
  const ChatPaginationControls({
    this.scrollOffset = 50.0,
    this.autoScrollTriggerOffset = 50.0,
    this.loadingIndicatorForNewMessages = true,
    this.loadingIndicatorForOldMessages = true,
    this.loadingNewMessageMinDuration = Duration.zero,
    this.loadingOldMessageMinDuration = Duration.zero,
  });

  /// The minimum scroll offset to trigger the pagination to call for more pages
  /// on both sides of the chat. Defaults to 50.0
  final double scrollOffset;

  /// The minimum scroll offset to trigger the auto scroll to the bottom of the
  /// chat. Defaults to 50.0
  final double autoScrollTriggerOffset;

  /// Whether to show a loading indicator for new messages loading
  final bool loadingIndicatorForNewMessages;

  /// Whether to show a loading indicator for old messages loading
  final bool loadingIndicatorForOldMessages;

  /// The minimum duration for the loading indicator for new messages
  /// to be shown. The loading indicator will wait for this duration and the
  /// completion of [ChatService.loadNewMessagesAfter]
  final Duration loadingNewMessageMinDuration;

  /// The minimum duration for the loading indicator for old messages
  /// to be shown. The loading indicator will wait for this duration and the
  /// completion of [ChatService.loadOldMessagesBefore]
  final Duration loadingOldMessageMinDuration;
}
