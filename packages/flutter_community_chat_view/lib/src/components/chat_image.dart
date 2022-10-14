import 'package:flutter/material.dart';

class ChatImage extends StatelessWidget {
  const ChatImage({
    super.key,
    this.image,
    this.size = 40,
  });

  final String? image;
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
        child: image == null
            ? const Center(child: Icon(Icons.person))
            : Image.network(
                image!,
                fit: BoxFit.cover,
              ),
      );
}
