// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

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
    required this.deleteChatButton,
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
    required this.chatCantBeDeleted,
    required this.chatProfileUsers,
    required this.imagePickerTitle,
    required this.uploadFile,
    required this.takePicture,
    required this.anonymousUser,
  });

  /// Default translations for the chat component view
  const ChatTranslations.empty({
    this.chatsTitle = 'Chats',
    this.chatsUnread = 'unread',
    this.newChatButton = 'Start a chat',
    this.newGroupChatButton = 'Create a group chat',
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

  // copyWith method to override the default values
  ChatTranslations copyWith({
    String? chatsTitle,
    String? chatsUnread,
    String? newChatButton,
    String? newGroupChatButton,
    String? newChatTitle,
    String? deleteChatButton,
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
    String? chatCantBeDeleted,
    String? chatProfileUsers,
    String? imagePickerTitle,
    String? uploadFile,
    String? takePicture,
    String? anonymousUser,
  }) =>
      ChatTranslations(
        chatsTitle: chatsTitle ?? this.chatsTitle,
        chatsUnread: chatsUnread ?? this.chatsUnread,
        newChatButton: newChatButton ?? this.newChatButton,
        newGroupChatButton: newGroupChatButton ?? this.newGroupChatButton,
        newChatTitle: newChatTitle ?? this.newChatTitle,
        deleteChatButton: deleteChatButton ?? this.deleteChatButton,
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
        chatCantBeDeleted: chatCantBeDeleted ?? this.chatCantBeDeleted,
        chatProfileUsers: chatProfileUsers ?? this.chatProfileUsers,
        imagePickerTitle: imagePickerTitle ?? this.imagePickerTitle,
        uploadFile: uploadFile ?? this.uploadFile,
        takePicture: takePicture ?? this.takePicture,
        anonymousUser: anonymousUser ?? this.anonymousUser,
      );
}
