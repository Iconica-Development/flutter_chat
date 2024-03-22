// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_chat_view/flutter_chat_view.dart';

class NewGroupChatScreen extends StatefulWidget {
  const NewGroupChatScreen({
    required this.options,
    required this.onPressGroupChatOverview,
    required this.service,
    this.translations = const ChatTranslations(),
    super.key,
  });

  final ChatOptions options;
  final ChatTranslations translations;
  final ChatService service;
  final Function(List<ChatUserModel>) onPressGroupChatOverview;

  @override
  State<NewGroupChatScreen> createState() => _NewGroupChatScreenState();
}

class _NewGroupChatScreenState extends State<NewGroupChatScreen> {
  final FocusNode _textFieldFocusNode = FocusNode();
  List<ChatUserModel> selectedUserList = [];

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
      body: FutureBuilder<List<ChatUserModel>>(
        future: widget.service.chatUserService.getAllUsers,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await widget.onPressGroupChatOverview(selectedUserList);
        },
        child: const Icon(Icons.arrow_circle_right),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
            widget.translations.newGroupChatButton,
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

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        var user = filteredUsers[index];
        var isSelected = selectedUserList.contains(user);

        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedUserList.remove(user);
              } else {
                selectedUserList.add(user);
              }
              debugPrint('The list of selected users is $selectedUserList');
            });
          },
          child: Container(
            color: isSelected ? Colors.amber.shade200 : Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: widget.options.chatRowContainerBuilder(
                    ChatRow(
                      avatar: widget.options.userAvatarBuilder(
                        user,
                        40.0,
                      ),
                      title: user.fullName ?? widget.translations.anonymousUser,
                    ),
                  ),
                ),
                if (isSelected)
                  const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(Icons.check_circle, color: Colors.green),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
