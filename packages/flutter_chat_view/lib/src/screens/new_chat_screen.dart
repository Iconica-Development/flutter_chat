// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_chat_view/flutter_chat_view.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({
    required this.options,
    required this.onPressCreateChat,
    required this.service,
    this.translations = const ChatTranslations(),
    super.key,
  });

  final ChatOptions options;
  final ChatTranslations translations;
  final ChatService service;
  final Function(ChatUserModel) onPressCreateChat;

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final FocusNode _textFieldFocusNode = FocusNode();
  bool _isSearching = false;
  String query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchField(),
        actions: [
          _buildSearchIcon(),
        ],
      ),
      body: FutureBuilder<List<ChatUserModel>>(
        future: widget.service.chatUserService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            return _buildUserList(snapshot.data!);
          } else {
            return widget.options
                .noChatsPlaceholderBuilder(widget.translations);
          }
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return _isSearching
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              focusNode: _textFieldFocusNode,
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
              decoration: InputDecoration(
                hintText: widget.translations.searchPlaceholder,
              ),
            ),
          )
        : Text(widget.translations.newChatButton);
  }

  Widget _buildSearchIcon() {
    return IconButton(
      onPressed: () {
        setState(() {
          _isSearching = !_isSearching;
        });

        if (_isSearching) {
          _textFieldFocusNode.requestFocus();
        }
      },
      icon: Icon(
        _isSearching ? Icons.close : Icons.search,
      ),
    );
  }

  Widget _buildUserList(List<ChatUserModel> users) {
    var filteredUsers = users
        .where(
          (user) =>
              user.fullName?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
              false,
        )
        .toList();

    if (filteredUsers.isEmpty) {
      return widget.options.noChatsPlaceholderBuilder(widget.translations);
    }

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        var user = filteredUsers[index];
        return GestureDetector(
          child: widget.options.chatRowContainerBuilder(
            ChatRow(
              avatar: widget.options.userAvatarBuilder(
                user,
                40.0,
              ),
              title: user.fullName ?? widget.translations.anonymousUser,
            ),
          ),
          onTap: () async {
            await widget.onPressCreateChat(user);
          },
        );
      },
    );
  }
}
