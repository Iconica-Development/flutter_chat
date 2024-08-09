import "package:flutter/material.dart";
import "package:flutter_chat/src/config/chat_options.dart";

/// The search field widget
class SearchField extends StatelessWidget {
  /// Constructs a [SearchField]
  const SearchField({
    required this.chatOptions,
    required this.isSearching,
    required this.onSearch,
    required this.focusNode,
    required this.text,
    super.key,
  });

  /// The chat options
  final ChatOptions chatOptions;

  /// Whether the search field is currently in use
  final bool isSearching;

  /// Callback function triggered when the search field is used
  final Function(String query) onSearch;

  /// The focus node of the search field
  final FocusNode focusNode;

  /// The text to display in the search field
  final String text;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var translations = chatOptions.translations;

    if (isSearching) {
      return TextField(
        focusNode: focusNode,
        onChanged: onSearch,
        decoration: InputDecoration(
          hintText: translations.searchPlaceholder,
          hintStyle: theme.textTheme.bodyMedium,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        style: theme.textTheme.bodySmall,
        cursorColor: theme.textSelectionTheme.cursorColor ?? Colors.white,
      );
    }

    return Text(
      text,
    );
  }
}
