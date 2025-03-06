// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

// ignore_for_file: public_member_api_docs

import "package:intl/intl.dart";

/// Class that holds all the translations for the chat component view and
///  the corresponding userstory
class ChatTranslations {
  /// ChatTranslations constructor where everything is required use this
  /// if you want to be sure to have all translations specified
  /// If you just want the default values use the empty constructor
  /// and optionally override the values with the copyWith method
  const ChatTranslations({
    required this.chatsTitle,
    required this.chatsUnread,
    required this.newChatButton,
    required this.newGroupChatButton,
    required this.newChatTitle,
    required this.image,
    required this.searchPlaceholder,
    required this.startTyping,
    required this.cancelImagePickerBtn,
    required this.messagePlaceholder,
    required this.writeMessageToStartChat,
    required this.writeFirstMessageInGroupChat,
    required this.imageUploading,
    required this.deleteChatModalTitle,
    required this.deleteChatModalDescription,
    required this.deleteChatModalCancel,
    required this.deleteChatModalConfirm,
    required this.noUsersFound,
    required this.noChatsFound,
    required this.chatProfileUsers,
    required this.imagePickerTitle,
    required this.uploadFile,
    required this.takePicture,
    required this.anonymousUser,
    required this.groupNameValidatorEmpty,
    required this.groupNameValidatorTooLong,
    required this.groupNameHintText,
    required this.newGroupChatTitle,
    required this.groupBioHintText,
    required this.groupProfileBioHeader,
    required this.groupBioValidatorEmpty,
    required this.groupChatNameFieldHeader,
    required this.groupBioFieldHeader,
    required this.selectedMembersHeader,
    required this.createGroupChatButton,
    required this.groupNameEmpty,
    required this.messagesLoadingError,
    required this.next,
    required this.chatTimeIndicatorLabel,
  });

  /// Default translations for the chat component view
  const ChatTranslations.empty({
    this.chatsTitle = "Chats",
    this.chatsUnread = "unread",
    this.newChatButton = "Start chat",
    this.newGroupChatButton = "Start a groupchat",
    this.newChatTitle = "Start a chat",
    this.image = "Image",
    this.searchPlaceholder = "Search...",
    this.startTyping = "Start typing to find a user to chat with",
    this.cancelImagePickerBtn = "Cancel",
    this.messagePlaceholder = "Write your message here...",
    this.writeMessageToStartChat = "Write a message to start the chat",
    this.writeFirstMessageInGroupChat =
        "Write the first message in this group chat",
    this.imageUploading = "Image is uploading...",
    this.deleteChatModalTitle = "Delete chat",
    this.deleteChatModalDescription =
        "Are you sure you want to delete this chat?",
    this.deleteChatModalCancel = "Cancel",
    this.deleteChatModalConfirm = "Confirm",
    this.noUsersFound = "No users were found to start a chat with",
    this.noChatsFound = "Click on 'Start a chat' to create a new chat",
    this.anonymousUser = "Anonymous user",
    this.chatProfileUsers = "Members:",
    this.imagePickerTitle = "Do you want to upload a file or take a picture?",
    this.uploadFile = "UPLOAD FILE",
    this.takePicture = "TAKE PICTURE",
    this.groupNameHintText = "Groupchat name",
    this.groupNameValidatorEmpty = "Please enter a group chat name",
    this.groupNameValidatorTooLong =
        "Group name is too long, max 15 characters",
    this.newGroupChatTitle = "start a groupchat",
    this.groupBioHintText = "Bio",
    this.groupProfileBioHeader = "Bio",
    this.groupBioValidatorEmpty = "Please enter a bio",
    this.groupChatNameFieldHeader = "Chat name",
    this.groupBioFieldHeader = "Additional information for members",
    this.selectedMembersHeader = "Members: ",
    this.createGroupChatButton = "Create groupchat",
    this.groupNameEmpty = "Group",
    this.messagesLoadingError = "Error loading messages, you can reload below:",
    this.next = "Next",
    this.chatTimeIndicatorLabel =
        ChatTranslations.defaultChatTimeIndicatorLabel,
  });

  final String chatsTitle;
  final String chatsUnread;
  final String newChatButton;
  final String newGroupChatButton;
  final String newChatTitle;
  final String image;
  final String searchPlaceholder;
  final String startTyping;
  final String cancelImagePickerBtn;
  final String messagePlaceholder;
  final String writeMessageToStartChat;
  final String writeFirstMessageInGroupChat;
  final String imageUploading;
  final String deleteChatModalTitle;
  final String deleteChatModalDescription;
  final String deleteChatModalCancel;
  final String deleteChatModalConfirm;
  final String noUsersFound;
  final String noChatsFound;
  final String chatProfileUsers;
  final String imagePickerTitle;
  final String uploadFile;
  final String takePicture;
  final String groupChatNameFieldHeader;
  final String groupBioFieldHeader;
  final String selectedMembersHeader;
  final String createGroupChatButton;

  /// Shown when the user has no name
  final String anonymousUser;
  final String groupNameValidatorEmpty;
  final String groupNameValidatorTooLong;
  final String groupNameHintText;
  final String newGroupChatTitle;
  final String groupBioHintText;
  final String groupProfileBioHeader;
  final String groupBioValidatorEmpty;
  final String groupNameEmpty;

  /// message shown in the default chat screen when the chat messages are unable
  /// to be loaded.
  final String messagesLoadingError;

