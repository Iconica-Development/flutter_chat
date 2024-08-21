import 'package:chat_repository_interface/chat_repository_interface.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUserRepository implements UserRepositoryInterface {
  final FirebaseFirestore _firestore;
  final String userCollection;

  FirebaseUserRepository({
    FirebaseFirestore? firestore,
    this.userCollection = 'users',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection(userCollection)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(
                doc.id,
                doc.data(),
              ))
          .toList();
    });
  }

  @override
  Stream<UserModel> getUser({required String userId}) {
    return _firestore
        .collection(userCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      return UserModel.fromMap(
        snapshot.id,
        snapshot.data() as Map<String, dynamic>,
      );
    });
  }
}
