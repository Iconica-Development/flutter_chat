/// The chat model
/// A model that represents a chat.
/// [id] is the chat id.
/// [users] is a list of [UserModel] that are part of the chat.
/// [chatName] is the name of the chat.
/// [description] is the description of the chat.
/// [imageUrl] is the image url of the chat.
/// [canBeDeleted] is a boolean that indicates if the chat can be deleted.
/// [lastUsed] is the last time the chat was used.
/// [lastMessage] is the last message of the chat.
/// [unreadMessageCount] is the number of unread messages in the chat.
/// Returns a [ChatModel] instance.
class ChatModel {
  /// The chat model constructor
  const ChatModel({
    required this.id,
    required this.users,
    required this.isGroupChat,
    this.chatName,
    this.description,
    this.imageUrl,
    this.canBeDeleted = true,
    this.lastUsed,
    this.lastMessage,
    this.unreadMessageCount = 0,
  });

  /// The chat id
  final String id;

  /// The chat users
  final List<String> users;

  /// The chat name
  final String? chatName;

  /// The chat description
  final String? description;

  /// The chat image url
  final String? imageUrl;

  /// A boolean that indicates if the chat can be deleted
  final bool canBeDeleted;

  /// The last time the chat was used
  final DateTime? lastUsed;

  /// The last message of the chat
  final String? lastMessage;

  /// The number of unread messages in the chat
  final int unreadMessageCount;

  /// A boolean that indicates if the chat is a group chat
  final bool isGroupChat;

  /// The chat model copy with method
  ChatModel copyWith({
    String? id,
    List<String>? users,
    String? chatName,
    String? description,
    String? imageUrl,
    bool? canBeDeleted,
    DateTime? lastUsed,
    String? lastMessage,
    int? unreadMessageCount,
    bool? isGroupChat,
  }) =>
      ChatModel(
        id: id ?? this.id,
        users: users ?? this.users,
        chatName: chatName ?? this.chatName,
        isGroupChat: isGroupChat ?? this.isGroupChat,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        canBeDeleted: canBeDeleted ?? this.canBeDeleted,
        lastUsed: lastUsed ?? this.lastUsed,
        lastMessage: lastMessage ?? this.lastMessage,
        unreadMessageCount: unreadMessageCount ?? this.unreadMessageCount,
      );
}

/// The chat model extension
/// An extension that adds extra functionality to the chat model.
/// [getOtherUser] is a method that returns the other user in the chat.
extension GetOtherUser on ChatModel {
  /// The get other user method
  String getOtherUser(String userId) =>
      users.firstWhere((user) => user != userId);
}
