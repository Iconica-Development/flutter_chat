import 'dart:typed_data';

import 'package:chat_repository_interface/chat_repository_interface.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseChatRepository implements ChatRepositoryInterface {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final String chatCollection;
  final String messageCollection;
  final String mediaPath;

  FirebaseChatRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    this.chatCollection = 'chats',
    this.messageCollection = 'messages',
    this.mediaPath = 'chat',
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<void> createChat({
    required List<String> users,
    required bool isGroupChat,
    String? chatName,
    String? description,
    String? imageUrl,
    List<MessageModel>? messages,
  }) async {
    final chatData = {
      'users': users,
      'isGroupChat': isGroupChat,
      'chatName': chatName,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
    await _firestore.collection(chatCollection).add(chatData);
  }

  @override
  Future<void> deleteChat({required String chatId}) async {
    await _firestore.collection(chatCollection).doc(chatId).delete();
  }

  @override
  Stream<ChatModel> getChat({required String chatId}) {
    return _firestore
        .collection(chatCollection)
        .doc(chatId)
        .snapshots()
        .map((snapshot) {
      var data = snapshot.data() as Map<String, dynamic>;
      return ChatModel.fromMap(snapshot.id, data);
    });
  }

  @override
  Stream<List<ChatModel>?> getChats({required String userId}) {
    return _firestore
        .collection(chatCollection)
        .where('users', arrayContains: userId)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        var data = doc.data();
        return ChatModel.fromMap(doc.id, data);
      }).toList();
    });
  }

  @override
  Stream<MessageModel?> getMessage(
      {required String chatId, required String messageId}) {
    return _firestore
        .collection(chatCollection)
        .doc(chatId)
        .collection(messageCollection)
        .doc(messageId)
        .snapshots()
        .map((snapshot) {
      var data = snapshot.data() as Map<String, dynamic>;
      return MessageModel.fromMap(
        snapshot.id,
        data,
      );
    });
  }

  @override
  Stream<List<MessageModel>?> getMessages({
    required String chatId,
    required String userId,
    required int pageSize,
    required int page,
  }) {
    return _firestore
        .collection(chatCollection)
        .doc(chatId)
        .collection(messageCollection)
        .orderBy('timestamp')
        .limit(pageSize)
        .snapshots()
        .map((query) => query.docs
            .map((snapshot) => MessageModel.fromMap(
                  snapshot.id,
                  snapshot.data(),
                ))
            .toList());
  }

  @override
  Stream<int> getUnreadMessagesCount(
      {required String userId, String? chatId}) async* {
    var query = _firestore
        .collection(chatCollection)
        .where('users', arrayContains: userId)
        .where('unreadMessageCount', isGreaterThan: 0)
        .snapshots();

    await for (var snapshot in query) {
      var count = 0;
      for (var doc in snapshot.docs) {
        var data = doc.data();
        var lastMessageKey = data['lastMessage'];

        var message =
            await getMessage(chatId: doc.id, messageId: lastMessageKey).first;
        if (message?.senderId != userId) {
          count += data['unreadMessageCount'] as int;
        }
      }

      yield count;
    }
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String messageId,
    String? text,
    String? imageUrl,
    DateTime? timestamp,
  }) async {
    var message = MessageModel(
        chatId: chatId,
        id: messageId,
        text: text,
        imageUrl: imageUrl,
        timestamp: timestamp ?? DateTime.now(),
        senderId: senderId);

    await _firestore
        .collection(chatCollection)
        .doc(chatId)
        .collection(messageCollection)
        .doc(messageId)
        .set(
          message.toMap(),
        );

    await _firestore.collection(chatCollection).doc(chatId).update(
      {
        'lastMessage': messageId,
        'unreadMessageCount': FieldValue.increment(1),
        'lastUsed': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  @override
  Future<void> updateChat({required ChatModel chat}) async {
    await _firestore
        .collection(chatCollection)
        .doc(chat.id)
        .update(chat.toMap());
  }

  @override
  Future<String> uploadImage(
      {required String path, required Uint8List image}) async {
    final ref = _storage.ref().child(mediaPath).child(path);
    final uploadTask = ref.putData(image);
    final snapshot = await uploadTask.whenComplete(() => {});
    return await snapshot.ref.getDownloadURL();
  }
}
