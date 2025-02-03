import "package:flutter/material.dart";

/// Default chat loading overlay
/// This is displayed over the chat when loading
class DefaultChatLoadingOverlay extends StatelessWidget {
  /// Creates a new default chat loading overlay
  const DefaultChatLoadingOverlay({super.key});

  /// Builds the default chat loading overlay
  static Widget builder(BuildContext context) =>
      const DefaultChatLoadingOverlay();

  @override
  Widget build(BuildContext context) => const Column(
        children: [
          SizedBox(height: 12),
          Center(child: CircularProgressIndicator()),
          SizedBox(height: 12),
        ],
      );
}
