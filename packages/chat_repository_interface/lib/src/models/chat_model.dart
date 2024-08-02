import 'package:chat_repository_interface/src/models/message_model.dart';
import 'package:chat_repository_interface/src/models/user_model.dart';

class ChatModel {
  ChatModel({
    required this.id,
    required this.users,
    required this.messages,
    this.chatName,
    this.description,
    this.imageUrl,
    this.canBeDeleted = true,
    this.lastUsed,
    this.lastMessage,
    this.unreadMessageCount = 0,
  });

  final String id;
  final List<MessageModel> messages;
  final List<UserModel> users;
  final String? chatName;
  final String? description;
  final String? imageUrl;

  final bool canBeDeleted;
  final DateTime? lastUsed;
  final MessageModel? lastMessage;
  final int unreadMessageCount;

  ChatModel copyWith({
    String? id,
    List<MessageModel>? messages,
    List<UserModel>? users,
    String? chatName,
    String? description,
    String? imageUrl,
    bool? canBeDeleted,
    DateTime? lastUsed,
    MessageModel? lastMessage,
    int? unreadMessageCount,
  }) {
    return ChatModel(
      id: id ?? this.id,
      messages: messages ?? this.messages,
      users: users ?? this.users,
      chatName: chatName ?? this.chatName,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      canBeDeleted: canBeDeleted ?? this.canBeDeleted,
      lastUsed: lastUsed ?? this.lastUsed,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadMessageCount: unreadMessageCount ?? this.unreadMessageCount,
    );
  }
}

extension IsGroupChat on ChatModel {
  bool get isGroupChat => users.length > 2;
}

extension GetOtherUser on ChatModel {
  UserModel getOtherUser(String userId) {
    return users.firstWhere((user) => user.id != userId);
  }
}
