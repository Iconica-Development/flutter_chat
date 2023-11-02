// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_community_chat_view/flutter_community_chat_view.dart';
import 'package:flutter_community_chat_view/src/components/chat_image.dart';
import 'package:flutter_community_chat_view/src/services/date_formatter.dart';

class ChatDetailRow extends StatefulWidget {
  const ChatDetailRow({
    required this.isFirstMessage,
    required this.message,
    required this.userAvatarBuilder,
    super.key,
  });

  final bool isFirstMessage;
  final ChatMessageModel message;
  final UserAvatarBuilder userAvatarBuilder;

  @override
  State<ChatDetailRow> createState() => _ChatDetailRowState();
}

class _ChatDetailRowState extends State<ChatDetailRow> {
  final DateFormatter _dateFormatter = DateFormatter();

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(top: widget.isFirstMessage ? 25.0 : 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Opacity(
              opacity: widget.isFirstMessage ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: widget.message.sender.imageUrl != null &&
                        widget.message.sender.imageUrl!.isNotEmpty
                    ? ChatImage(
                        image: widget.message.sender.imageUrl!,
                      )
                    : widget.userAvatarBuilder(
                        widget.message.sender,
                        30,
                      ),
              ),
            ),
            Expanded(
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (widget.isFirstMessage)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.message.sender.fullName?.toUpperCase() ??
                                  '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Text(
                                _dateFormatter.format(
                                  date: widget.message.timestamp,
                                  showFullDate: true,
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFBBBBBB),
                                ),
                              ),
                            ),
                          ],
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: widget.message is ChatTextMessageModel
                            ? Text(
                                (widget.message as ChatTextMessageModel).text,
                                style: const TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 999,
                              )
                            : CachedNetworkImage(
                                imageUrl:
                                    (widget.message as ChatImageMessageModel)
                                        .imageUrl,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
