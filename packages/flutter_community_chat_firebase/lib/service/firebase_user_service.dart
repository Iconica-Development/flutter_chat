import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_community_chat_firebase/config/firebase_chat_options.dart';
import 'package:flutter_community_chat_firebase/dto/firebase_chat_document.dart';
import 'package:flutter_community_chat_firebase/dto/firebase_user_document.dart';
import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';

class FirebaseUserService {
  FirebaseUserService({
    required this.db,
    required this.auth,
    required this.options,
  });

  FirebaseFirestore db;
  FirebaseAuth auth;
  FirebaseChatOptoons options;

  ChatUserModel? _currentUser;
  final Map<String, ChatUserModel> _users = {};

  CollectionReference<FirebaseUserDocument> get _userCollection => db
      .collection(options.usersCollectionName)
      .withConverter<FirebaseUserDocument>(
        fromFirestore: (snapshot, _) => FirebaseUserDocument.fromJson(
          snapshot.data()!,
          snapshot.id,
        ),
        toFirestore: (user, _) => user.toJson(),
      );

  CollectionReference<FirebaseChatDocument> get _chatsCollection => db
      .collection(options.chatsCollectionName)
      .withConverter<FirebaseChatDocument>(
        fromFirestore: (snapshot, _) => FirebaseChatDocument.fromJson(
          snapshot.data()!,
          snapshot.id,
        ),
        toFirestore: (chat, _) => chat.toJson(),
      );

  Future<ChatUserModel?> getUser(String id) async {
    if (_users.containsKey(id)) {
      return _users[id]!;
    }

    return _userCollection.doc(id).get().then((response) {
      var data = response.data();

      var user = data == null
          ? ChatUserModel(id: id)
          : ChatUserModel(
              id: id,
              name: '${data.firstName} ${data.lastName}',
              imageUrl: data.imageUrl,
            );

      _users[id] = user;

      return user;
    });
  }

  Future<ChatUserModel?> getCurrentUser() async {
    return _currentUser == null && auth.currentUser?.uid != null
        ? _currentUser = await getUser(auth.currentUser!.uid)
        : _currentUser;
  }

  Future<List<ChatUserModel>> getNewUsers() async {
    var currentUser = await getCurrentUser();
    var existingUserIds = [];

    var existingChatCollection = await db
        .collection(options.usersCollectionName)
        .doc(currentUser?.id)
        .collection('chats')
        .get();

    var existingChatsIds =
        existingChatCollection.docs.map((chat) => chat['id']).toList();

    if (existingChatsIds.isNotEmpty) {
      for (var existingChatsId in existingChatsIds) {
        var existingChat = await _chatsCollection.doc(existingChatsId).get();
        var existingChatData = existingChat.data();

        if (existingChatData != null) {
          existingUserIds.addAll(
            existingChatData.users,
          );
        }
      }
    }

    var data = await _userCollection.get();

    return data.docs
        .where(
      (user) =>
          user.id != currentUser?.id && !existingUserIds.contains(user.id),
    )
        .map((user) {
      var userData = user.data();
      return ChatUserModel(
        id: user.id,
        name: '${userData.firstName} ${userData.lastName}',
        imageUrl: userData.imageUrl,
      );
    }).toList();
  }
}
