class UserModel {
  UserModel({
    required this.id,
    this.firstName,
    this.lastName,
    this.imageUrl,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final String? imageUrl;
}

extension Fullname on UserModel {
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
