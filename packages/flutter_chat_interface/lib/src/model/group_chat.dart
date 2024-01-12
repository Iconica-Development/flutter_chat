// ignore_for_file: public_member_api_docs, sort_constructors_first
// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter_chat_interface/flutter_chat_interface.dart';

abstract class GroupChatModelInterface extends ChatModel {
  GroupChatModelInterface({
    super.id,
    super.messages,
    super.lastUsed,
    super.lastMessage,
    super.unreadMessages,
    super.canBeDeleted,
  });

  String get title;
  String get imageUrl;
  List<ChatUserModel> get users;

  GroupChatModelInterface copyWith({
    String? id,
    List<ChatMessageModel>? messages,
    int? unreadMessages,
    DateTime? lastUsed,
    ChatMessageModel? lastMessage,
    String? title,
    String? imageUrl,
    List<ChatUserModel>? users,
    bool? canBeDeleted,
  });
}

class GroupChatModel implements GroupChatModelInterface {
  GroupChatModel({
    this.id,
    this.messages,
    this.unreadMessages,
    this.lastUsed,
    this.lastMessage,
    required this.canBeDeleted,
    required this.title,
    required this.imageUrl,
    required this.users,
  });

  @override
  String? id;
  @override
  final List<ChatMessageModel>? messages;
  @override
  final int? unreadMessages;
  @override
  final DateTime? lastUsed;
  @override
  final ChatMessageModel? lastMessage;
  @override
  final bool canBeDeleted;
  @override
  final String title;
  @override
  final String imageUrl;
  @override
  final List<ChatUserModel> users;

  @override
  GroupChatModel copyWith({
    String? id,
    List<ChatMessageModel>? messages,
    int? unreadMessages,
    DateTime? lastUsed,
    ChatMessageModel? lastMessage,
    bool? canBeDeleted,
    String? title,
    String? imageUrl,
    List<ChatUserModel>? users,
  }) {
    return GroupChatModel(
      id: id ?? this.id,
      messages: messages ?? this.messages,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      lastUsed: lastUsed ?? this.lastUsed,
      lastMessage: lastMessage ?? this.lastMessage,
      canBeDeleted: canBeDeleted ?? this.canBeDeleted,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      users: users ?? this.users,
    );
  }
}
