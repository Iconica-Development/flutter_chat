import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class FirebaseUserRepository implements UserRepositoryInterface {
  FirebaseUserRepository({
    FirebaseFirestore? firestore,
    this.userCollection = "users",
  }) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  final String userCollection;

  @override
  Stream<List<UserModel>> getAllUsers() =>
      _firestore.collection(userCollection).snapshots().map(
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
      _firestore.collection(userCollection).doc(userId).snapshots().map(
            (snapshot) => UserModel.fromMap(
              snapshot.id,
              snapshot.data()!,
            ),
          );
}
