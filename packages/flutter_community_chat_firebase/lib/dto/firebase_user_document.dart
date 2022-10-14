class FirebaseUserDocument {
  FirebaseUserDocument({
    this.firstName,
    this.lastName,
    this.imageUrl,
    this.id,
  });

  final String? firstName;
  final String? lastName;
  final String? imageUrl;
  final String? id;

  FirebaseUserDocument.fromJson(
    Map<String, Object?> json,
    String id,
  ) : this(
            id: id,
            firstName:
                json['first_name'] == null ? '' : json['first_name'] as String,
            lastName:
                json['last_name'] == null ? '' : json['last_name'] as String,
            imageUrl:
                json['image_url'] == null ? null : json['image_url'] as String);

  Map<String, Object?> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'image_url': imageUrl,
    };
  }
}
