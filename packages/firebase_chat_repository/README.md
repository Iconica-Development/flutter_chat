# Firebase chat repository
The firebase implementation of the chat_repository_interface

## Usage
```dart
chatService: ChatService(
    chatRepository: FirebaseChatRepository(
        chatCollection: 'chats', 
        messageCollection: 'messages', 
        mediaPath: 'chat',
    ),
    userRepository: FirebaseUserRepository(
        userCollection: 'users',
    ),
),
```