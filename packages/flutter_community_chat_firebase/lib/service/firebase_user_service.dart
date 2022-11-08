// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_community_chat_firebase/config/firebase_chat_options.dart';
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

  Future<ChatUserModel?> getCurrentUser() async =>
      _currentUser == null && auth.currentUser?.uid != null
          ? _currentUser = await getUser(auth.currentUser!.uid)
          : _currentUser;

  Future<List<ChatUserModel>> getAllUsers() async {
    var currentUser = await getCurrentUser();

    var data = await _userCollection.get();

    return data.docs.where((user) => user.id != currentUser?.id).map((user) {
      var userData = user.data();
      return ChatUserModel(
        id: user.id,
        name: '${userData.firstName} ${userData.lastName}',
        imageUrl: userData.imageUrl,
      );
    }).toList();
  }
}
