/// User model
/// Represents a user in a chat
/// [id] is the user id.
/// [firstName] is the user first name.
/// [lastName] is the user last name.
/// [imageUrl] is the user image url.
/// [fullname] is the user full name.
class UserModel {
  /// User model constructor
  const UserModel({
    required this.id,
    this.firstName,
    this.lastName,
    this.imageUrl,
  });

  /// Creates a user based on a given map [data]
  factory UserModel.fromMap(String id, Map<String, dynamic> data) => UserModel(
        id: id,
        firstName: data["first_name"],
        lastName: data["last_name"],
        imageUrl: data["image_url"],
      );

  /// The user id
  final String id;

  /// The user first name
  final String? firstName;

  /// The user last name
  final String? lastName;

  /// The user image url
  final String? imageUrl;
}

/// Extension on [UserModel] to get the user full name
extension Fullname on UserModel {
  /// Get the user full name
  String? get fullname {
    if (firstName == null && lastName == null) {
      return null;
    }

    if (firstName == null) {
      return lastName;
    }

    if (lastName == null) {
      return firstName;
    }

    return "$firstName $lastName";
  }
}
