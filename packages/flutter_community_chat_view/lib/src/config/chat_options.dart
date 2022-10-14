import 'package:flutter/material.dart';

class ChatOptions {
  const ChatOptions({
    this.newChatButtonBuilder = _createNewChatButton,
    this.messageInputBuilder = _createMessageInput,
    this.chatRowContainerBuilder = _createChatRowContainer,
    this.imagePickerContainerBuilder = _createImagePickerContainer,
    this.closeImagePickerButtonBuilder = _createCloseImagePickerButton,
    this.scaffoldBuilder = _createScaffold,
  });

  final ButtonBuilder newChatButtonBuilder;
  final TextInputBuilder messageInputBuilder;
  final ContainerBuilder chatRowContainerBuilder;
  final ContainerBuilder imagePickerContainerBuilder;
  final ButtonBuilder closeImagePickerButtonBuilder;
  final ScaffoldBuilder scaffoldBuilder;
}

Widget _createNewChatButton(
  BuildContext context,
  VoidCallback onPressed,
) =>
    Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
        ),
        onPressed: onPressed,
        child: const Text('Start chat'),
      ),
    );

Widget _createMessageInput(
  TextEditingController textEditingController,
  Widget suffixIcon,
) =>
    TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: 'Schrijf hier je bericht',
        suffixIcon: suffixIcon,
      ),
    );

Widget _createChatRowContainer(
  Widget chatRow,
) =>
    Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 15.0,
        horizontal: 10.0,
      ),
      child: chatRow,
    );

Widget _createImagePickerContainer(
  Widget imagePicker,
) =>
    Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.black,
      child: imagePicker,
    );

Widget _createCloseImagePickerButton(
  BuildContext context,
  VoidCallback onPressed,
) =>
    ElevatedButton(
      onPressed: onPressed,
      child: const Text('Annuleren'),
    );

Scaffold _createScaffold(
  AppBar appbar,
  Widget body,
) =>
    Scaffold(
      appBar: appbar,
      body: body,
    );

typedef ButtonBuilder = Widget Function(
  BuildContext context,
  VoidCallback onPressed,
);

typedef TextInputBuilder = Widget Function(
  TextEditingController textEditingController,
  Widget suffixIcon,
);

typedef ContainerBuilder = Widget Function(
  Widget child,
);

typedef ScaffoldBuilder = Scaffold Function(
  AppBar appBar,
  Widget body,
);
