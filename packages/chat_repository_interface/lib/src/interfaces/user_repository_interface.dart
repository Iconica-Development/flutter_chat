import 'package:chat_repository_interface/src/models/user_model.dart';

abstract class UserRepositoryInterface {
  Stream<UserModel> getUser({required String userId});

  Stream<List<UserModel>> getAllUsers();
}
