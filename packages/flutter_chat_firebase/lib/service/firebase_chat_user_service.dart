// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter_chat_firebase/config/firebase_chat_options.dart";
import "package:flutter_chat_firebase/dto/firebase_user_document.dart";
import "package:flutter_chat_interface/flutter_chat_interface.dart";

/// Service class for managing chat users using Firebase.
class FirebaseChatUserService implements ChatUserService {
  /// Constructor for FirebaseChatUserService.
  ///
  /// [app]: The Firebase app instance.
  /// [options]: The options for configuring Firebase Chat.
  FirebaseChatUserService({
    FirebaseApp? app,
    FirebaseChatOptions? options,
  }) {
    var appInstance = app ?? Firebase.app();

    _db = FirebaseFirestore.instanceFor(app: appInstance);
    _auth = FirebaseAuth.instanceFor(app: appInstance);
    _options = options ?? const FirebaseChatOptions();
  }

  /// The Firebase Firestore instance.
  late FirebaseFirestore _db;

  /// The Firebase Authentication instance.
  late FirebaseAuth _auth;

  /// The options for configuring Firebase Chat.
  late FirebaseChatOptions _options;

  /// The current user.
  ChatUserModel? _currentUser;

  /// Map to cache user models.
  final Map<String, ChatUserModel> _users = {};

  /// Collection reference for users.
  CollectionReference<FirebaseUserDocument> get _userCollection => _db
      .collection(_options.usersCollectionName)
      .withConverter<FirebaseUserDocument>(
        fromFirestore: (snapshot, _) => FirebaseUserDocument.fromJson(
          snapshot.data()!,
          snapshot.id,
        ),
        toFirestore: (user, _) => user.toJson(),
      );

  @override
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
              firstName: data.firstName,
              lastName: data.lastName,
              imageUrl: data.imageUrl,
            );

      _users[id] = user;

      return user;
    });
  }

  @override
  Future<ChatUserModel?> getCurrentUser() async =>
      _currentUser == null && _auth.currentUser?.uid != null
          ? _currentUser = await getUser(_auth.currentUser!.uid)
          : _currentUser;

  @override
  Future<List<ChatUserModel>> getAllUsers() async {
    var currentUser = await getCurrentUser();

    var query = _userCollection.where(
      FieldPath.documentId,
      isNotEqualTo: currentUser?.id,
    );

    var data = await query.get();

    return data.docs.map((user) {
      var userData = user.data();
      return ChatUserModel(
        id: user.id,
        firstName: userData.firstName,
        lastName: userData.lastName,
        imageUrl: userData.imageUrl,
      );
    }).toList();
  }
}
