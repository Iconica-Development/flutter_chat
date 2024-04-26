// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

class ChatTranslations {
  const ChatTranslations({
    this.chatsTitle = 'Chats',
    this.chatsUnread = 'unread',
    this.newChatButton = 'Start a chat',
    this.newGroupChatButton = 'Start group chat',
    this.newChatTitle = 'Start a chat',
    this.image = 'Image',
    this.searchPlaceholder = 'Search...',
    this.startTyping = 'Start typing to find a user to chat with.',
    this.cancelImagePickerBtn = 'Cancel',
    this.messagePlaceholder = 'Write your message here...',
    this.writeMessageToStartChat = 'Write a message to start the chat.',
    this.writeFirstMessageInGroupChat =
        'Write the first message in this group chat.',
    this.imageUploading = 'Image is uploading...',
    this.deleteChatButton = 'Delete',
    this.deleteChatModalTitle = 'Delete chat',
    this.deleteChatModalDescription =
        'Are you sure you want to delete this chat?',
    this.deleteChatModalCancel = 'Cancel',
    this.deleteChatModalConfirm = 'Delete',
    this.noUsersFound = 'No users were found to start a chat with.',
    this.noChatsFound = 'Click on \'Start a chat\' to create a new chat.',
    this.anonymousUser = 'Anonymous user',
    this.chatCantBeDeleted = 'This chat can\'t be deleted',
    this.chatProfileUsers = 'Users:',
    this.imagePickerTitle = 'Do you want to upload a file or take a picture?',
    this.uploadFile = 'UPLOAD FILE',
    this.takePicture = 'TAKE PICTURE',
  });

  final String chatsTitle;
  final String chatsUnread;
  final String newChatButton;
  final String newGroupChatButton;
  final String newChatTitle;
  final String deleteChatButton;
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
  final String chatCantBeDeleted;
  final String chatProfileUsers;
  final String imagePickerTitle;
  final String uploadFile;
  final String takePicture;

  /// Shown when the user has no name
  final String anonymousUser;
}
