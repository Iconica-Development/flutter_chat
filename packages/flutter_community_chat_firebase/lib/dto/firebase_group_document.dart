class FirebaseGroupDocument {
  const FirebaseGroupDocument({
    required this.chats,
    this.id,
    this.title,
  });
  factory FirebaseGroupDocument.fromJson(
          Map<String, dynamic> json, String id) =>
      FirebaseGroupDocument(
        id: id,
        chats: List<String>.from(json['chats']),
        title: json['title'],
      );
  final List<String> chats;
  final String? id;
  final String? title;

  Map<String, dynamic> toJson() => {
        'chats': chats,
        'title': title,
      };
}
