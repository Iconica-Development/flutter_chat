// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:flutter/material.dart";

/// Represents a user document in Firebase.
@immutable
class FirebaseUserDocument {
  /// Creates a new instance of `FirebaseUserDocument`.
  const FirebaseUserDocument({
    this.firstName,
    this.lastName,
    this.imageUrl,
    this.id,
  });

  /// Constructs a FirebaseUserDocument from JSON.
  FirebaseUserDocument.fromJson(
    Map<String, Object?> json,
    String id,
  ) : this(
          id: id,
          firstName:
              json["first_name"] == null ? "" : json["first_name"]! as String,
          lastName:
              json["last_name"] == null ? "" : json["last_name"]! as String,
          imageUrl:
              json["image_url"] == null ? null : json["image_url"]! as String,
        );

  /// The first name of the user.
  final String? firstName;

  /// The last name of the user.
  final String? lastName;

  /// The image URL of the user.
  final String? imageUrl;

  /// The unique identifier of the user document.
  final String? id;

  /// Converts the FirebaseUserDocument to JSON format.
  Map<String, Object?> toJson() => {
        "first_name": firstName,
        "last_name": lastName,
        "image_url": imageUrl,
      };
}
