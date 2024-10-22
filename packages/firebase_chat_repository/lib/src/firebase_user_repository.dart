import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:cloud_firestore/cloud_firestore.dart";

/// Firebase implementation of a user respository for chats.
class FirebaseUserRepository implements UserRepositoryInterface {
  /// Creates a firebase implementation of a user respository for chats.
  FirebaseUserRepository({
    FirebaseFirestore? firestore,
    String userCollection = "users",
  })  : _userCollection = userCollection,
        _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  final String _userCollection;

  @override
  Stream<List<UserModel>> getAllUsers() =>
      _firestore.collection(_userCollection).snapshots().map(
            (querySnapshot) => querySnapshot.docs
                .map(
                  (doc) => UserModel.fromMap(
                    doc.id,
                    doc.data(),
                  ),
                )
                .toList(),
          );

  @override
  Stream<UserModel> getUser({required String userId}) =>
      _firestore.collection(_userCollection).doc(userId).snapshots().map(
            (snapshot) => UserModel.fromMap(
              snapshot.id,
              snapshot.data()!,
            ),
          );
}
