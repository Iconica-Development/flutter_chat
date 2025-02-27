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
    required this.profileStartChatButton,
    required this.chatsStartChatButton,
    required this.chatsDeleteConfirmButton,
    required this.newChatCreateGroupChatButton,
    required this.newGroupChatCreateGroupChatButton,
    required this.newGroupChatNextButton,
    required this.imagePickerCancelButton,
    required this.chatSelectImageIconButton,
    required this.chatSendMessageIconButton,
    required this.newChatSearchIconButton,
    required this.newGroupChatSearchIconButton,
    required this.chatBackButton,
    required this.chatTitleButton,
    required this.newGroupChatSelectImage,
    required this.newGroupChatRemoveImage,
    required this.newGroupChatRemoveUser,
    required this.profileTapUserButton,
    required this.chatsOpenChatButton,
    required this.userListTapUser,
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
    this.profileStartChatButton = "button_start_chat",
    this.chatsStartChatButton = "button_start_chat",
    this.chatsDeleteConfirmButton = "button_delete_chat_confirm",
    this.newChatCreateGroupChatButton = "button_create_group_chat",
    this.newGroupChatCreateGroupChatButton = "button_create_group_chat",
    this.newGroupChatNextButton = "button_next",
    this.imagePickerCancelButton = "button_cancel",
    this.chatSelectImageIconButton = "button_icon_select_image",
    this.chatSendMessageIconButton = "button_icon_send_message",
    this.newChatSearchIconButton = "button_icon_search",
    this.newGroupChatSearchIconButton = "button_icon_search",
    this.chatBackButton = "button_back",
    this.chatTitleButton = "button_open_profile",
    this.newGroupChatSelectImage = "button_select_image",
    this.newGroupChatRemoveImage = "button_remove_image",
    this.newGroupChatRemoveUser = "button_remove_user",
    this.profileTapUserButton = _defaultProfileTapUserButton,
    this.chatsOpenChatButton = _defaultChatsOpenChatButton,
    this.userListTapUser = _defaultUserListTapUser,
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

  // Buttons
  final String profileStartChatButton;
  final String chatsStartChatButton;
  final String chatsDeleteConfirmButton;
  final String newChatCreateGroupChatButton;
  final String newGroupChatCreateGroupChatButton;
  final String newGroupChatNextButton;
  final String imagePickerCancelButton;

  // Icon buttons
  final String chatSelectImageIconButton;
  final String chatSendMessageIconButton;
  final String newChatSearchIconButton;
  final String newGroupChatSearchIconButton;

  // Inkwells
  final String chatBackButton;
  final String chatTitleButton;
  final String newGroupChatSelectImage;
  final String newGroupChatRemoveImage;
  final String newGroupChatRemoveUser;

  // Indexed inkwells
  final String Function(int index) profileTapUserButton;
  final String Function(int index) chatsOpenChatButton;
  final String Function(int index) userListTapUser;

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
    String? profileStartChatButton,
    String? chatsStartChatButton,
    String? chatsDeleteConfirmButton,
    String? newChatCreateGroupChatButton,
    String? newGroupChatCreateGroupChatButton,
    String? newGroupChatNextButton,
    String? imagePickerCancelButton,
    String? chatSelectImageIconButton,
    String? chatSendMessageIconButton,
    String? newChatSearchIconButton,
    String? newGroupChatSearchIconButton,
    String? chatBackButton,
    String? chatTitleButton,
    String? newGroupChatSelectImage,
    String? newGroupChatRemoveImage,
    String? newGroupChatRemoveUser,
    String Function(int)? profileTapUserButton,
    String Function(int)? chatsOpenChatButton,
    String Function(int)? userListTapUser,
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
        profileStartChatButton:
            profileStartChatButton ?? this.profileStartChatButton,
        chatsStartChatButton: chatsStartChatButton ?? this.chatsStartChatButton,
        chatsDeleteConfirmButton:
            chatsDeleteConfirmButton ?? this.chatsDeleteConfirmButton,
        newChatCreateGroupChatButton:
            newChatCreateGroupChatButton ?? this.newChatCreateGroupChatButton,
        newGroupChatCreateGroupChatButton: newGroupChatCreateGroupChatButton ??
            this.newGroupChatCreateGroupChatButton,
        newGroupChatNextButton:
            newGroupChatNextButton ?? this.newGroupChatNextButton,
        imagePickerCancelButton:
            imagePickerCancelButton ?? this.imagePickerCancelButton,
        chatSelectImageIconButton:
            chatSelectImageIconButton ?? this.chatSelectImageIconButton,
        chatSendMessageIconButton:
            chatSendMessageIconButton ?? this.chatSendMessageIconButton,
        newChatSearchIconButton:
            newChatSearchIconButton ?? this.newChatSearchIconButton,
        newGroupChatSearchIconButton:
            newGroupChatSearchIconButton ?? this.newGroupChatSearchIconButton,
        chatBackButton: chatBackButton ?? this.chatBackButton,
        chatTitleButton: chatTitleButton ?? this.chatTitleButton,
        newGroupChatSelectImage:
            newGroupChatSelectImage ?? this.newGroupChatSelectImage,
        newGroupChatRemoveImage:
            newGroupChatRemoveImage ?? this.newGroupChatRemoveImage,
        newGroupChatRemoveUser:
            newGroupChatRemoveUser ?? this.newGroupChatRemoveUser,
        profileTapUserButton: profileTapUserButton ?? this.profileTapUserButton,
        chatsOpenChatButton: chatsOpenChatButton ?? this.chatsOpenChatButton,
        userListTapUser: userListTapUser ?? this.userListTapUser,
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
String _defaultProfileTapUserButton(int index) => "button_tap_user_$index";
String _defaultChatsOpenChatButton(int index) => "button_open_chat_$index";
String _defaultUserListTapUser(int index) => "button_tap_user_$index";
