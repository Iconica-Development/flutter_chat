import "package:chat_repository_interface/src/models/chat_model.dart";
import "package:chat_repository_interface/src/models/message_model.dart";
import "package:chat_repository_interface/src/models/user_model.dart";

/// The chunkSize for the LocalChatRepository
const int chunkSize = 10;

/// All the chats of the local memory database
final List<ChatModel> chats = [];

/// All the messages of the local memory database mapped by chat id
final Map<String, List<MessageModel>> chatMessages = {};

/// All the users of the local memory database
final List<UserModel> users = [
  const UserModel(
    id: "1",
    firstName: "John",
    lastName: "Doe",
    imageUrl: "https://picsum.photos/200/300",
  ),
  const UserModel(
    id: "2",
    firstName: "Jane",
    lastName: "Doe",
    imageUrl: "https://picsum.photos/200/300",
  ),
  const UserModel(
    id: "3",
    firstName: "Frans",
    lastName: "Timmermans",
    imageUrl: "https://picsum.photos/200/300",
  ),
  const UserModel(
    id: "4",
    firstName: "Hendrik-Jan",
    lastName: "De derde",
    imageUrl: "https://picsum.photos/200/300",
  ),
];
