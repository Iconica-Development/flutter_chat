import "package:flutter/material.dart";
import "package:flutter_chat/flutter_chat.dart";

/// The default layout for a chat indicator
class DefaultChatTimeIndicator extends StatelessWidget {
  /// Create a default timeindicator in a chat
  const DefaultChatTimeIndicator({
    required this.timeIndicatorString,
    super.key,
  });

  /// The text shown in the time indicator
  final String timeIndicatorString;

  /// Standard builder for time indication
  static Widget builder(BuildContext context, String timeIndicatorString) =>
      DefaultChatTimeIndicator(timeIndicatorString: timeIndicatorString);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var spacing = ChatScope.of(context).options.spacing;
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: spacing.chatBetweenMessagesPadding),
        padding: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: Text(
          timeIndicatorString,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
