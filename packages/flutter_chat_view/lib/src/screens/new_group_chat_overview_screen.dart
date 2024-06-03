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
    return Scaffold(
      appBar: AppBar(
        iconTheme: theme.appBarTheme.iconTheme ??
            const IconThemeData(color: Colors.white),
        backgroundColor: theme.appBarTheme.backgroundColor ?? Colors.black,
        title: const Text(
          'New Group Chat',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _textEditingController,
          decoration: const InputDecoration(
            hintText: 'Group chat name',
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          await widget.onPressCompleteGroupChatCreation(
            widget.users,
            _textEditingController.text,
          );
        },
        child: const Icon(Icons.check_circle),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
