import "package:firebase_core/firebase_core.dart";
import "package:flutter_chat_firebase/config/firebase_chat_options.dart";
import "package:flutter_chat_firebase/flutter_chat_firebase.dart";
import "package:flutter_chat_interface/flutter_chat_interface.dart";

/// Service class for managing chat services using Firebase.
class FirebaseChatService implements ChatService {
  FirebaseChatService({
    this.options,
    this.app,
    this.firebaseChatDetailService,
    this.firebaseChatOverviewService,
    this.firebaseChatUserService,
  }) {
    firebaseChatDetailService ??= FirebaseChatDetailService(
      userService: chatUserService,
      options: options,
      app: app,
    );

    firebaseChatOverviewService ??= FirebaseChatOverviewService(
      userService: chatUserService,
      options: options,
      app: app,
    );

    firebaseChatUserService ??= FirebaseChatUserService(
      options: options,
      app: app,
    );
  }

  /// The options for configuring Firebase Chat.
  final FirebaseChatOptions? options;

  /// The Firebase app instance.
  final FirebaseApp? app;

  /// The service for managing chat details.
  ChatDetailService? firebaseChatDetailService;

  /// The service for managing chat overviews.
  ChatOverviewService? firebaseChatOverviewService;

  /// The service for managing chat users.
  ChatUserService? firebaseChatUserService;

  @override
  ChatDetailService get chatDetailService {
    if (firebaseChatDetailService != null) {
      return firebaseChatDetailService!;
    } else {
      return FirebaseChatDetailService(
        userService: chatUserService,
        options: options,
        app: app,
      );
    }
  }

  @override
  ChatOverviewService get chatOverviewService {
    if (firebaseChatOverviewService != null) {
      return firebaseChatOverviewService!;
    } else {
      return FirebaseChatOverviewService(
        userService: chatUserService,
        options: options,
        app: app,
      );
    }
  }

  @override
  ChatUserService get chatUserService {
    if (firebaseChatUserService != null) {
      return firebaseChatUserService!;
    } else {
      return FirebaseChatUserService(
        options: options,
        app: app,
      );
    }
  }
}
