// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

class ChatTranslations {
  const ChatTranslations({
    this.chatsTitle = 'Chats',
    this.chatsUnread = 'unread',
    this.newChatButton = 'Start chat',
    this.newChatTitle = 'Start chat',
    this.image = 'Image',
    this.searchPlaceholder = 'Search...',
    this.cancelImagePickerBtn = 'Cancel',
    this.messagePlaceholder = 'Write your message here...',
    this.imageUploading = 'Image is uploading...',
    this.deleteChatButton = 'Delete',
    this.deleteChatModalTitle = 'Delete chat',
    this.deleteChatModalDescription =
        'Are you sure you want to delete this chat?',
    this.deleteChatModalCancel = 'Cancel',
    this.deleteChatModalConfirm = 'Delete',
    this.noUsersFound = 'No users found',
    this.anonymousUser = 'Anonymous user',
    this.chatCantBeDeleted = 'This chat can\'t be deleted',
    this.chatProfileUsers = 'Users:',
  });

  final String chatsTitle;
  final String chatsUnread;
  final String newChatButton;
  final String newChatTitle;
  final String deleteChatButton;
  final String image;
  final String searchPlaceholder;
  final String cancelImagePickerBtn;
  final String messagePlaceholder;
  final String imageUploading;
  final String deleteChatModalTitle;
  final String deleteChatModalDescription;
  final String deleteChatModalCancel;
  final String deleteChatModalConfirm;
  final String noUsersFound;
  final String chatCantBeDeleted;
  final String chatProfileUsers;

  /// Shown when the user has no name
  final String anonymousUser;
}
