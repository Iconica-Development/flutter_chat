import 'package:flutter/material.dart';
import 'package:flutter_chat/flutter_chat.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: chatNavigatorUserStory(context,
            configuration: ChatUserStoryConfiguration(
                chatService: LocalChatService(),
                chatOptionsBuilder: (ctx) => ChatOptions(
                      noChatsPlaceholderBuilder: (translations) =>
                          Text(translations.noUsersFound),
                    ))));
  }
}
