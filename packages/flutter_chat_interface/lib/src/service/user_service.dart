import 'package:flutter_chat_interface/flutter_chat_interface.dart';

abstract class ChatUserService {
  Future<ChatUserModel?> getUser(String id);
  Future<ChatUserModel?> getCurrentUser();
  Future<List<ChatUserModel>> get getAllUsers;
}
