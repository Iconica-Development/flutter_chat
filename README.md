# Flutter Chat

Flutter Chat is a package which gives the possibility to add a (personal or group) chat to your Flutter-application. Default this package adds support for a Firebase back-end. You can add your custom back-end (like a Websocket-API) by extending the `ChatInterface` interface from the `flutter_chat_interface` package.

![Flutter Chat GIF](example.gif)

Figma Design that defines this component (only accessible for Iconica developers): https://www.figma.com/file/4WkjwynOz5wFeFBRqTHPeP/Iconica-Design-System?type=design&node-id=357%3A3342&mode=design&t=XulkAJNPQ32ARxWh-1
Figma clickable prototype that demonstrates this component (only accessible for Iconica developers): https://www.figma.com/proto/PRJoVXQ5aOjAICfkQdAq2A/Iconica-User-Stories?page-id=1%3A2&type=design&node-id=56-6837&viewport=279%2C2452%2C0.2&t=E7Al3Xng2WXnbCEQ-1&scaling=scale-down&starting-point-node-id=56%3A6837&mode=design

## Setup

To use this package, add flutter_chat as a dependency in your pubspec.yaml file:

```
  flutter_chat:
    git:
        url: https://github.com/Iconica-Development/flutter_chat
        path: packages/flutter_chat
```

If you are going to use Firebase as the back-end of the Community Chat, you should also add the following package as a dependency to your pubspec.yaml file:

```
  flutter_chat_firebase:
    git:
        url: https://github.com/Iconica-Development/flutter_chat
        path: packages/flutter_chat_firebase
```

Create a Firebase project for your application and add firebase firestore and storage.

To use the camera or photo library to send photos add the following to your project:

For ios add the following lines to your info.plist:

```
	<key>NSCameraUsageDescription</key>
	<string>Access camera</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>Library</string>
```

For android add the following lines to your AndroidManifest.xml:

```
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.GALLERY"/>
```

## How to use

To use the module within your Flutter-application with predefined `Go_router` routes you should add the following:

Add go_router as dependency to your project.
Add the following configuration to your flutter_application:

```
List<GoRoute> getChatRoutes() => getChatStoryRoutes(
      ChatUserStoryConfiguration(
        chatService: chatService,
        chatOptionsBuilder: (ctx) => const ChatOptions(),
      ),
    );
```

Add the `getChatRoutes()` to your go_router routes like so:

```
final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const MyHomePage(
          title: "home",
        );
      },
    ),
    ...getChatRoutes()
  ],
);
```

To use the module within your Flutter-application without predefined `Go_router` routes add the following code to the build-method of a chosen widget:

The `ChatScreen` shows all chats that you currently have with their latest messages.
To add the `ChatScreen` add the following code:

````
ChatScreen(
  options: options,
  onPressStartChat: onPressStartChat,
  onPressChat: onPressChat,
  onDeleteChat: onDeleteChat,
  service: service,
  pageSize: pageSize,
  );
```

The `ChatDetailScreen` shows the messages that are in the current chat you selected.
To add the `ChatDetailScreen` add the following code:

```
ChatDetailScreen(
  options: options,
  onMessageSubmit: onMessageSubmit,
  onUploadImage: onUploadImage,
  onReadChat: onReadChat,
  service: service,
  );
```

On the `NewChatScreen` you can select a person to chat.
To add the `NewChatScreen` add the following code:

```
NewChatScreen(
  options: options,
  onPressCreateChat: onPressCreateChat,
  service: service,
  );
```

The `ChatEntryWidget` is a widget you can put anywhere in your app.
It displays the amount of unread messages you currently have.
You can choose to add a onTap to the `ChatEntryWidget` so it routes to the `ChatScreen`,
where all your chats are shown.

To add the `ChatEntryWidget` add the follwoing code:

```
ChatEntryWidget(
  chatService: chatService,
  onTap: onTap,
);
```

The `ChatOptions` has its own parameters, as specified below:
| Parameter | Explanation |
|-----------|-------------|
| newChatButtonBuilder | Builds the 'New Chat' button, to initiate a new chat session. This button is displayed on the chat overview. |
| messageInputBuilder | Builds the text input which is displayed within the chat view, responsible for sending text messages. |
| chatRowContainerBuilder | Builds a chat row. A row with the users' avatar, name and eventually the last massage sended in the chat. This builder is used both in the _chat overview screen_ as in the _new chat screen_. |
| imagePickerContainerBuilder | Builds the container around the ImagePicker. |
| closeImagePickerButtonBuilder | Builds the close button for the Image Picker pop-up window. |
| scaffoldBuilder | Builds the default Scaffold-widget around the Community Chat. The chat title is displayed within the Scaffolds' title for example. |

The `ImagePickerTheme` also has its own parameters, how to use these parameters can be found in [the documentation of the flutter_image_picker package](https://github.com/Iconica-Development/flutter_image_picker).

## Issues

Please file any issues, bugs or feature request as an issue on our [GitHub](https://github.com/Iconica-Development/flutter_chat/pulls) page. Commercial support is available if you need help with integration with your app or services. You can contact us at [support@iconica.nl](mailto:support@iconica.nl).

## Want to contribute

If you would like to contribute to the plugin (e.g. by improving the documentation, solving a bug or adding a cool new feature), please carefully review our [contribution guide](../CONTRIBUTING.md) and send us your [pull request](https://github.com/Iconica-Development/flutter_chat/pulls).

## Author

This `flutter_chat` for Flutter is developed by [Iconica](https://iconica.nl). You can contact us at <support@iconica.nl>
````
