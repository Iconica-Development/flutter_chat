// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';
import 'package:flutter_community_chat_view/flutter_community_chat_view.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({
    required this.options,
    required this.users,
    required this.onPressCreateChat,
    this.translations = const ChatTranslations(),
    super.key,
  });

  final ChatOptions options;
  final ChatTranslations translations;
  final List<ChatUserModel> users;
  final Function(ChatUserModel) onPressCreateChat;

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final FocusNode _textFieldFocusNode = FocusNode();

  bool _isSearching = false;
  List<ChatUserModel>? _filteredUsers;

  void filterUsers(String query) => setState(
        () => _filteredUsers = query.isEmpty
            ? null
            : widget.users
                .where(
                  (user) => user.fullName.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList(),
      );

  @override
  Widget build(BuildContext context) {
    var users = _filteredUsers ?? widget.users;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  focusNode: _textFieldFocusNode,
                  onChanged: filterUsers,
                  decoration: InputDecoration(
                    hintText: widget.translations.searchPlaceholder,
                  ),
                ),
              )
            : Text(widget.translations.newChatButton),
        actions: [
          IconButton(
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
          )
        ],
      ),
      body: users.isEmpty
          ? widget.options.noChatsPlaceholderBuilder(widget.translations)
          : ListView(
              children: [
                for (var user in users)
                  GestureDetector(
                    child: widget.options.chatRowContainerBuilder(
                      ChatRow(
                        avatar: widget.options.userAvatarBuilder(
                          user,
                          40.0,
                        ),
                        title: user.fullName,
                      ),
                    ),
                    onTap: () => widget.onPressCreateChat(user),
                  ),
              ],
            ),
    );
  }
}
