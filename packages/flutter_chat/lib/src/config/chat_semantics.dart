// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

// ignore_for_file: public_member_api_docs

/// Class that holds all the semantic ids for the chat component view and
///  the corresponding userstory
class ChatSemantics {
  /// ChatSemantics constructor where everything is required use this
  /// if you want to be sure to have all translations specified
  /// If you just want the default values use the standard constructor
  /// and optionally override the values with the copyWith method
  const ChatSemantics({
    required this.profileTitle,
    required this.profileDescription,
    required this.chatUnreadMessages,
    required this.chatChatTitle,
    required this.chatNoMessages,
    required this.newChatGetUsersError,
    required this.newGroupChatMemberAmount,
    required this.newGroupChatGetUsersError,
    required this.newChatUserListUserFullName,
    required this.chatBubbleTitle,
    required this.chatBubbleTime,
    required this.chatBubbleText,
    required this.chatsChatTitle,
    required this.chatsChatSubTitle,
    required this.chatsChatLastUsed,
    required this.chatsChatUnreadMessages,
    required this.chatMessageInput,
    required this.newChatNameInput,
    required this.newChatBioInput,
    required this.newChatSearchInput,
    required this.newGroupChatSearchInput,
  });

  /// Default translations for the chat component view
  const ChatSemantics.standard({
    this.profileTitle = "text_profile_title",
    this.profileDescription = "text_profile_description",
    this.chatUnreadMessages = "text_unread_messages",
    this.chatChatTitle = "text_chat_title",
    this.chatNoMessages = "text_no_messages",
    this.newChatGetUsersError = "text_get_users_error",
    this.newGroupChatMemberAmount = "text_member_amount",
    this.newGroupChatGetUsersError = "text_get_users_error",
    this.newChatUserListUserFullName = _defaultNewChatUserListUserFullName,
    this.chatBubbleTitle = _defaultChatBubbleTitle,
    this.chatBubbleTime = _defaultChatBubbleTime,
    this.chatBubbleText = _defaultChatBubbleText,
    this.chatsChatTitle = _defaultChatsChatTitle,
    this.chatsChatSubTitle = _defaultChatsChatSubTitle,
    this.chatsChatLastUsed = _defaultChatsChatLastUsed,
    this.chatsChatUnreadMessages = _defaultChatsChatUnreadMessages,
    this.chatMessageInput = "input_text_message",
    this.newChatNameInput = "input_text_name",
    this.newChatBioInput = "input_text_bio",
    this.newChatSearchInput = "input_text_search",
    this.newGroupChatSearchInput = "input_text_search",
  });

  // Text
  final String profileTitle;
  final String profileDescription;
  final String chatUnreadMessages;
  final String chatChatTitle;
  final String chatNoMessages;
  final String newChatGetUsersError;
  final String newGroupChatMemberAmount;
  final String newGroupChatGetUsersError;

  // Indexed text
  final String Function(int index) newChatUserListUserFullName;
  final String Function(int index) chatBubbleTitle;
  final String Function(int index) chatBubbleTime;
  final String Function(int index) chatBubbleText;
  final String Function(int index) chatsChatTitle;
  final String Function(int index) chatsChatSubTitle;
  final String Function(int index) chatsChatLastUsed;
  final String Function(int index) chatsChatUnreadMessages;

  // Input texts
  final String chatMessageInput;
  final String newChatNameInput;
  final String newChatBioInput;
  final String newChatSearchInput;
  final String newGroupChatSearchInput;

  ChatSemantics copyWith({
    String? profileTitle,
    String? profileDescription,
    String? chatUnreadMessages,
    String? chatChatTitle,
    String? chatNoMessages,
    String? newChatGetUsersError,
    String? newGroupChatMemberAmount,
    String? newGroupChatGetUsersError,
    String Function(int)? newChatUserListUserFullName,
    String Function(int)? chatBubbleTitle,
    String Function(int)? chatBubbleTime,
    String Function(int)? chatBubbleText,
    String Function(int)? chatsChatTitle,
    String Function(int)? chatsChatSubTitle,
    String Function(int)? chatsChatLastUsed,
    String Function(int)? chatsChatUnreadMessages,
    String? chatMessageInput,
    String? newChatNameInput,
    String? newChatBioInput,
    String? newChatSearchInput,
    String? newGroupChatSearchInput,
  }) =>
      ChatSemantics(
        profileTitle: profileTitle ?? this.profileTitle,
        profileDescription: profileDescription ?? this.profileDescription,
        chatUnreadMessages: chatUnreadMessages ?? this.chatUnreadMessages,
        chatChatTitle: chatChatTitle ?? this.chatChatTitle,
        chatNoMessages: chatNoMessages ?? this.chatNoMessages,
        newChatGetUsersError: newChatGetUsersError ?? this.newChatGetUsersError,
        newGroupChatMemberAmount:
            newGroupChatMemberAmount ?? this.newGroupChatMemberAmount,
        newGroupChatGetUsersError:
            newGroupChatGetUsersError ?? this.newGroupChatGetUsersError,
        newChatUserListUserFullName:
            newChatUserListUserFullName ?? this.newChatUserListUserFullName,
        chatBubbleTitle: chatBubbleTitle ?? this.chatBubbleTitle,
        chatBubbleTime: chatBubbleTime ?? this.chatBubbleTime,
        chatBubbleText: chatBubbleText ?? this.chatBubbleText,
        chatsChatTitle: chatsChatTitle ?? this.chatsChatTitle,
        chatsChatSubTitle: chatsChatSubTitle ?? this.chatsChatSubTitle,
        chatsChatLastUsed: chatsChatLastUsed ?? this.chatsChatLastUsed,
        chatsChatUnreadMessages:
            chatsChatUnreadMessages ?? this.chatsChatUnreadMessages,
        chatMessageInput: chatMessageInput ?? this.chatMessageInput,
        newChatNameInput: newChatNameInput ?? this.newChatNameInput,
        newChatBioInput: newChatBioInput ?? this.newChatBioInput,
        newChatSearchInput: newChatSearchInput ?? this.newChatSearchInput,
        newGroupChatSearchInput:
            newGroupChatSearchInput ?? this.newGroupChatSearchInput,
      );
}

String _defaultNewChatUserListUserFullName(int index) =>
    "text_user_fullname_$index";
String _defaultChatBubbleTitle(int index) => "text_chat_bubble_title_$index";
String _defaultChatBubbleTime(int index) => "text_chat_bubble_time_$index";
String _defaultChatBubbleText(int index) => "text_chat_bubble_text_$index";
String _defaultChatsChatTitle(int index) => "text_chat_title_$index";
String _defaultChatsChatSubTitle(int index) => "text_chat_sub_title_$index";
String _defaultChatsChatLastUsed(int index) => "text_chat_last_used_$index";
String _defaultChatsChatUnreadMessages(int index) =>
    "text_chat_unread_messages_$index";
