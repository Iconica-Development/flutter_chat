import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_chat/src/config/chat_options.dart";
import "package:flutter_chat/src/config/screen_types.dart";
import "package:flutter_chat/src/screens/creation/widgets/search_field.dart";
import "package:flutter_chat/src/screens/creation/widgets/search_icon.dart";
import "package:flutter_chat/src/screens/creation/widgets/user_list.dart";
import "package:flutter_chat/src/util/scope.dart";
import "package:flutter_hooks/flutter_hooks.dart";

/// New chat screen
/// This screen is used to create a new chat
class NewChatScreen extends StatefulHookWidget {
  /// Constructs a [NewChatScreen]
  const NewChatScreen({
    required this.onExit,
    required this.onPressCreateGroupChat,
    required this.onPressCreateChat,
    super.key,
  });

  /// Callback function triggered when the create group chat button is pressed
  final VoidCallback onPressCreateGroupChat;

  /// Callback function triggered when a user is tapped
  final Function(UserModel) onPressCreateChat;

  /// Callback for when the user wants to navigate back
  final VoidCallback onExit;

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final FocusNode _textFieldFocusNode = FocusNode();
  bool _isSearching = false;
  String query = "";

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;
    var service = chatScope.service;
    var userId = chatScope.userId;

    useEffect(() {
      chatScope.popHandler.add(widget.onExit);
      return () => chatScope.popHandler.remove(widget.onExit);
    });

    if (options.builders.baseScreenBuilder == null) {
      return Scaffold(
        appBar: _AppBar(
          chatOptions: options,
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
          chatOptions: options,
          chatService: service,
          isSearching: _isSearching,
          onPressCreateGroupChat: widget.onPressCreateGroupChat,
          onPressCreateChat: widget.onPressCreateChat,
          userId: userId,
          query: query,
        ),
      );
    }

    return options.builders.baseScreenBuilder!.call(
      context,
      widget.mapScreenType,
      _AppBar(
        chatOptions: options,
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
      _Body(
        chatOptions: options,
        chatService: service,
        isSearching: _isSearching,
        onPressCreateGroupChat: widget.onPressCreateGroupChat,
        onPressCreateChat: widget.onPressCreateChat,
        userId: userId,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.groups_2,
                  ),
                  const SizedBox(
                    width: 8,
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
