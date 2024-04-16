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
    required this.onPressCreateGroupChat,
    this.translations = const ChatTranslations(),
    super.key,
  });

  /// Chat options.
  final ChatOptions options;

  /// Chat service instance.
  final ChatService service;

  /// Callback function for creating a new chat with a user.
  final Function(ChatUserModel) onPressCreateChat;
  final Function() onPressCreateGroupChat;

  /// Translations for the chat.
  final ChatTranslations translations;

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final FocusNode _textFieldFocusNode = FocusNode();
  bool _isSearching = false;
  String query = '';

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: theme.appBarTheme.iconTheme ??
            const IconThemeData(color: Colors.white),
        backgroundColor: theme.appBarTheme.backgroundColor ?? Colors.black,
        title: _buildSearchField(),
        actions: [
          _buildSearchIcon(),
        ],
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () async {
              await widget.onPressCreateGroupChat();
            },
            child: Container(
              color: Colors.grey[900],
              child: SizedBox(
                height: 60.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16.0,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.group,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // Handle group chat creation
                            },
                          ),
                        ),
                        const Text(
                          'Create group chat',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ChatUserModel>>(
              // ignore: discarded_futures
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
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    var theme = Theme.of(context);

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
                hintStyle: theme.inputDecorationTheme.hintStyle ??
                    const TextStyle(
                      color: Colors.white,
                    ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: theme.inputDecorationTheme.focusedBorder?.borderSide
                            .color ??
                        Colors.white,
                  ),
                ),
              ),
              style: theme.inputDecorationTheme.hintStyle ??
                  const TextStyle(
                    color: Colors.white,
                  ),
              cursorColor: theme.textSelectionTheme.cursorColor ?? Colors.white,
            ),
          )
        : Text(
            widget.translations.newChatTitle,
            style: theme.appBarTheme.titleTextStyle ??
                const TextStyle(
                  color: Colors.white,
                ),
          );
  }

  Widget _buildSearchIcon() {
    var theme = Theme.of(context);

    return IconButton(
      onPressed: () {
        setState(() {
          _isSearching = !_isSearching;
          query = '';
        });

        if (_isSearching) {
          _textFieldFocusNode.requestFocus();
        }
      },
      icon: Icon(
        _isSearching ? Icons.close : Icons.search,
        color: theme.appBarTheme.iconTheme?.color ?? Colors.white,
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

    return ListView.separated(
      itemCount: filteredUsers.length,
      separatorBuilder: (context, index) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.0),
        child: Divider(),
      ), // Add Divider here
      itemBuilder: (context, index) {
        var user = filteredUsers[index];
        return GestureDetector(
          child: widget.options.chatRowContainerBuilder(
            Container(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12),
                      child: widget.options.userAvatarBuilder(user, 40.0),
                    ),
                    Expanded(
                      child: Container(
                        height: 40.0, // Adjust the height as needed
                        alignment: Alignment.centerLeft,
                        child: Text(
                          user.fullName ?? widget.translations.anonymousUser,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
