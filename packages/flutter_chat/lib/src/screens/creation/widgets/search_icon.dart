import "package:flutter/material.dart";

/// A widget representing a search icon.
class SearchIcon extends StatelessWidget {
  /// Constructs a [SearchIcon].
  const SearchIcon({
    required this.isSearching,
    required this.onPressed,
    required this.semanticId,
    super.key,
  });

  /// Whether the search icon is currently in use
  final bool isSearching;

  /// Callback function triggered when the search icon is pressed
  final VoidCallback onPressed;

  /// Semantic id for icon button
  final String semanticId;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Semantics(
      identifier: semanticId,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          isSearching ? Icons.close : Icons.search,
          color: theme.appBarTheme.iconTheme?.color ?? Colors.white,
        ),
      ),
    );
  }
}
