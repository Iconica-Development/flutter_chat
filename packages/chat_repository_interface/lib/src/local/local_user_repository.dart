import "dart:async";

import "package:chat_repository_interface/src/interfaces/user_repository_interface.dart";
import "package:chat_repository_interface/src/models/user_model.dart";
import "package:rxdart/rxdart.dart";

/// The local user repository
class LocalUserRepository implements UserRepositoryInterface {
  final StreamController<List<UserModel>> _usersController =
      BehaviorSubject<List<UserModel>>();

  final List<UserModel> _users = [
    UserModel(
      id: "1",
      firstName: "John",
      lastName: "Doe",
      imageUrl: "https://picsum.photos/200/300",
    ),
    UserModel(
      id: "2",
      firstName: "Jane",
      lastName: "Doe",
      imageUrl: "https://picsum.photos/200/300",
    ),
    UserModel(
      id: "3",
      firstName: "Frans",
      lastName: "Timmermans",
      imageUrl: "https://picsum.photos/200/300",
    ),
    UserModel(
      id: "4",
      firstName: "Hendrik-Jan",
      lastName: "De derde",
      imageUrl: "https://picsum.photos/200/300",
    ),
  ];

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
    _usersController.add(_users);

    return _usersController.stream;
  }
}
