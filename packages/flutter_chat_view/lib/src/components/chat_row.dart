// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';

class ChatRow extends StatelessWidget {
  const ChatRow({
    required this.title,
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
                  style: unreadMessages > 0
                      ? theme.textTheme.bodyLarge
                      : theme.textTheme.bodyMedium,
                ),
                if (subTitle != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Text(
                      subTitle!,
                      style: unreadMessages > 0
                          ? theme.textTheme.bodyLarge
                          : theme.textTheme.bodyMedium,
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
                  style: const TextStyle(
                    color: Color(0xFFBBBBBB),
                    fontSize: 14,
                  ),
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
