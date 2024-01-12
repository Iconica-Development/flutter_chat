// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_chat_interface/flutter_chat_interface.dart';

class ChatService {
  final ChatUserService chatUserService;
  final ChatOverviewService chatOverviewService;
  final ChatDetailService chatDetailService;

  ChatService({
    required this.chatUserService,
    required this.chatOverviewService,
    required this.chatDetailService,
  });
}
