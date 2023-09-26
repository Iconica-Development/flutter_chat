// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

class ChatUserModel {
  ChatUserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.imageUrl,
  });

  final String? id;
  final String? firstName;
  final String? lastName;
  final String? imageUrl;

  String? get fullName {
    var fullName = '';

    if (firstName != null && lastName != null) {
      fullName += '$firstName $lastName';
    } else if (firstName != null) {
      fullName += firstName!;
    } else if (lastName != null) {
      fullName += lastName!;
    }

    return fullName == '' ? null : fullName;
  }
}
