// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_chat_view/flutter_chat_view.dart";
import "package:flutter_chat_view/src/components/image_picker_popup.dart";

class NewGroupChatOverviewScreen extends StatefulWidget {
  const NewGroupChatOverviewScreen({
    required this.options,
    required this.onPressCompleteGroupChatCreation,
    required this.service,
    this.translations = const ChatTranslations.empty(),
    super.key,
  });

  final ChatOptions options;
  final ChatTranslations translations;
  final ChatService service;
  final Function(
    List<ChatUserModel> users,
    String groupchatName,
    String? groupchatBio,
    Uint8List? imageBytes,
  ) onPressCompleteGroupChatCreation;

  @override
  State<NewGroupChatOverviewScreen> createState() =>
      _NewGroupChatOverviewScreenState();
}

class _NewGroupChatOverviewScreenState
    extends State<NewGroupChatOverviewScreen> {
  final TextEditingController _chatNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  Uint8List? image;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var formKey = GlobalKey<FormState>();
    var isPressed = false;
    var users = widget.service.chatOverviewService.currentlySelectedUsers;

    void onUploadImage(groupImage) {
      setState(() {
        image = groupImage;
      });
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: theme.appBarTheme.iconTheme ??
            const IconThemeData(color: Colors.white),
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          widget.translations.newGroupChatTitle,
          style: theme.appBarTheme.titleTextStyle,
        ),
      ),
      body: Stack(
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
                          GestureDetector(
                            onTap: () async {
                              await onPressSelectImage(
                                context,
                                widget.translations,
                                widget.options,
                                onUploadImage,
                              );
                            },
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
                              child: image == null
                                  ? const Icon(Icons.image)
                                  : null,
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
                                  child: GestureDetector(
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
                      widget.translations.groupChatNameFieldHeader,
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
                        hintText: widget.translations.groupNameHintText,
                        hintStyle: theme.textTheme.bodyMedium!.copyWith(
                          color: theme.textTheme.bodyMedium!.color!
                              .withOpacity(0.5),
                        ),
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
                          return widget.translations.groupNameValidatorEmpty;
                        }
                        if (value.length > 15)
                          return widget.translations.groupNameValidatorTooLong;
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      widget.translations.groupBioFieldHeader,
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
                        hintText: widget.translations.groupBioHintText,
                        hintStyle: theme.textTheme.bodyMedium!.copyWith(
                          color: theme.textTheme.bodyMedium!.color!
                              .withOpacity(0.5),
                        ),
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
                          return widget.translations.groupBioValidatorEmpty;
                        }

                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      "${widget.translations.selectedMembersHeader}"
                      "${users.length}",
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Wrap(
                      children: [
                        ...users.map(
                          _selectedUser,
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
              child: FilledButton(
                onPressed: users.isNotEmpty
                    ? () async {
                        if (!isPressed) {
                          isPressed = true;
                          if (formKey.currentState!.validate()) {
                            await widget.onPressCompleteGroupChatCreation(
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
                      widget.translations.createGroupChatButton,
                      style: theme.textTheme.displayLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
    );
  }

  Widget _selectedUser(ChatUserModel user) => GestureDetector(
        onTap: () {
          setState(() {
            widget.service.chatOverviewService
                .removeCurrentlySelectedUser(user);
          });
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: widget.options.userAvatarBuilder(
                user,
                40,
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
