// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';

@immutable
class FirebaseUserDocument {
  const FirebaseUserDocument({
    this.firstName,
    this.lastName,
    this.imageUrl,
    this.id,
  });

  FirebaseUserDocument.fromJson(
    Map<String, Object?> json,
    String id,
  ) : this(
          id: id,
          firstName:
              json['first_name'] == null ? '' : json['first_name']! as String,
          lastName:
              json['last_name'] == null ? '' : json['last_name']! as String,
          imageUrl:
              json['image_url'] == null ? null : json['image_url']! as String,
        );

  final String? firstName;
  final String? lastName;
  final String? imageUrl;
  final String? id;

  Map<String, Object?> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'image_url': imageUrl,
      };
}
