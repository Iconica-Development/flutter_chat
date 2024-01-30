import 'package:flutter_chat_interface/flutter_chat_interface.dart';
import 'package:flutter_chat_local/service/local_chat_detail_service.dart';
import 'package:flutter_chat_local/service/local_chat_overview_service.dart';
import 'package:flutter_chat_local/service/local_chat_user_service.dart';

class LocalChatService implements ChatService {
  LocalChatService({
    this.localChatDetailService,
    this.localChatOverviewService,
    this.localChatUserService,
  }) {
    {
      localChatOverviewService ??= LocalChatOverviewService();
      localChatDetailService ??= LocalChatDetailService(
        chatOverviewService: localChatOverviewService!,
      );

      localChatUserService ??= LocalChatUserService();
    }
  }

  ChatDetailService? localChatDetailService;
  ChatOverviewService? localChatOverviewService;
  ChatUserService? localChatUserService;

  @override
  ChatDetailService get chatDetailService => localChatDetailService!;

  @override
  ChatOverviewService get chatOverviewService => localChatOverviewService!;

  @override
  ChatUserService get chatUserService => localChatUserService!;
}
