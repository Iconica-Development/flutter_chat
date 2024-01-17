// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

mixin ChatUserStoryRoutes {
  static const String chatScreen = '/chat';
  static String chatDetailViewPath(String chatId) => '/chat-detail/$chatId';
  static const String chatDetailScreen = '/chat-detail/:id';
  static const String newChatScreen = '/new-chat';
  static String chatProfileScreenPath(String chatId, String? userId) =>
      '/chat-profile/$chatId/$userId';
  static const String chatProfileScreen = '/chat-profile/:id/:userId';
}
