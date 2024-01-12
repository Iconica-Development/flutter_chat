import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_profile/flutter_profile.dart';

class ChatProfileService extends ProfileService {
  @override
  FutureOr<void> editProfile(User user, String key, String? value) {
    throw UnimplementedError();
  }

  @override
  FutureOr<void> pageBottomAction() {
    throw UnimplementedError();
  }

  @override
  FutureOr<void> uploadImage(
    BuildContext context, {
    required Function(bool isUploading) onUploadStateChanged,
  }) {
    throw UnimplementedError();
  }
}
