import "dart:async";

import "package:chat_repository_interface/src/interfaces/user_repository_interface.dart";
import "package:chat_repository_interface/src/local/local_memory_db.dart";
import "package:chat_repository_interface/src/models/user_model.dart";
import "package:rxdart/rxdart.dart";

/// The local user repository
class LocalUserRepository implements UserRepositoryInterface {
  final StreamController<List<UserModel>> _usersController =
      BehaviorSubject<List<UserModel>>();

  @override
  Stream<UserModel> getUser({
    required String userId,
  }) =>
      getAllUsers().map(
        (users) => users.firstWhere(
          (e) => e.id == userId,
          orElse: () => throw Exception(),
        ),
      );

  @override
  Stream<List<UserModel>> getAllUsers() {
    _usersController.add(users);

    return _usersController.stream;
  }

  @override
  Stream<List<UserModel>> getAllUsersForChat({
    required String chatId,
  }) =>
      Stream.value(
        chats
            .firstWhere(
              (chat) => chat.id == chatId,
              orElse: () => throw Exception("Chat not found"),
            )
            .users
            .map(
              (userId) => users.firstWhere(
                (user) => user.id == userId,
                orElse: () => throw Exception("User not found"),
              ),
            )
            .toList(),
      );
}
