// ignore_for_file: public_member_api_docs, sort_constructors_first
// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:flutter/material.dart";

abstract class ChatUserModelInterface {
  String? get id;
  String? get firstName;
  String? get lastName;
  String? get imageUrl;

  String? get fullName;
}

/// A concrete implementation of [ChatUserModelInterface]
/// representing a chat user.
@immutable
class ChatUserModel implements ChatUserModelInterface {
  /// Constructs a [ChatUserModel] instance.
  ///
  /// [id]: The ID of the user.
  ///
  /// [firstName]: The first name of the user.
  ///
  /// [lastName]: The last name of the user.
  ///
  /// [imageUrl]: The URL of the user's image.
  ///
  const ChatUserModel({
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
    var fullName = "";

    if (firstName != null && lastName != null) {
      fullName += "$firstName $lastName";
    } else if (firstName != null) {
      fullName += firstName!;
    } else if (lastName != null) {
      fullName += lastName!;
    }

    return fullName == "" ? null : fullName;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ChatUserModel && id == other.id;

  @override
  int get hashCode =>
      id.hashCode ^ firstName.hashCode ^ lastName.hashCode ^ imageUrl.hashCode;
}
