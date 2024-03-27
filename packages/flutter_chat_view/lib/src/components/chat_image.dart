// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A stateless widget representing an image in the chat.
class ChatImage extends StatelessWidget {
  /// Constructs a [ChatImage] widget.
  ///
  /// [image]: The URL of the image.
  ///
  /// [size]: The size of the image widget.
  const ChatImage({
    required this.image,
    this.size = 40,
    super.key,
  });

  /// The URL of the image.
  final String image;

  /// The size of the image widget.
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(40.0),
        ),
        width: size,
        height: size,
        child: image.isNotEmpty
            ? CachedNetworkImage(
                fadeInDuration: Duration.zero,
                imageUrl: image,
                fit: BoxFit.cover,
              )
            : null,
      );
}
