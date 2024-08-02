import 'package:flutter/material.dart';
import 'package:flutter_chat/src/config/chat_options.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.chatOptions,
    required this.isSearching,
    required this.onSearch,
    required this.focusNode,
    required this.text,
  });

  final ChatOptions chatOptions;
  final bool isSearching;
  final Function(String query) onSearch;
  final FocusNode focusNode;
  final String text;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var translations = chatOptions.translations;

    return isSearching
        ? TextField(
            focusNode: focusNode,
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: translations.searchPlaceholder,
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
            text,
          );
  }
}
