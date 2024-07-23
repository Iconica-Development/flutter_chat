// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_chat_view/flutter_chat_view.dart";
import "package:flutter_chat_view/src/components/chat_image.dart";
import "package:flutter_chat_view/src/services/date_formatter.dart";

class ChatDetailRow extends StatefulWidget {
  const ChatDetailRow({
    required this.translations,
    required this.message,
    required this.userAvatarBuilder,
    required this.onPressUserProfile,
    required this.options,
    this.usernameBuilder,
    this.previousMessage,
    this.showTime = false,
    super.key,
  });

  /// The translations for the chat.
  final ChatTranslations translations;

  /// The chat message model.
  final ChatMessageModel message;

  /// The builder function for user avatar.
  final UserAvatarBuilder userAvatarBuilder;

  /// The previous chat message model.
  final ChatMessageModel? previousMessage;
  final Function(ChatUserModel user) onPressUserProfile;
  final Widget Function(String userFullName)? usernameBuilder;

  /// Flag indicating whether to show the time.
  final bool showTime;

  final ChatOptions options;

  @override
  State<ChatDetailRow> createState() => _ChatDetailRowState();
}

class _ChatDetailRowState extends State<ChatDetailRow> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var dateFormatter = DateFormatter(options: widget.options);

    var isNewDate = widget.previousMessage != null &&
        widget.message.timestamp.day != widget.previousMessage?.timestamp.day;
    var isSameSender = widget.previousMessage == null ||
        widget.previousMessage?.sender.id != widget.message.sender.id;
    var isSameMinute = widget.previousMessage != null &&
        widget.message.timestamp.minute ==
            widget.previousMessage?.timestamp.minute;
    var hasHeader = isNewDate || isSameSender;
    return Padding(
      padding: EdgeInsets.only(
        top: isNewDate || isSameSender ? 25.0 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isNewDate || isSameSender) ...[
            GestureDetector(
              onTap: () => widget.onPressUserProfile(
                widget.message.sender,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: widget.message.sender.imageUrl?.isNotEmpty ?? false
                    ? ChatImage(
                        image: widget.message.sender.imageUrl!,
                      )
                    : widget.userAvatarBuilder(
                        widget.message.sender,
                        40,
                      ),
              ),
            ),
          ] else ...[
            const SizedBox(
              width: 50,
            ),
          ],
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (isNewDate || isSameSender) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: widget.usernameBuilder?.call(
                                widget.message.sender.fullName ?? "",
                              ) ??
                              Text(
                                widget.message.sender.fullName ??
                                    widget.translations.anonymousUser,
                                style: widget
                                        .options.textstyles?.senderTextStyle ??
                                    theme.textTheme.titleMedium,
                              ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            dateFormatter.format(
                              date: widget.message.timestamp,
                              showFullDate: true,
                            ),
                            style: widget.options.textstyles?.dateTextStyle ??
                                theme.textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: widget.message is ChatTextMessageModel
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  (widget.message as ChatTextMessageModel).text,
                                  style: widget.options.textstyles
                                          ?.messageTextStyle ??
                                      theme.textTheme.bodySmall,
                                ),
                              ),
                              if (widget.showTime &&
                                  !isSameMinute &&
                                  !isNewDate &&
                                  !hasHeader)
                                Text(
                                  dateFormatter
                                      .format(
                                        date: widget.message.timestamp,
                                        showFullDate: true,
                                      )
                                      .split(" ")
                                      .last,
                                  style: widget
                                          .options.textstyles?.dateTextStyle ??
                                      theme.textTheme.labelSmall,
                                  textAlign: TextAlign.end,
                                ),
                            ],
                          )
                        : CachedNetworkImage(
                            imageUrl: (widget.message as ChatImageMessageModel)
                                .imageUrl,
                          ),
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
