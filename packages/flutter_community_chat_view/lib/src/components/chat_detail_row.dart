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
    required this.translations,
    required this.message,
    required this.userAvatarBuilder,
    this.previousMessage,
    this.showTime = false,
    super.key,
  });

  final ChatTranslations translations;
  final ChatMessageModel message;
  final UserAvatarBuilder userAvatarBuilder;
  final bool showTime;
  final ChatMessageModel? previousMessage;

  @override
  State<ChatDetailRow> createState() => _ChatDetailRowState();
}

class _ChatDetailRowState extends State<ChatDetailRow> {
  final DateFormatter _dateFormatter = DateFormatter();

  @override
  Widget build(BuildContext context) {
    var isNewDate = widget.previousMessage != null &&
        widget.message.timestamp.day != widget.previousMessage?.timestamp.day;
    var isSameSender = widget.previousMessage == null ||
        widget.previousMessage?.sender.id != widget.message.sender.id;
    print(isNewDate);

    return Padding(
      padding: EdgeInsets.only(
        top: isNewDate || isSameSender ? 25.0 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isNewDate || isSameSender) ...[
            Padding(
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
          ] else ...[
            const SizedBox(
              width: 50,
            ),
          ],
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (isNewDate || isSameSender)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.message.sender.fullName?.toUpperCase() ??
                                widget.translations.anonymousUser,
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
                          ? RichText(
                              text: TextSpan(
                                text: (widget.message as ChatTextMessageModel)
                                    .text,
                                style: const TextStyle(fontSize: 16),
                                children: <TextSpan>[
                                  if (widget.showTime)
                                    TextSpan(
                                      text: " ${_dateFormatter.format(
                                            date: widget.message.timestamp,
                                            showFullDate: true,
                                          ).split(' ').last}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFBBBBBB),
                                      ),
                                    )
                                  else
                                    const TextSpan(),
                                ],
                              ),
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
}
