// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_chat_view/flutter_chat_view.dart';

class NewGroupChatOverviewScreen extends StatefulWidget {
  const NewGroupChatOverviewScreen({
    required this.options,
    required this.onPressCompleteGroupChatCreation,
    required this.service,
    required this.users,
    this.translations = const ChatTranslations.empty(),
    super.key,
  });

  final ChatOptions options;
  final ChatTranslations translations;
  final ChatService service;
  final List<ChatUserModel> users;
  final Function(List<ChatUserModel>, String) onPressCompleteGroupChatCreation;

  @override
  State<NewGroupChatOverviewScreen> createState() =>
      _NewGroupChatOverviewScreenState();
}

class _NewGroupChatOverviewScreenState
    extends State<NewGroupChatOverviewScreen> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var formKey = GlobalKey<FormState>();
    var isPressed = false;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        iconTheme: theme.appBarTheme.iconTheme ??
            const IconThemeData(color: Colors.white),
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          widget.translations.newGroupChatTitle,
          style: theme.appBarTheme.titleTextStyle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: TextFormField(
            controller: _textEditingController,
            decoration: InputDecoration(
              hintText: widget.translations.groupNameHintText,
              hintStyle: theme.inputDecorationTheme.hintStyle,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return widget.translations.groupNameValidatorEmpty;
              }
              if (value.length > 15)
                return widget.translations.groupNameValidatorTooLong;
              return null;
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          if (!isPressed) {
            isPressed = true;
            if (formKey.currentState!.validate()) {
              await widget.onPressCompleteGroupChatCreation(
                widget.users,
                _textEditingController.text,
              );
            }
            isPressed = false;
          }
        },
        child: const Icon(
          Icons.check_circle,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
