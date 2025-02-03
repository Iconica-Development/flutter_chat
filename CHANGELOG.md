## 5.0.0 - WIP
- Removed the default values for the ChatOptions that are now nullable so they resolve to the ThemeData values
- Added chatAlignment to change the alignment of the chat messages
- Added messageType to the ChatMessageModel to allow for different type of messages, it is nullable to remain backwards compatible
- Get the color for the imagepicker from the Theme's primaryColor
- Added chatMessageBuilder to the userstory configuration to customize the chat messages
- Update the default chat message builder to a new design
- Added ChatScope that can be used to get the ChatService and ChatTranslations from the context. If you use individual components instead of the userstory you need to wrap them with the ChatScope. The options and service will be removed from all the component constructors.

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
