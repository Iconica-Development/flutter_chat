## 6.0.0
- Added pending message repository to temporarily store messages that are not yet received by the backend
- Added pending message icons next to time on default messages
- Added pending image uploading by base64encoding the data and putting it in the image url
- Added image pre-loading to handle error and loading states
- Added reload button in case of an image loading error
- Added messageStatus field to MessageModel to differentiate between sent and pending messages

## 5.1.2
- Added correct padding inbetween time indicators and names
- Show names if a new day occurs and an indicator is shown

## 5.1.1
- Expose default indicator builder from the indicator options

## 5.1.0
- Added optional time indicator in chat detail screens to show which day the message is posted

## 5.0.0
- Removed the default values for the ChatOptions that are now nullable so they resolve to the ThemeData values
- Added chatAlignment to change the alignment of the chat messages
- Added messageType to the ChatMessageModel to allow for different type of messages, it is nullable to remain backwards compatible
- Get the color for the imagepicker from the Theme's primaryColor
- Added chatMessageBuilder to the userstory configuration to customize the chat messages
- Update the default chat message builder to a new design
- Added ChatScope that can be used to get the ChatService and ChatTranslations from the context. If you use individual components instead of the userstory you need to wrap them with the ChatScope. The options and service will be removed from all the component constructors.
- Added getAllUsersForChat to UserRepositoryInterface for fetching all users for a chat
- Added flutter_hooks as a dependency for easier state management
- Added FlutterChatDetailNavigatorUserstory that can be used to start the userstory from the chat detail screen without having the chat overview screen
- Changed the ChatDetailScreen to use the chatId instead of the ChatModel, the screen will now fetch the chat from the ChatService
- Changed baseScreenBuilder to include a chatTitle that can be used to show provide the title logic to apps that use the baseScreenBuilder
- Added loadNewMessagesAfter, loadOldMessagesBefore and removed pagination from getMessages in the ChatRepositoryInterface to change pagination behavior to rely on the stream and two methods indicating that more messages should be added to the stream
- Added chatTitleResolver that can be used to resolve the chat title from the chat model or return null to allow for default behavior
- Added ChatPaginationControls to the ChatOptions to allow for more control over the pagination
- Fixed that chat message is automatically sent when the user presses enter on the keyboard in the chat input
- Added sender and chatId to uploadImage in the ChatRepositoryInterface
- Added imagePickerBuilder to the builders in the ChatOptions to override the image picker with a custom implementation that needs to return a Future<Uint8List?>
- Changed the ChatBottomInputSection to be multiline and go from 45px to 120px in height depending on how many lines are in the textfield
- Added chatScreenBuilder to the userstory configuration to customize the specific chat screen with a ChatModel as argument
- Added senderTitleResolver to the ChatOptions to resolve the title of the sender in the chat message
- Added imageProviderResolver to the ChatOptions to resolve ImageProvider for all images in the userstory
- Added enabled boolean to the messageInputBuilder and made parameters named
- Added autoScrollTriggerOffset to the ChatPaginationControls to adjust when the auto scroll should be enabled
- Added the ability to set the color of the CircularProgressIndicator of the ImageLoadingSnackbar by theme.snackBarTheme.actionTextColor
- Added semantics for variable text, buttons and textfields
- Added flag to enable/disable loading new and old messages on scrolling to the end of the current view.
- Updated description of packages to be more descriptive

## 4.0.0
- Move to the new user story architecture

## 3.1.0
- Fix center the texts for no users found with search and type first message
- Fix styling for the whole userstory
- Add groupchat profile picture, and bio to the groupchat creation screen
- Updated profile of users and groups


## 3.0.1

- fix bug where you could make multiple groups quickly by routing back to the previous screen
- fix bug where you would route back to the user selection screen insterad of routing back to the chat overview screen
- Add onPopInvoked callback to the userstory to add custom behaviour for the back button on the chatscreen
- Handle overflows for users with a long name.
- Remove the scaffold backgrounds because they should be inherited from the scaffold theme

## 3.0.0

- Add theming
- add validator for group name
- fix spamming buttons
- fix user list flickering on the group creation screen

## 2.0.0

- Add a serviceBuilder to the userstory configuration
- Add a translationsBuilder to the userstory configuration
- Change onPressUserProfile callback to use a ChatUserModel instead of a String
- Add a enableGroupChatCreation boolean to the userstory configuration to enable or disable group chat creation
- Change the ChatTranslations constructor to require all translations or use the ChatTranslations.empty constructor if you don't want to specify all translations
- Remove the Divider between the users on the new chat screen
- Add option to set a custom padding around the list of chats
- Fix nullpointer when firstWhere returns null because there is only 1 person in a groupchat

## 1.4.3

- Added default styling.
- Fixed groupchats using navigator

## 1.4.2

- Added doc comments
- Fixed bug when creating a group chat with the `LocalChatService`
- Updated readme

## 1.4.1
- Made UI changes to match the Figma design

## 1.4.0
- Add way to create group chats
- Update flutter_profile to 1.3.0
- Update flutter_image_picker to 1.0.5

## 1.3.1

- Added more options for styling the UI.
- Changed the way profile images are shown.
- Added an ontapUser in the chat.
- Changed the way the time is shown in the chat after a message.
- Added option to customize chat title and username chat message widget.

## 1.2.1

- Fixed bug in the LocalChatService

## 1.2.0

- Added linter and workflow

## 1.1.0

- Added LocalChatService for example app

## 1.0.0

- Added pagination for the ChatDetailScreen
- Added routes with Go_router and Navigator
- Added ChatEntryWidget

## 0.6.0 - December 1 2023

- Made the message controller nullable
- Improved chat UI and added showTime option for chatDetailScreen to always show the time

## 0.5.0 - November 29 2023

- Added the option to add your own dialog on chat delete and addded the option to make the chat not deletable

## 0.4.2 - November 24 2023

- Fix groupchats seen as personal chat when there are unread messages

## 0.4.1 - November 22 2023

- Add groupName for groupchat avatarbuilder

## 0.4.0 - November 6 2023

- Show amount of unread messages per chat
- More intuitive chat UI
- Fix default profile avatars

## 0.3.4 - October 25 2023

- Add interface methods for getting amount of unread messages

## 0.3.3 - October 10 2023

- Add icon color property for icon buttons

## 0.3.2 - September 26 2023

- Fix fullname getter for nullable values

## 0.3.1 - July 11 2023

- Removed image message when there is no last message in a chat

## 0.3.0 - March 31 2023

- Added support for group chats

## 0.0.1 - October 17th 2022

- Initial release
