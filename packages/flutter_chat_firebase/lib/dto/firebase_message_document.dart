// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";

/// Represents a message document in Firebase.
@immutable
class FirebaseMessageDocument {
  /// Creates a new instance of `FirebaseMessageDocument`.
  const FirebaseMessageDocument({
    required this.sender,
    required this.timestamp,
    this.id,
    this.text,
    this.imageUrl,
  });

  /// Constructs a FirebaseMessageDocument from JSON.
  FirebaseMessageDocument.fromJson(Map<String, dynamic> json, this.id)
      : sender = json["sender"],
        text = json["text"],
        imageUrl = json["image_url"],
        timestamp = json["timestamp"];

  /// The unique identifier of the message document.
  final String? id;

  /// The sender of the message.
  final String sender;

  /// The text content of the message.
  final String? text;

  /// The image URL of the message.
  final String? imageUrl;

  /// The timestamp of when the message was sent.
  final Timestamp timestamp;

  /// Converts the FirebaseMessageDocument to JSON format.
  Map<String, dynamic> toJson() => {
        "sender": sender,
        "text": text,
        "image_url": imageUrl,
        "timestamp": timestamp,
      };
}
