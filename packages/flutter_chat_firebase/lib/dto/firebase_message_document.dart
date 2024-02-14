// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

@immutable
class FirebaseMessageDocument {
  const FirebaseMessageDocument({
    required this.sender,
    required this.timestamp,
    this.id,
    this.text,
    this.imageUrl,
  });

  FirebaseMessageDocument.fromJson(Map<String, dynamic> json, this.id)
      : sender = json['sender'],
        text = json['text'],
        imageUrl = json['image_url'],
        timestamp = json['timestamp'];

  final String? id;
  final String sender;
  final String? text;
  final String? imageUrl;
  final Timestamp timestamp;

  Map<String, dynamic> toJson() => {
        'sender': sender,
        'text': text,
        'image_url': imageUrl,
        'timestamp': timestamp,
      };
}
