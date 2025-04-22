import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:cloud_firestore/cloud_firestore.dart";

/// Firebase implementation of a user respository for chats.
class FirebaseUserRepository implements UserRepositoryInterface {
  /// Creates a firebase implementation of a user respository for chats.
  FirebaseUserRepository({
    FirebaseFirestore? firestore,
    String userCollection = "users",
    String chatCollection = "chats",
  })  : _userCollection = userCollection,
        _chatCollection = chatCollection,
        _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  final String _userCollection;
  final String _chatCollection;

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

  @override
  Stream<List<UserModel>> getAllUsersForChat({required String chatId}) {
    var chatDocStream =
        _firestore.collection(_chatCollection).doc(chatId).snapshots();

    return chatDocStream.asyncMap((snapshot) async {
      if (!snapshot.exists) return [];

      var chatModel = ChatModel.fromMap(snapshot.id, snapshot.data()!);
      var userIds = chatModel.users;

      var userStreams =
          userIds.map((userId) => getUser(userId: userId)).toList();

      return Future.wait(userStreams.map((s) => s.first));
    });
  }
}
