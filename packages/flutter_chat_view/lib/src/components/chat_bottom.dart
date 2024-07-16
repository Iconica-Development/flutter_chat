// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:emoji_picker_flutter/emoji_picker_flutter.dart";
import "package:flutter/foundation.dart" as foundation;
import "package:flutter/material.dart";
import "package:flutter_chat_view/flutter_chat_view.dart";
import "package:google_fonts/google_fonts.dart";

class ChatBottom extends StatefulWidget {
  const ChatBottom({
    required this.chat,
    required this.onMessageSubmit,
    required this.messageInputBuilder,
    required this.translations,
    this.onPressSelectImage,
    this.iconColor,
    this.iconDisabledColor,
    super.key,
  });

  /// Callback function invoked when a message is submitted.
  final Future<void> Function(String text) onMessageSubmit;

  /// The builder function for the message input.
  final TextInputBuilder messageInputBuilder;

  /// Callback function invoked when the select image button is pressed.
  final VoidCallback? onPressSelectImage;

  /// The chat model.
  final ChatModel chat;

  /// The translations for the chat.
  final ChatTranslations translations;

  /// The color of the icons.
  final Color? iconColor;
  final Color? iconDisabledColor;

  @override
  State<ChatBottom> createState() => _ChatBottomState();
}

class _ChatBottomState extends State<ChatBottom> {
  bool _isTyping = false;
  bool _isSending = false;
  bool _emojiPickerShowing = false;
  late final EmojiTextEditingController _emojiTextEditingController;
  late final ScrollController _scrollController;
  late final FocusNode _focusNode;
  late final TextStyle _emojiTextStyle;

  final bool isApple = [TargetPlatform.iOS, TargetPlatform.macOS]
      .contains(foundation.defaultTargetPlatform);

  @override
  void initState() {
    var fontSize = 24 * (isApple ? 1.2 : 1.0);
    // Define Custom Emoji Font & Text Style
    _emojiTextStyle = DefaultEmojiTextStyle.copyWith(
      fontFamily: GoogleFonts.notoColorEmoji().fontFamily,
      fontSize: fontSize,
    );

    _emojiTextEditingController = EmojiTextEditingController(emojiTextStyle: _emojiTextStyle);
    _scrollController = ScrollController();
    _focusNode = FocusNode();

    _emojiTextEditingController.addListener(() {
      if (_emojiTextEditingController.text.isEmpty) {
        setState(() {
          _isTyping = false;
        });
      } else {
        setState(() {
          _isTyping = true;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        child: Column(
          children: [
            SizedBox(
              height: 45,
              child: widget.messageInputBuilder(
                _emojiTextEditingController,
                _focusNode,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _emojiPickerShowing = !_emojiPickerShowing;
                          if (!_emojiPickerShowing) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _focusNode.requestFocus();
                            });
                          } else {
                            _focusNode.unfocus();
                          }
                        });
                      },
                      icon: Icon(
                        _emojiPickerShowing
                            ? Icons.keyboard
                            : Icons.emoji_emotions_outlined,
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onPressSelectImage,
                      icon: Icon(
                        Icons.image_outlined,
                        color: widget.iconColor,
                      ),
                    ),
                    IconButton(
                      disabledColor: widget.iconDisabledColor,
                      color: widget.iconColor,
                      onPressed: _isTyping && !_isSending
                          ? () async {
                              setState(() {
                                _isSending = true;
                              });

                              var value = _emojiTextEditingController.text;

                              if (value.isNotEmpty) {
                                await widget.onMessageSubmit(value);
                                _emojiTextEditingController.clear();
                              }

                              setState(() {
                                _isSending = false;
                              });
                            }
                          : null,
                      icon: const Icon(
                        Icons.send,
                      ),
                    ),
                  ],
                ),
                widget.translations,
                context,
              ),
            ),
            Offstage(
              offstage: !_emojiPickerShowing,
              child: EmojiPicker(
                textEditingController: _emojiTextEditingController,
                scrollController: _scrollController,
                config: Config(
                  height: 256,
                  checkPlatformCompatibility: true,
                  emojiTextStyle: _emojiTextStyle,
                  emojiViewConfig: const EmojiViewConfig(
                    backgroundColor: Colors.white,
                  ),
                  swapCategoryAndBottomBar: true,
                  skinToneConfig: const SkinToneConfig(),
                  categoryViewConfig: const CategoryViewConfig(
                    backgroundColor: Colors.white,
                    dividerColor: Colors.white,
                    indicatorColor: Colors.blue,
                    iconColorSelected: Colors.black,
                    iconColor: Color(0xFF8B98A0),
                    categoryIcons: CategoryIcons(
                      recentIcon: Icons.access_time_outlined,
                      smileyIcon: Icons.emoji_emotions_outlined,
                      animalIcon: Icons.cruelty_free_outlined,
                      foodIcon: Icons.coffee_outlined,
                      activityIcon: Icons.sports_soccer_outlined,
                      travelIcon: Icons.directions_car_filled_outlined,
                      objectIcon: Icons.lightbulb_outline,
                      symbolIcon: Icons.emoji_symbols_outlined,
                      flagIcon: Icons.flag_outlined,
                    ),
                  ),
                  bottomActionBarConfig: const BottomActionBarConfig(
                    backgroundColor: Colors.white,
                    buttonColor: Colors.white,
                    buttonIconColor: Color(0xFF8B98A0),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
