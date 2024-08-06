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

  bool _isSearching = false;
  String query = "";

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return widget.options.newGroupChatScreenScaffoldBuilder(
      AppBar(
        iconTheme: theme.appBarTheme.iconTheme ??
            const IconThemeData(color: Colors.white),
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: _buildSearchField(),
        actions: [
          _buildSearchIcon(),
        ],
      ),
      FutureBuilder<List<ChatUserModel>>(
        // ignore: discarded_futures
        future: widget.service.chatUserService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            return Stack(
              children: [
                _buildUserList(snapshot.data!),
                NextButton(
                  service: widget.service,
                  onPressGroupChatOverview: widget.onPressGroupChatOverview,
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
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
            widget.translations.newGroupChatButton,
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
      options: widget.options,
      translations: widget.translations,
      service: widget.service,
    );
  }
}

class NextButton extends StatefulWidget {
  const NextButton({
    required this.service,
    required this.onPressGroupChatOverview,
    super.key,
  });

  final ChatService service;
  final Function(List<ChatUserModel>) onPressGroupChatOverview;

  @override
  State<NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<NextButton> {
  @override
  void initState() {
    widget.service.chatOverviewService.addListener(_listen);
    super.initState();
  }

  @override
  void dispose() {
    widget.service.chatOverviewService.removeListener(_listen);
    super.dispose();
  }

  void _listen() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 24,
          horizontal: 80,
        ),
        child: Visibility(
          visible: widget
              .service.chatOverviewService.currentlySelectedUsers.isNotEmpty,
          child: FilledButton(
            onPressed: () async {
              await widget.onPressGroupChatOverview(
                widget.service.chatOverviewService.currentlySelectedUsers,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Next",
                  style: theme.textTheme.displayLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserList extends StatefulWidget {
  const UserList({
    required this.filteredUsers,
    required this.options,
    required this.translations,
    required this.service,
    super.key,
  });

  final List<ChatUserModel> filteredUsers;
  final ChatOptions options;
  final ChatTranslations translations;
  final ChatService service;

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  @override
  void initState() {
    widget.service.chatOverviewService.addListener(_listen);
    super.initState();
  }

  @override
  void dispose() {
    widget.service.chatOverviewService.removeListener(_listen);
    super.dispose();
  }

  void _listen() {
    setState(() {});
  }

  void _toggleUserSelection(user) {
    setState(() {
      if (widget.service.chatOverviewService.currentlySelectedUsers
          .contains(user)) {
        widget.service.chatOverviewService.removeCurrentlySelectedUser(user);
      } else {
        widget.service.chatOverviewService.addCurrentlySelectedUser(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: widget.options.paddingAroundChatList ??
            const EdgeInsets.only(
              top: 8,
              left: 12,
              right: 12,
              bottom: 80,
            ),
        child: ListView.builder(
          itemCount: widget.filteredUsers.length,
          itemBuilder: (context, index) {
            var user = widget.filteredUsers[index];
            var isSelected = widget
                .service.chatOverviewService.currentlySelectedUsers
                .any((selectedUser) => selectedUser == user);
            var theme = Theme.of(context);
            return widget.options.chatRowContainerBuilder(
              InkWell(
                onTap: () => _toggleUserSelection(user),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) => _toggleUserSelection(user),
                    ),
                  ],
                ),
              ),
              context,
            );
          },
        ),
      );
}
