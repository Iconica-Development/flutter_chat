// SPDX-License-Identifier: BSD-3-Clause

import "package:flutter/material.dart";
import "package:flutter_chat_view/flutter_chat_view.dart";

class NewGroupChatScreen extends StatefulWidget {
  const NewGroupChatScreen({
    required this.options,
    required this.onPressGroupChatOverview,
    required this.service,
    this.translations = const ChatTranslations.empty(),
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
  String query = "";

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        iconTheme: theme.appBarTheme.iconTheme ??
            const IconThemeData(color: Colors.white),
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: _buildSearchField(),
        actions: [
          _buildSearchIcon(),
        ],
      ),
      body: FutureBuilder<List<ChatUserModel>>(
        // ignore: discarded_futures
        future: widget.service.chatUserService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            return _buildUserList(snapshot.data!);
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          await widget.onPressGroupChatOverview(selectedUserList);
        },
        child: const Icon(Icons.arrow_forward_ios),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
            widget.translations.newGroupChatButton,
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
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.options
              .noUsersPlaceholderBuilder(widget.translations, context),
        ],
      );
    }

    return UserList(
      filteredUsers: filteredUsers,
      selectedUserList: selectedUserList,
      options: widget.options,
      translations: widget.translations,
    );
  }
}

class UserList extends StatefulWidget {
  const UserList({
    required this.filteredUsers,
    required this.selectedUserList,
    required this.options,
    required this.translations,
    super.key,
  });

  final List<ChatUserModel> filteredUsers;
  final List<ChatUserModel> selectedUserList;
  final ChatOptions options;
  final ChatTranslations translations;

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: widget.filteredUsers.length,
        itemBuilder: (context, index) {
          var user = widget.filteredUsers[index];
          var isSelected = widget.selectedUserList
              .any((selectedUser) => selectedUser == user);
          var theme = Theme.of(context);
          return DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.secondary.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  if (widget.selectedUserList.contains(user)) {
                    widget.selectedUserList.remove(user);
                  } else {
                    widget.selectedUserList.add(user);
                  }
                });
              },
              child: Padding(
                padding: widget.options.paddingAroundChatList ??
                    const EdgeInsets.fromLTRB(28, 8, 28, 8),
                child: ColoredBox(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 30,
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: widget.options.userAvatarBuilder(user, 40.0),
                        ),
                        Expanded(
                          child: Container(
                            height: 40,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              user.fullName ??
                                  widget.translations.anonymousUser,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ),
                        if (isSelected) ...[
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Icon(
                              Icons.check_circle,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
}
