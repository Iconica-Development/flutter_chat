import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_accessibility/flutter_accessibility.dart";
import "package:flutter_chat/src/config/screen_types.dart";
import "package:flutter_chat/src/screens/creation/widgets/search_field.dart";
import "package:flutter_chat/src/screens/creation/widgets/search_icon.dart";
import "package:flutter_chat/src/screens/creation/widgets/user_list.dart";
import "package:flutter_chat/src/util/scope.dart";
import "package:flutter_hooks/flutter_hooks.dart";

/// New group chat screen
/// This screen is used to create a new group chat
class NewGroupChatScreen extends StatefulHookWidget {
  /// Constructs a [NewGroupChatScreen]
  const NewGroupChatScreen({
    required this.onExit,
    required this.onContinue,
    super.key,
  });

  /// Callback for when the user wants to navigate back
  final VoidCallback onExit;

  /// Callback function triggered when the continue button is pressed
  final Function(List<UserModel>) onContinue;

  @override
  State<NewGroupChatScreen> createState() => _NewGroupChatScreenState();
}

class _NewGroupChatScreenState extends State<NewGroupChatScreen> {
  final FocusNode _textFieldFocusNode = FocusNode();
  bool _isSearching = false;
  String query = "";

  List<UserModel> selectedUsers = [];

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;

    useEffect(() {
      chatScope.popHandler.add(widget.onExit);
      return () => chatScope.popHandler.remove(widget.onExit);
    });
    if (options.builders.baseScreenBuilder == null) {
      return Scaffold(
        appBar: _AppBar(
          isSearching: _isSearching,
          onSearch: (query) {
            setState(() {
              _isSearching = query.isNotEmpty;
              this.query = query;
            });
          },
          onPressedSearchIcon: () {
            setState(() {
              _isSearching = !_isSearching;
              query = "";
            });

            if (_isSearching) {
              _textFieldFocusNode.requestFocus();
            }
          },
          focusNode: _textFieldFocusNode,
        ),
        body: _Body(
          onSelectedUser: handleUserTap,
          selectedUsers: selectedUsers,
          onPressGroupChatOverview: widget.onContinue,
          isSearching: _isSearching,
          query: query,
        ),
      );
    }

    return options.builders.baseScreenBuilder!.call(
      context,
      widget.mapScreenType,
      _AppBar(
        isSearching: _isSearching,
        onSearch: (query) {
          setState(() {
            _isSearching = query.isNotEmpty;
            this.query = query;
          });
        },
        onPressedSearchIcon: () {
          setState(() {
            _isSearching = !_isSearching;
            query = "";
          });

          if (_isSearching) {
            _textFieldFocusNode.requestFocus();
          }
        },
        focusNode: _textFieldFocusNode,
      ),
      options.translations.newGroupChatTitle,
      _Body(
        onSelectedUser: handleUserTap,
        selectedUsers: selectedUsers,
        onPressGroupChatOverview: widget.onContinue,
        isSearching: _isSearching,
        query: query,
      ),
    );
  }

  void handleUserTap(UserModel user) {
    if (selectedUsers.contains(user)) {
      setState(() {
        selectedUsers.remove(user);
      });
    } else {
      setState(() {
        selectedUsers.add(user);
      });
    }
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({
    required this.isSearching,
    required this.onSearch,
    required this.onPressedSearchIcon,
    required this.focusNode,
  });

  final bool isSearching;
  final Function(String) onSearch;
  final VoidCallback onPressedSearchIcon;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;
    var theme = Theme.of(context);

    return AppBar(
      iconTheme: theme.appBarTheme.iconTheme ??
          const IconThemeData(color: Colors.white),
      title: SearchField(
        isSearching: isSearching,
        onSearch: onSearch,
        focusNode: focusNode,
        text: options.translations.newGroupChatTitle,
        semanticId: options.semantics.newGroupChatSearchInput,
      ),
      actions: [
        SearchIcon(
          isSearching: isSearching,
          onPressed: onPressedSearchIcon,
          semanticId: options.semantics.newGroupChatSearchIconButton,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _Body extends StatelessWidget {
  const _Body({
    required this.isSearching,
    required this.query,
    required this.selectedUsers,
    required this.onSelectedUser,
    required this.onPressGroupChatOverview,
  });

  final bool isSearching;

  final String query;

  final List<UserModel> selectedUsers;
  final Function(UserModel) onSelectedUser;
  final Function(List<UserModel>) onPressGroupChatOverview;

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var service = chatScope.service;
    var options = chatScope.options;
    var userId = chatScope.userId;
    var translations = options.translations;
    var theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<UserModel>>(
            // ignore: discarded_futures
            stream: service.getAllUsers(),
            builder: (context, snapshot) {
              var chatScope = ChatScope.of(context);
              var options = chatScope.options;

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Semantics(
                  identifier: options.semantics.newGroupChatGetUsersError,
                  value: "Error: ${snapshot.error}",
                  child: Text("Error: ${snapshot.error}"),
                );
              } else if (snapshot.hasData) {
                return Stack(
                  children: [
                    UserList(
                      users: snapshot.data!,
                      currentUser: userId,
                      query: query,
                      onPressCreateChat: null,
                      creatingGroup: true,
                      selectedUsers: selectedUsers,
                      onSelectedUser: onSelectedUser,
                    ),
                    _NextButton(
                      selectedUsers: selectedUsers,
                      onPressGroupChatOverview: onPressGroupChatOverview,
                    ),
                  ],
                );
              } else {
                return options.builders.noUsersPlaceholderBuilder
                        ?.call(context, translations) ??
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          translations.noUsersFound,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    );
              }
            },
          ),
        ),
      ],
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({
    required this.onPressGroupChatOverview,
    required this.selectedUsers,
  });

  final Function(List<UserModel>) onPressGroupChatOverview;
  final List<UserModel> selectedUsers;

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;
    var theme = Theme.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 24,
          horizontal: 80,
        ),
        child: Visibility(
          visible: selectedUsers.isNotEmpty,
          child: CustomSemantics(
            identifier: options.semantics.newGroupChatNextButton,
            child: FilledButton(
              onPressed: () async {
                await onPressGroupChatOverview(selectedUsers);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    options.translations.next,
                    style: theme.textTheme.displayLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
