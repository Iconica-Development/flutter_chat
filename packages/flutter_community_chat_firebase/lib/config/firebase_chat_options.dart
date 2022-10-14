class FirebaseChatOptoons {
  const FirebaseChatOptoons({
    this.chatsCollectionName = 'chats',
    this.messagesCollectionName = 'messages',
    this.usersCollectionName = 'users',
  });

  final String chatsCollectionName;
  final String messagesCollectionName;
  final String usersCollectionName;
}
