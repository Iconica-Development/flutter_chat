import "package:flutter/material.dart";

///
class PopHandler {
  /// Constructor
  PopHandler();

  final List<VoidCallback> _handlers = [];

  /// Registers a new handler
  void add(VoidCallback handler) {
    _handlers.add(handler);
  }

  /// Removes a handler
  void remove(VoidCallback handler) {
    _handlers.remove(handler);
  }

  /// Handles the pop
  void handlePop() {
    _handlers.lastOrNull?.call();
  }
}
