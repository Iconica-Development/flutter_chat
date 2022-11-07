// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';
import 'package:flutter_community_chat_view/src/components/chat_image.dart';
import 'package:flutter_community_chat_view/src/services/date_formatter.dart';

class ChatDetailRow extends StatefulWidget {
  const ChatDetailRow({
    required this.message,
    super.key,
  });

  final ChatMessageModel message;

  @override
  State<ChatDetailRow> createState() => _ChatDetailRowState();
}

class _ChatDetailRowState extends State<ChatDetailRow> {
  final DateFormatter _dateFormatter = DateFormatter();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 43.0),
        child: Row(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: ChatImage(
                  image: widget.message.sender.imageUrl,
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
                      Text(
                        widget.message.sender.name != null
                            ? widget.message.sender.name!.toUpperCase()
                            : '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: widget.message is ChatTextMessageModel
                            ? Text(
                                (widget.message as ChatTextMessageModel).text,
                                style: const TextStyle(
                                  fontSize: 16,
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
                ),
              ),
            ),
          ],
        ),
      );
}
