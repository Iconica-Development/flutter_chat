import 'package:flutter/material.dart';
import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';
import 'package:flutter_community_chat_view/flutter_community_chat_view.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({
    required this.chatOptions,
    required this.users,
    required this.onPressCreateChat,
    super.key,
  });

  final ChatOptions chatOptions;
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
                  (user) =>
                      user.name != null &&
                      user.name!.toLowerCase().contains(
                            query.toLowerCase(),
                          ),
                )
                .toList(),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    focusNode: _textFieldFocusNode,
                    onChanged: filterUsers,
                    decoration: const InputDecoration(
                      hintText: 'Zoeken...',
                    ),
                  ),
                )
              : const Text('Start een chat'),
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
        body: ListView(
          children: [
            for (var user in _filteredUsers ?? widget.users)
              GestureDetector(
                child: widget.chatOptions.chatRowContainerBuilder(
                  ChatRow(
                    image: user.imageUrl,
                    title: user.name ?? '',
                  ),
                ),
                onTap: () {
                  widget.onPressCreateChat(user);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      );
}
