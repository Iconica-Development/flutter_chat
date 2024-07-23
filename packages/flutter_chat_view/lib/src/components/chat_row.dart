// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:flutter/material.dart";
import "package:flutter_chat_view/flutter_chat_view.dart";

class ChatRow extends StatelessWidget {
  const ChatRow({
    required this.title,
    required this.options,
    this.unreadMessages = 0,
    this.lastUsed,
    this.subTitle,
    this.avatar,
    super.key,
  });

  /// The title of the chat.
  final String title;

  /// The number of unread messages in the chat.
  final int unreadMessages;

  /// The last time the chat was used.
  final String? lastUsed;

  /// The subtitle of the chat.
  final String? subTitle;

  /// The avatar associated with the chat.
  final Widget? avatar;

  final ChatOptions options;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: avatar,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: options.textstyles?.senderTextStyle ??
                      theme.textTheme.titleMedium,
                ),
                if (subTitle != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Text(
                      subTitle!,
                      style: unreadMessages > 0
                          ? options.textstyles?.messageTextStyle!.copyWith(
                                fontWeight: FontWeight.w800,
                              ) ??
                              theme.textTheme.bodySmall!.copyWith(
                                fontWeight: FontWeight.w800,
                              )
                          : options.textstyles?.messageTextStyle ??
                              theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (lastUsed != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  lastUsed!,
                  style: options.textstyles?.dateTextStyle ??
                      theme.textTheme.labelSmall,
                ),
              ),
            ],
            if (unreadMessages > 0) ...[
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    unreadMessages.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
