// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

mixin CommunityChatUserStoryRoutes {
  static const String chatScreen = '/chat';
  static String chatDetailViewPath(String chatId) => '/chat-detail/$chatId';
  static const String chatDetailScreen = '/chat-detail/:id';
  static const String newChatScreen = '/new-chat';
}
