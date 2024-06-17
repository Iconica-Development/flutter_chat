import "package:flutter_chat_interface/flutter_chat_interface.dart";

/// Service class for managing local chat users.
class LocalChatUserService implements ChatUserService {
  /// List of predefined chat users.
  List<ChatUserModel> users = [
    const ChatUserModel(
      id: "1",
      firstName: "John",
      lastName: "Doe",
      imageUrl: "https://picsum.photos/200/300",
    ),
    const ChatUserModel(
      id: "2",
      firstName: "Jane",
      lastName: "Doe",
      imageUrl: "https://picsum.photos/200/300",
    ),
    const ChatUserModel(
      id: "3",
      firstName: "ico",
      lastName: "nica",
      imageUrl: "https://picsum.photos/100/200",
    ),
  ];

  @override
  Future<List<ChatUserModel>> getAllUsers() =>
      Future.value(users.where((element) => element.id != "3").toList());

  @override
  Future<ChatUserModel?> getCurrentUser() =>
      Future.value(const ChatUserModel());

  @override
  Future<ChatUserModel?> getUser(String id) {
    var user = users.firstWhere((element) => element.id == id);
    return Future.value(user);
  }
}
