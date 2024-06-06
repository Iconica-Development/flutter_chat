// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:flutter_chat_interface/flutter_chat_interface.dart";
import "package:flutter_data_interface/flutter_data_interface.dart";

class ChatDataProvider extends DataInterface {
  ChatDataProvider({
    required this.chatService,
    required this.userService,
    required this.messageService,
  }) : super(token: _token);

  static final Object _token = Object();
  final ChatUserService userService;
  final ChatOverviewService chatService;
  final ChatDetailService messageService;
}
