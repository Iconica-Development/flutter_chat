import 'package:chat_repository_interface/chat_repository_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/src/config/chat_options.dart';
import 'package:flutter_chat/src/screens/creation/widgets/search_field.dart';
import 'package:flutter_chat/src/screens/creation/widgets/search_icon.dart';
import 'package:flutter_chat/src/screens/creation/widgets/user_list.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({
    required this.userId,
    required this.chatService,
    required this.chatOptions,
    required this.onPressCreateGroupChat,
    required this.onPressCreateChat,
    super.key,
  });

  final String userId;
  final ChatService chatService;
  final ChatOptions chatOptions;
  final VoidCallback onPressCreateGroupChat;
  final Function(UserModel) onPressCreateChat;

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

    return widget.chatOptions.builders.newChatScreenScaffoldBuilder?.call(
          _AppBar(
            chatOptions: widget.chatOptions,
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
          ) as AppBar,
          _Body(
            chatOptions: widget.chatOptions,
            chatService: widget.chatService,
            isSearching: _isSearching,
            onPressCreateGroupChat: widget.onPressCreateGroupChat,
            onPressCreateChat: widget.onPressCreateChat,
            userId: widget.userId,
            query: query,
          ),
          theme.scaffoldBackgroundColor,
        ) ??
        Scaffold(
          appBar: _AppBar(
            chatOptions: widget.chatOptions,
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
            chatOptions: widget.chatOptions,
            chatService: widget.chatService,
            isSearching: _isSearching,
            onPressCreateGroupChat: widget.onPressCreateGroupChat,
            onPressCreateChat: widget.onPressCreateChat,
            userId: widget.userId,
            query: query,
          ),
        );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({
    required this.chatOptions,
    required this.isSearching,
    required this.onSearch,
    required this.onPressedSearchIcon,
    required this.focusNode,
  });

  final ChatOptions chatOptions;
  final bool isSearching;
  final Function(String) onSearch;
  final VoidCallback onPressedSearchIcon;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return AppBar(
      iconTheme: theme.appBarTheme.iconTheme ??
          const IconThemeData(color: Colors.white),
      title: SearchField(
        chatOptions: chatOptions,
        isSearching: isSearching,
        onSearch: onSearch,
        focusNode: focusNode,
        text: chatOptions.translations.newChatTitle,
      ),
      actions: [
        SearchIcon(
          isSearching: isSearching,
          onPressed: onPressedSearchIcon,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _Body extends StatelessWidget {
  const _Body({
    required this.chatOptions,
    required this.chatService,
    required this.isSearching,
    required this.onPressCreateGroupChat,
    required this.onPressCreateChat,
    required this.userId,
    required this.query,
  });

  final ChatOptions chatOptions;
  final ChatService chatService;
  final bool isSearching;

  final String userId;
  final String query;

  final VoidCallback onPressCreateGroupChat;
  final Function(UserModel) onPressCreateChat;

  @override
  Widget build(BuildContext context) {
    var translations = chatOptions.translations;
    var theme = Theme.of(context);

    return Column(
      children: [
        if (chatOptions.groupChatEnabled && !isSearching) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: 32,
              right: 32,
              top: 20,
            ),
            child: FilledButton(
              onPressed: onPressCreateGroupChat,
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
                    translations.newGroupChatButton,
                    style: theme.textTheme.displayLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
        Expanded(
          child: StreamBuilder<List<UserModel>>(
            // ignore: discarded_futures
            stream: chatService.getAllUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else if (snapshot.hasData) {
                return UserList(
                  users: snapshot.data!,
                  currentUser: userId,
                  query: query,
                  options: chatOptions,
                  onPressCreateChat: onPressCreateChat,
                );
              } else {
                return chatOptions.builders.noUsersPlaceholderBuilder
                        ?.call(translations) ??
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
