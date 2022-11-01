// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_community_chat_view/src/components/chat_image.dart';

class ChatRow extends StatelessWidget {
  const ChatRow({
    required this.title,
    this.image,
    this.lastUsed,
    this.subTitle,
    super.key,
  });
  final String title;
  final String? image;
  final String? subTitle;
  final String? lastUsed;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: ChatImage(
              image: image,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subTitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3.0),
                      child: Text(
                        subTitle!,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Text(
            lastUsed == null ? '' : lastUsed!,
            style: const TextStyle(
              color: Color(0xFFBBBBBB),
              fontSize: 14,
            ),
          ),
        ],
      );
}
