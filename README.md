# Flutter Community Chat
Flutter Community Chat is a package which gives the possibility to add a (personal or group) chat to your Flutter-application. Default this package adds support for a Firebase back-end. You can add your custom back-end (like a Websocket-API) by extending the `CommunityChatInterface` interface from the `flutter_community_chat_interface` package.

![Flutter Community Chat GIF](example.gif)

Figma Design that defines this component (only accessible for Iconica developers): https://www.figma.com/file/4WkjwynOz5wFeFBRqTHPeP/Iconica-Design-System?type=design&node-id=357%3A3342&mode=design&t=XulkAJNPQ32ARxWh-1
Figma clickable prototype that demonstrates this component (only accessible for Iconica developers): https://www.figma.com/proto/PRJoVXQ5aOjAICfkQdAq2A/Iconica-User-Stories?page-id=1%3A2&type=design&node-id=56-6837&viewport=279%2C2452%2C0.2&t=E7Al3Xng2WXnbCEQ-1&scaling=scale-down&starting-point-node-id=56%3A6837&mode=design

## Setup
To use this package, add flutter_community_chat as a dependency in your pubspec.yaml file:

```
  flutter_community_chat:
    git: 
        url: https://github.com/Iconica-Development/flutter_community_chat.git
        path: packages/flutter_community_chat
```

If you are going to use Firebase as the back-end of the Community Chat, you should also add the following package as a dependency to your pubspec.yaml file:

```
  flutter_community_chat_firebase:
    git: 
        url: https://github.com/Iconica-Development/flutter_community_chat.git
        path: packages/flutter_community_chat_firebase
```

## How to use
To use the module within your Flutter-application you should add the following code to the build-method of a chosen widget.

```
CommunityChat(
    dataProvider: FirebaseCommunityChatDataProvider(),
)
```

In this example we provide a `FirebaseCommunityChatDataProvider` as a data provider. You can also specify your own implementation here of the `CommunityChatInterface` interface.

You can also include your custom configuration for both the Community Chat itself as the Image Picker which is included in this package. You can specify those configurations as a parameter:

```
CommunityChat(
    dataProvider: FirebaseCommunityChatDataProvider(),
    imagePickerTheme: ImagePickerTheme(),
    chatOptions: ChatOptions(),
)
```

The `ChatOptions` has its own parameters, as specified below:
| Parameter | Explanation |
|-----------|-------------|
| newChatButtonBuilder          | Builds the 'New Chat' button, to initiate a new chat session. This button is displayed on the chat overview. |
| messageInputBuilder           | Builds the text input which is displayed within the chat view, responsible for sending text messages. |
| chatRowContainerBuilder       | Builds a chat row. A row with the users' avatar, name and eventually the last massage sended in the chat. This builder is used both in the *chat overview screen* as in the *new chat screen*. |
| imagePickerContainerBuilder   | Builds the container around the ImagePicker. |
| closeImagePickerButtonBuilder | Builds the close button for the Image Picker pop-up window. |
| scaffoldBuilder               | Builds the default Scaffold-widget around the Community Chat. The chat title is displayed within the Scaffolds' title for example. |

The  `ImagePickerTheme` also has its own parameters, how to use these parameters can be found in [the documentation of the flutter_image_picker package](https://github.com/Iconica-Development/flutter_image_picker).

## Issues

Please file any issues, bugs or feature request as an issue on our [GitHub](https://github.com/Iconica-Development/flutter_community_chat/pulls) page. Commercial support is available if you need help with integration with your app or services. You can contact us at [support@iconica.nl](mailto:support@iconica.nl).

## Want to contribute

If you would like to contribute to the plugin (e.g. by improving the documentation, solving a bug or adding a cool new feature), please carefully review our [contribution guide](../CONTRIBUTING.md) and send us your [pull request](https://github.com/Iconica-Development/flutter_community_chat/pulls).

## Author

This `flutter_community_chat` for Flutter is developed by [Iconica](https://iconica.nl). You can contact us at <support@iconica.nl>