  /// The message of a label given a certain offset.
  ///
  /// The offset determines whether it is today (0), yesterday (-1), or earlier.
  ///
  /// [dateOffset] will rarely be a +1, however if anyone ever wants to see
  /// future chat messages, then this number will be positive.
  ///
  /// use the given [time] format to display exact time information.
  final String Function(int dateOffset, DateTime time) chatTimeIndicatorLabel;

  /// Standard function to convert an offset to a String.
  ///
  /// Recommended to always override this in any production app with an
  /// app localizations implementation.
  static String defaultChatTimeIndicatorLabel(
    int dateOffset,
    DateTime time,
  ) =>
      switch (dateOffset) {
        0 => "Today",
        -1 => "Yesterday",
        1 => "Tomorrow",
        int value when value < 5 && value > 1 => "In $value days",
        int value when value < -1 && value > -5 => "$value days ago",
        _ => DateFormat("dd-MM-YYYY").format(time),
      };

  final String next;

  // copyWith method to override the default values
  ChatTranslations copyWith({
    String? chatsTitle,
    String? chatsUnread,
    String? newChatButton,
    String? newGroupChatButton,
    String? newChatTitle,
    String? image,
    String? searchPlaceholder,
    String? startTyping,
    String? cancelImagePickerBtn,
    String? messagePlaceholder,
    String? writeMessageToStartChat,
    String? writeFirstMessageInGroupChat,
    String? imageUploading,
    String? deleteChatModalTitle,
    String? deleteChatModalDescription,
    String? deleteChatModalCancel,
    String? deleteChatModalConfirm,
    String? noUsersFound,
    String? noChatsFound,
    String? chatProfileUsers,
    String? imagePickerTitle,
    String? uploadFile,
    String? takePicture,
    String? anonymousUser,
    String? groupNameValidatorEmpty,
    String? groupNameValidatorTooLong,
    String? groupNameHintText,
    String? newGroupChatTitle,
    String? groupBioHintText,
    String? groupProfileBioHeader,
    String? groupBioValidatorEmpty,
    String? groupChatNameFieldHeader,
    String? groupBioFieldHeader,
    String? selectedMembersHeader,
    String? createGroupChatButton,
    String? groupNameEmpty,
    String? messagesLoadingError,
    String? next,
    String Function(int dateOffset, DateTime time)? chatTimeIndicatorLabel,
  }) =>
      ChatTranslations(
        chatsTitle: chatsTitle ?? this.chatsTitle,
        chatsUnread: chatsUnread ?? this.chatsUnread,
        newChatButton: newChatButton ?? this.newChatButton,
        newGroupChatButton: newGroupChatButton ?? this.newGroupChatButton,
        newChatTitle: newChatTitle ?? this.newChatTitle,
        image: image ?? this.image,
        searchPlaceholder: searchPlaceholder ?? this.searchPlaceholder,
        startTyping: startTyping ?? this.startTyping,
        cancelImagePickerBtn: cancelImagePickerBtn ?? this.cancelImagePickerBtn,
        messagePlaceholder: messagePlaceholder ?? this.messagePlaceholder,
        writeMessageToStartChat:
            writeMessageToStartChat ?? this.writeMessageToStartChat,
        writeFirstMessageInGroupChat:
            writeFirstMessageInGroupChat ?? this.writeFirstMessageInGroupChat,
        imageUploading: imageUploading ?? this.imageUploading,
        deleteChatModalTitle: deleteChatModalTitle ?? this.deleteChatModalTitle,
        deleteChatModalDescription:
            deleteChatModalDescription ?? this.deleteChatModalDescription,
        deleteChatModalCancel:
            deleteChatModalCancel ?? this.deleteChatModalCancel,
        deleteChatModalConfirm:
            deleteChatModalConfirm ?? this.deleteChatModalConfirm,
        noUsersFound: noUsersFound ?? this.noUsersFound,
        noChatsFound: noChatsFound ?? this.noChatsFound,
        chatProfileUsers: chatProfileUsers ?? this.chatProfileUsers,
        imagePickerTitle: imagePickerTitle ?? this.imagePickerTitle,
        uploadFile: uploadFile ?? this.uploadFile,
        takePicture: takePicture ?? this.takePicture,
        anonymousUser: anonymousUser ?? this.anonymousUser,
        groupNameValidatorEmpty:
            groupNameValidatorEmpty ?? this.groupNameValidatorEmpty,
        groupNameValidatorTooLong:
            groupNameValidatorTooLong ?? this.groupNameValidatorTooLong,
        groupNameHintText: groupNameHintText ?? this.groupNameHintText,
        newGroupChatTitle: newGroupChatTitle ?? this.newGroupChatTitle,
        groupBioHintText: groupBioHintText ?? this.groupBioHintText,
        groupProfileBioHeader:
            groupProfileBioHeader ?? this.groupProfileBioHeader,
        groupBioValidatorEmpty:
            groupBioValidatorEmpty ?? this.groupBioValidatorEmpty,
        groupChatNameFieldHeader:
            groupChatNameFieldHeader ?? this.groupChatNameFieldHeader,
        groupBioFieldHeader: groupBioFieldHeader ?? this.groupBioFieldHeader,
        selectedMembersHeader:
            selectedMembersHeader ?? this.selectedMembersHeader,
        createGroupChatButton:
            createGroupChatButton ?? this.createGroupChatButton,
        groupNameEmpty: groupNameEmpty ?? this.groupNameEmpty,
        messagesLoadingError: messagesLoadingError ?? this.messagesLoadingError,
        next: next ?? this.next,
        chatTimeIndicatorLabel:
            chatTimeIndicatorLabel ?? this.chatTimeIndicatorLabel,
      );
}
