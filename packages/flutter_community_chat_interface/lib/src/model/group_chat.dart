// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';

class GroupChatModel extends ChatModel {
  GroupChatModel({
    required this.title,
    required this.imageUrl,
    required this.users,
    super.id,
    super.messages,
    super.lastUsed,
    super.lastMessage,
  });

  final String title;
  final String imageUrl;
  final List<ChatUserModel> users;
}
