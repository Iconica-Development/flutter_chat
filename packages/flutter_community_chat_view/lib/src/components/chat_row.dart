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
  final String title;
  final int unreadMessages;
  final Widget? avatar;
  final String? subTitle;
  final String? lastUsed;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: avatar,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: unreadMessages > 0
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  if (subTitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3.0),
                      child: Text(
                        subTitle!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: unreadMessages > 0
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                lastUsed ?? '',
                style: const TextStyle(
                  color: Color(0xFFBBBBBB),
                  fontSize: 14,
                ),
              ),
              if (unreadMessages > 0) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Container(
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
                ),
              ],
            ],
          ),
        ],
      );
}
