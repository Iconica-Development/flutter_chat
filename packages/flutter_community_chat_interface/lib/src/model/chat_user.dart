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

  String? get fullName => firstName == null && lastName == null
      ? null
      : '${firstName ?? ''} ${lastName ?? ''}';
}
