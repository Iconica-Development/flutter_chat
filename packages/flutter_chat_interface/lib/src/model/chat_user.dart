// ignore_for_file: public_member_api_docs, sort_constructors_first
// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

abstract class ChatUserModelInterface {
  String? get id;
  String? get firstName;
  String? get lastName;
  String? get imageUrl;

  String? get fullName;
}

class ChatUserModel implements ChatUserModelInterface {
  ChatUserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.imageUrl,
  });

  @override
  final String? id;
  @override
  final String? firstName;
  @override
  final String? lastName;
  @override
  final String? imageUrl;
  @override
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
