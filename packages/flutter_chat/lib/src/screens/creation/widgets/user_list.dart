import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_chat/src/config/chat_options.dart";
import "package:flutter_profile/flutter_profile.dart";

/// The user list widget
class UserList extends StatefulWidget {
  /// Constructs a [UserList]
  const UserList({
    required this.users,
    required this.currentUser,
    required this.query,
    required this.options,
    required this.onPressCreateChat,
    this.creatingGroup = false,
    this.selectedUsers = const [],
    this.onSelectedUser,
    super.key,
  });

  /// The list of users
  final List<UserModel> users;

  /// The query to search for
  final String query;

  /// The current user
  final String currentUser;

  /// The chat options
  final ChatOptions options;

  /// Whether the user is creating a group
  final bool creatingGroup;

  /// Callback function triggered when a chat is created
  final Function(UserModel)? onPressCreateChat;

  /// The selected users
  final List<UserModel> selectedUsers;

  /// Callback function triggered when a user is selected
  final Function(UserModel)? onSelectedUser;

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<UserModel> users = [];
  List<UserModel> filteredUsers = [];
  bool isPressed = false;

  @override
  void initState() {
    super.initState();
    users = List.from(widget.users);
    users.removeWhere((user) => user.id == widget.currentUser);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var translations = widget.options.translations;
    filteredUsers = users
        .where(
          (user) =>
              user.fullname?.toLowerCase().contains(
                    widget.query.toLowerCase(),
                  ) ??
              false,
        )
        .toList();
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 80),
      child: ListView.builder(
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          var user = filteredUsers[index];
          var isSelected = widget.selectedUsers.any((u) => u.id == user.id);

          return InkWell(
            onTap: () async {
              if (widget.creatingGroup) {
                return handleGroupChatTap(user);
              } else {
                return handlePersonalChatTap(user);
              }
            },
            child: widget.options.builders.chatRowContainerBuilder?.call(
                  context,
                  Row(
                    children: [
                      widget.options.builders.userAvatarBuilder
                              ?.call(context, user, 44) ??
                          Avatar(
                            boxfit: BoxFit.cover,
                            user: User(
                              firstName: user.firstName,
                              lastName: user.lastName,
                              imageUrl:
                                  user.imageUrl != "" ? user.imageUrl : null,
                            ),
                            size: 44,
                          ),
                      const SizedBox(
                        width: 12,
                      ),
                      Text(
                        user.fullname ?? translations.anonymousUser,
                        style: theme.textTheme.titleMedium,
                      ),
                      if (widget.creatingGroup) ...[
                        const Spacer(),
                        Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            handleGroupChatTap(user);
                          },
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                      ],
                    ],
                  ),
                ) ??
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border(
                      bottom: BorderSide(
                        color: theme.dividerColor,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        widget.options.builders.userAvatarBuilder
                                ?.call(context, user, 44) ??
                            Avatar(
                              boxfit: BoxFit.cover,
                              user: User(
                                firstName: user.firstName,
                                lastName: user.lastName,
                                imageUrl:
                                    user.imageUrl != "" ? user.imageUrl : null,
                              ),
                              size: 44,
                            ),
                        const SizedBox(
                          width: 12,
                        ),
                        Text(
                          user.fullname ?? translations.anonymousUser,
                          style: theme.textTheme.titleMedium,
                        ),
                        if (widget.creatingGroup) ...[
                          const Spacer(),
                          Checkbox(
                            value: isSelected,
                            onChanged: (value) {
                              handleGroupChatTap(user);
                            },
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
          );
        },
      ),
    );
  }

  Future<void> handlePersonalChatTap(UserModel user) async {
    if (!isPressed) {
      setState(() {
        isPressed = true;
      });

      await widget.onPressCreateChat?.call(user);

      setState(() {
        isPressed = false;
      });
    }
  }

  void handleGroupChatTap(UserModel user) {
    widget.onSelectedUser?.call(user);
  }
}
