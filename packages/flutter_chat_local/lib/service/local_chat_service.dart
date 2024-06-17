import "package:flutter_chat_interface/flutter_chat_interface.dart";
import "package:flutter_chat_local/service/local_chat_detail_service.dart";
import "package:flutter_chat_local/service/local_chat_overview_service.dart";
import "package:flutter_chat_local/service/local_chat_user_service.dart";

/// Service class for managing local chat services.
class LocalChatService implements ChatService {
  /// Constructor for LocalChatService.
  ///
  /// [localChatDetailService]: Optional local ChatDetailService instance,
  /// defaults to LocalChatDetailService.
  /// [localChatOverviewService]: Optional local ChatOverviewService instance,
  /// defaults to LocalChatOverviewService.
  /// [localChatUserService]: Optional local ChatUserService instance,
  /// defaults to LocalChatUserService.
  LocalChatService({
    this.localChatDetailService,
    this.localChatOverviewService,
    this.localChatUserService,
  }) {
    localChatOverviewService ??= LocalChatOverviewService();
    localChatDetailService ??= LocalChatDetailService(
      chatOverviewService: localChatOverviewService!,
    );

    localChatUserService ??= LocalChatUserService();
  }

  /// The local chat detail service.
  ChatDetailService? localChatDetailService;

  /// The local chat overview service.
  ChatOverviewService? localChatOverviewService;

  /// The local chat user service.
  ChatUserService? localChatUserService;

  @override
  ChatDetailService get chatDetailService => localChatDetailService!;

  @override
  ChatOverviewService get chatOverviewService => localChatOverviewService!;

  @override
  ChatUserService get chatUserService => localChatUserService!;
}
