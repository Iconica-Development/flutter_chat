import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseMessageDocument {
  FirebaseMessageDocument({
    required this.sender,
    required this.timestamp,
    this.id,
    this.text,
    this.imageUrl,
  });

  final String? id;
  final String sender;
  final String? text;
  final String? imageUrl;
  final Timestamp timestamp;

  FirebaseMessageDocument.fromJson(Map<String, dynamic> json, this.id)
      : sender = json['sender'],
        text = json['text'],
        imageUrl = json['image_url'],
        timestamp = json['timestamp'];

  Map<String, dynamic> toJson() => {
        'sender': sender,
        'text': text,
        'image_url': imageUrl,
        'timestamp': timestamp,
      };
}
