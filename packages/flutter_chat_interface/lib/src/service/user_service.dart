import 'package:flutter_chat_interface/flutter_chat_interface.dart';

abstract class ChatUserService {
  /// Retrieves a user based on the ID.
  Future<ChatUserModel?> getUser(String id);

  /// Retrieves the current user.
  /// This is the user that is currently logged in.
  Future<ChatUserModel?> getCurrentUser();

  /// Retrieves all users. Used for chat creation.
  Future<List<ChatUserModel>> getAllUsers();
}
