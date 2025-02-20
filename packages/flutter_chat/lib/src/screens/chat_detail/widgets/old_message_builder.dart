import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_chat/src/services/date_formatter.dart";
import "package:flutter_chat/src/util/scope.dart";
import "package:flutter_profile/flutter_profile.dart";

/// The old chat message builder that shows messages with the user image on the
/// left and the message on the right.
class OldChatMessageBuilder extends StatelessWidget {
  /// Creates a new [OldChatMessageBuilder]
  const OldChatMessageBuilder({
    required this.message,
    required this.previousMessage,
    required this.user,
    required this.onPressUserProfile,
    super.key,
  });

  /// The message that is being built
  final MessageModel message;

  /// The previous message if any, this can be used to determine if the message
  /// is from the same sender as the previous message.
  final MessageModel? previousMessage;

  /// The user that sent the message
  final UserModel user;

  /// The function that is called when the user profile is pressed
  final Function(UserModel user) onPressUserProfile;

  /// implements [ChatMessageBuilder]
  static Widget builder(
    BuildContext context,
    MessageModel message,
    MessageModel? previousMessage,
    UserModel user,
    Function(UserModel user) onPressUserProfile,
  ) =>
      OldChatMessageBuilder(
        message: message,
        previousMessage: previousMessage,
        user: user,
        onPressUserProfile: onPressUserProfile,
      );

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;
    var translations = options.translations;
    var theme = Theme.of(context);
    var dateFormatter = DateFormatter(options: options);

    var isNewDate = previousMessage != null &&
        message.timestamp.day != previousMessage?.timestamp.day;
    var isSameSender = previousMessage == null ||
        previousMessage?.senderId != message.senderId;
    var isSameMinute = previousMessage != null &&
        message.timestamp.minute == previousMessage?.timestamp.minute;
    var hasHeader = isNewDate || isSameSender;

    return Padding(
      padding: EdgeInsets.only(
        top: hasHeader ? 25.0 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasHeader) ...[
            InkWell(
              onTap: () => onPressUserProfile(user),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: user.imageUrl?.isNotEmpty ?? false
                    ? _ChatImage(
                        image: user.imageUrl!,
                      )
                    : options.builders.userAvatarBuilder?.call(
                          context,
                          user,
                          40,
                        ) ??
                        Avatar(
                          key: ValueKey(user.id),
                          boxfit: BoxFit.cover,
                          user: User(
                            firstName: user.firstName,
                            lastName: user.lastName,
                            imageUrl:
                                user.imageUrl != "" ? user.imageUrl : null,
                          ),
                          size: 40,
                        ),
              ),
            ),
          ] else ...[
            const SizedBox(width: 50),
          ],
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (hasHeader) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: options.builders.usernameBuilder?.call(
                                user.fullname ?? "",
                              ) ??
                              Text(
                                user.fullname ?? translations.anonymousUser,
                                style: theme.textTheme.titleMedium,
                              ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            dateFormatter.format(
                              date: message.timestamp,
                              showFullDate: true,
                            ),
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: message.isTextMessage
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  message.text ?? "",
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                              if (!isSameMinute && !isNewDate && !hasHeader)
                                Text(
                                  dateFormatter
                                      .format(
                                        date: message.timestamp,
                                        showFullDate: true,
                                      )
                                      .split(" ")
                                      .last,
                                  style: theme.textTheme.labelSmall,
                                  textAlign: TextAlign.end,
                                ),
                            ],
                          )
                        : message.isImageMessage
                            ? Image(
                                image: options.imageProviderResolver(
                                  context,
                                  Uri.parse(message.imageUrl!),
                                ),
                              )
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatImage extends StatelessWidget {
  const _ChatImage({
    required this.image,
  });

  final String image;

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(40.0),
      ),
      width: 40,
      height: 40,
      child: image.isNotEmpty
          ? Image(
              fit: BoxFit.cover,
              image: options.imageProviderResolver(context, Uri.parse(image)),
            )
          : null,
    );
  }
}
