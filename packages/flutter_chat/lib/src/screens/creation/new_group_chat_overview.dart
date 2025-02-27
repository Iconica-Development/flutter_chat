import "dart:typed_data";

import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_accessibility/flutter_accessibility.dart";
import "package:flutter_chat/src/config/screen_types.dart";
import "package:flutter_chat/src/screens/creation/widgets/default_image_picker.dart";
import "package:flutter_chat/src/util/scope.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:flutter_profile/flutter_profile.dart";

/// New group chat overview
/// Seen after the user has selected the users they
/// want to add to the group chat
class NewGroupChatOverview extends HookWidget {
  /// Constructs a [NewGroupChatOverview]
  const NewGroupChatOverview({
    required this.onExit,
    required this.users,
    required this.onComplete,
    super.key,
  });

  /// The users to be added to the group chat
  final List<UserModel> users;

  /// Callback for when the user wants to navigate back
  final VoidCallback onExit;

  /// Callback function triggered when the group chat is created
  final Function(
    List<UserModel> users,
    String chatName,
    String description,
    Uint8List? image,
  ) onComplete;

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;

    useEffect(() {
      chatScope.popHandler.add(onExit);
      return () => chatScope.popHandler.remove(onExit);
    });

    if (options.builders.baseScreenBuilder == null) {
      return Scaffold(
        appBar: const _AppBar(),
        body: _Body(
          users: users,
          onComplete: onComplete,
        ),
      );
    }

    return options.builders.baseScreenBuilder!.call(
      context,
      mapScreenType,
      const _AppBar(),
      options.translations.newGroupChatTitle,
      _Body(
        users: users,
        onComplete: onComplete,
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;
    var theme = Theme.of(context);
    return AppBar(
      iconTheme: theme.appBarTheme.iconTheme ??
          const IconThemeData(color: Colors.white),
      backgroundColor: theme.appBarTheme.backgroundColor,
      title: Text(
        options.translations.newGroupChatTitle,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _Body extends StatefulWidget {
  const _Body({
    required this.users,
    required this.onComplete,
  });

  final List<UserModel> users;
  final Function(
    List<UserModel> users,
    String chatName,
    String description,
    Uint8List? image,
  ) onComplete;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final TextEditingController _chatNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final ValueNotifier<bool> isButtonEnabled = ValueNotifier<bool>(false);
  Uint8List? image;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isPressed = false;

  List<UserModel> users = <UserModel>[];

  @override
  void initState() {
    users = widget.users;
    super.initState();
    _chatNameController.addListener(() {
      isButtonEnabled.value = _chatNameController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _chatNameController.dispose();
    _bioController.dispose();
    isButtonEnabled.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;
    var theme = Theme.of(context);
    var translations = options.translations;
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: Stack(
                      children: [
                        InkWell(
                          onTap: () async => onPressSelectImage(
                            context,
                            options,
                            (image) {
                              setState(() {
                                this.image = image;
                              });
                            },
                          ),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(40),
                              image: image != null
                                  ? DecorationImage(
                                      image: MemoryImage(image!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child:
                                image == null ? const Icon(Icons.image) : null,
                          ),
                        ),
                        if (image != null)
                          Positioned.directional(
                            textDirection: Directionality.of(context),
                            end: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFFBCBCBC),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Center(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      image = null;
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Text(
                    translations.groupChatNameFieldHeader,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    style: theme.textTheme.bodySmall,
                    controller: _chatNameController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      hintText: translations.groupNameHintText,
                      hintStyle: theme.textTheme.bodyMedium,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return translations.groupNameValidatorEmpty;
                      }
                      if (value.length > 15) {
                        return translations.groupNameValidatorTooLong;
                      }

                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    translations.groupBioFieldHeader,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    style: theme.textTheme.bodySmall,
                    controller: _bioController,
                    minLines: null,
                    maxLines: 5,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      hintText: translations.groupBioHintText,
                      hintStyle: theme.textTheme.bodyMedium,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return translations.groupBioValidatorEmpty;
                      }

                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  CustomSemantics(
                    identifier: options.semantics.newGroupChatMemberAmount,
                    value: "${translations.selectedMembersHeader}"
                        "${users.length}",
                    child: Text(
                      "${translations.selectedMembersHeader}"
                      "${users.length}",
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Wrap(
                    children: [
                      ...users.map(
                        (e) => _SelectedUser(
                          user: e,
                          onRemove: (user) {
                            setState(() {
                              users.remove(user);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 80,
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 24,
              horizontal: 80,
            ),
            child: ValueListenableBuilder(
              valueListenable: isButtonEnabled,
              builder: (context, isEnabled, child) => FilledButton(
                onPressed: users.isNotEmpty
                    ? () async {
                        if (!isPressed) {
                          isPressed = true;
                          if (formKey.currentState!.validate()) {
                            await widget.onComplete(
                              users,
                              _chatNameController.text,
                              _bioController.text,
                              image,
                            );
                          }
                          isPressed = false;
                        }
                      }
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      translations.createGroupChatButton,
                      style: theme.textTheme.displayLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectedUser extends StatelessWidget {
  const _SelectedUser({
    required this.user,
    required this.onRemove,
  });

  final UserModel user;
  final Function(UserModel) onRemove;

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;
    return InkWell(
      onTap: () {
        onRemove(user);
      },
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: options.builders.userAvatarBuilder?.call(
                  context,
                  user,
                  40,
                ) ??
                Avatar(
                  boxfit: BoxFit.cover,
                  user: User(
                    firstName: user.firstName,
                    lastName: user.lastName,
                    imageUrl: user.imageUrl != "" ? user.imageUrl : null,
                  ),
                  size: 40,
                ),
          ),
          Positioned.directional(
            textDirection: Directionality.of(context),
            end: 0,
            child: const Icon(
              Icons.cancel,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
