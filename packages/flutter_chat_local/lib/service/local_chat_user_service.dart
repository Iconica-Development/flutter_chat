import 'package:flutter_chat_interface/flutter_chat_interface.dart';

class LocalChatUserService implements ChatUserService {
  List<ChatUserModel> users = [
    ChatUserModel(
      id: '1',
      firstName: 'John',
      lastName: 'Doe',
      imageUrl: 'https://picsum.photos/200/300',
    ),
    ChatUserModel(
      id: '2',
      firstName: 'Jane',
      lastName: 'Doe',
      imageUrl: 'https://picsum.photos/200/300',
    ),
    ChatUserModel(
      id: '3',
      firstName: 'ico',
      lastName: 'nica',
      imageUrl: 'https://picsum.photos/100/200',
    ),
  ];
  @override
  Future<List<ChatUserModel>> get getAllUsers =>
      Future.value(users.where((element) => element.id != '3').toList());

  @override
  Future<ChatUserModel?> getCurrentUser() => Future.value(ChatUserModel());

  @override
  Future<ChatUserModel?> getUser(String id) {
    var user = users.firstWhere((element) => element.id == id);
    return Future.value(user);
  }
}
