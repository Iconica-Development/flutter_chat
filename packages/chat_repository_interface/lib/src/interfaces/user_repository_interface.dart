import "package:chat_repository_interface/src/models/user_model.dart";

/// The user repository interface
/// Implement this interface to create a user
/// repository with a given data source.
abstract class UserRepositoryInterface {
  /// Get the user with the given [userId].
  /// Returns a [UserModel] stream.
  Stream<UserModel> getUser({required String userId});

  /// Get all the users.
  /// Returns a list of [UserModel] stream.
  Stream<List<UserModel>> getAllUsers();

  /// Get all the users for the given [chatId].
  /// Returns a list of [UserModel] stream.
  Stream<List<UserModel>> getAllUsersForChat({required String chatId});
}
