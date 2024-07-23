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
    return widget.options.newChatScreenScaffoldBuilder(
      AppBar(
        iconTheme: theme.appBarTheme.iconTheme ??
            const IconThemeData(color: Colors.white),
        title: _buildSearchField(),
        actions: [
          _buildSearchIcon(),
        ],
      ),
      Column(
        children: [
          if (widget.showGroupChatButton && !_isSearching) ...[
            Padding(
              padding: const EdgeInsets.only(
                left: 32,
                right: 32,
                top: 20,
              ),
              child: FilledButton(
                onPressed: () async {
                  await widget.onPressCreateGroupChat();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.groups,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      widget.translations.newGroupChatButton,
                      style: theme.textTheme.displayLarge,
                    ),
                  ],
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
      theme.scaffoldBackgroundColor,
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
              hintStyle:
                  theme.textTheme.bodyMedium!.copyWith(color: Colors.white),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            style: theme.textTheme.bodySmall!.copyWith(color: Colors.white),
            cursorColor: theme.textSelectionTheme.cursorColor ?? Colors.white,
          )
        : Text(
            widget.translations.newChatTitle,
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
        child: Align(
          alignment: Alignment.topCenter,
          child: Text(
            widget.translations.startTyping,
            style: theme.textTheme.bodySmall,
          ),
        ),
      );
    }

    if (filteredUsers.isEmpty) {
      return widget.options
          .noUsersPlaceholderBuilder(widget.translations, context);
    }
    var isPressed = false;
    return Padding(
      padding: widget.options.paddingAroundChatList ??
          const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListView.builder(
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          var user = filteredUsers[index];
          return InkWell(
            onTap: () async {
              if (!isPressed) {
                isPressed = true;
                await widget.onPressCreateChat(user);
                isPressed = false;
              }
            },
            child: widget.options.chatRowContainerBuilder(
              Row(
                children: [
                  widget.options.userAvatarBuilder(user, 44),
                  const SizedBox(
                    width: 12,
                  ),
                  Text(
                    user.fullName ?? widget.translations.anonymousUser,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
              context,
            ),
          );
        },
      ),
    );
  }
}
