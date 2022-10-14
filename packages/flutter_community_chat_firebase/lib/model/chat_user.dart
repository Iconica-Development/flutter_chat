import 'package:flutter_community_chat_interface/flutter_community_chat_interface.dart';

class FirebaseChatUserModel extends ChatUserModel {
  FirebaseChatUserModel({
    required super.name,
    required super.imageUrl,
    super.id,
  });

  FirebaseChatUserModel.fromJson(String id, Map<String, Object?> json)
      : this(
            id: id,
            name: json['name'] == null ? null : json['name'] as String,
            imageUrl:
                json['image_url'] == null ? null : json['image_url'] as String);

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'image_url': imageUrl,
    };
  }
}
