// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:flutter/material.dart";
import "package:flutter_chat_view/flutter_chat_view.dart";

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({
    required this.options,
    required this.onPressCreateChat,
    required this.service,
    required this.onPressCreateGroupChat,
    this.showGroupChatButton = true,
    this.translations = const ChatTranslations.empty(),
    super.key,
  });

  /// Chat options.
  final ChatOptions options;

  /// Chat service instance.
  final ChatService service;

  /// Callback function for creating a new chat with a user.
  final Function(ChatUserModel) onPressCreateChat;

  /// Callback function for creating a new group chat.
  final Function() onPressCreateGroupChat;

  /// Option to enable the group chat creation button.
  final bool showGroupChatButton;

  /// Translations for the chat.
  final ChatTranslations translations;

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final FocusNode _textFieldFocusNode = FocusNode();
  bool _isSearching = false;
  String query = "";

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: theme.appBarTheme.iconTheme ??
            const IconThemeData(color: Colors.white),
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: _buildSearchField(),
        actions: [
          _buildSearchIcon(),
        ],
      ),
      body: Column(
        children: [
          if (widget.showGroupChatButton) ...[
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
                          Text(
                            widget.translations.newGroupChatButton,
                            style: const TextStyle(
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
          ],
          Expanded(
            child: FutureBuilder<List<ChatUserModel>>(
              // ignore: discarded_futures
              future: widget.service.chatUserService.getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (snapshot.hasData) {
                  return _buildUserList(snapshot.data!);
                } else {
                  return widget.options
                      .noUsersPlaceholderBuilder(widget.translations, context);
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
        ? TextField(
            focusNode: _textFieldFocusNode,
            onChanged: (value) {
              setState(() {
                query = value;
              });
            },
            decoration: InputDecoration(
              hintText: widget.translations.searchPlaceholder,
              hintStyle: theme.inputDecorationTheme.hintStyle,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            style: theme.inputDecorationTheme.hintStyle,
            cursorColor: theme.textSelectionTheme.cursorColor ?? Colors.white,
          )
        : Text(
            widget.translations.newChatTitle,
            style: theme.appBarTheme.titleTextStyle,
          );
  }

  Widget _buildSearchIcon() {
    var theme = Theme.of(context);

    return IconButton(
      onPressed: () {
        setState(() {
          _isSearching = !_isSearching;
          query = "";
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
    var theme = Theme.of(context);
    var filteredUsers = users
        .where(
          (user) =>
              user.fullName?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
              false,
        )
        .toList();

    if (_textFieldFocusNode.hasFocus && query.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Text(
          widget.translations.startTyping,
          style: theme.textTheme.bodySmall,
        ),
      );
    }

    if (filteredUsers.isEmpty) {
      return widget.options
          .noUsersPlaceholderBuilder(widget.translations, context);
    }
    var isPressed = false;
    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        var user = filteredUsers[index];
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.secondary.withOpacity(0.3),
                width: 0.5,
              ),
            ),
          ),
          child: GestureDetector(
            child: widget.options.chatRowContainerBuilder(
              Padding(
                padding: widget.options.paddingAroundChatList ??
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 28),
                child: ColoredBox(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: widget.options.userAvatarBuilder(user, 40.0),
                        ),
                        Expanded(
                          child: Container(
                            height: 40.0,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              user.fullName ??
                                  widget.translations.anonymousUser,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            onTap: () async {
              if (!isPressed) {
                isPressed = true;
                await widget.onPressCreateChat(user);
                isPressed = false;
              }
            },
          ),
        );
      },
    );
  }
}
