// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

/// Provides route paths for the chat user story.
mixin ChatUserStoryRoutes {
  static const String chatScreen = '/chat';

  /// Constructs the path for the chat detail view.
  static String chatDetailViewPath(String chatId) => '/chat-detail/$chatId';

  static const String chatDetailScreen = '/chat-detail/:id';
  static const String newChatScreen = '/new-chat';

  /// Constructs the path for the chat profile screen.
  static String chatProfileScreenPath(String chatId, String? userId) =>
      '/chat-profile/$chatId/$userId';

  static const String chatProfileScreen = '/chat-profile/:id/:userId';
}
