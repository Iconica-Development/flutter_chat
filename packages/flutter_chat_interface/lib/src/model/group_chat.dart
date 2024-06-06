// ignore_for_file: public_member_api_docs, sort_constructors_first
// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:flutter_chat_interface/flutter_chat_interface.dart";

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

  @override
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
  /// Constructs a [GroupChatModel] instance.
  ///
  /// [id]: The ID of the chat.
  ///
  /// [messages]: The list of messages in the chat.
  ///
  /// [unreadMessages]: The number of unread messages in the chat.
  ///
  /// [lastUsed]: The timestamp when the chat was last used.
  ///
  /// [lastMessage]: The last message sent in the chat.
  ///
  /// [title]: The title of the group chat.
  ///
  /// [imageUrl]: The URL of the image associated with the group chat.
  ///
  /// [users]: The list of users participating in the group chat.
  ///
  /// [canBeDeleted]: Indicates whether the chat can be deleted.
  GroupChatModel({
    required this.canBeDeleted,
    required this.title,
    required this.imageUrl,
    required this.users,
    this.id,
    this.messages,
    this.unreadMessages,
    this.lastUsed,
    this.lastMessage,
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
  }) =>
      GroupChatModel(
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
