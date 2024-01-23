import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/flutter_chat.dart';
import 'package:flutter_chat_firebase/flutter_chat_firebase.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      // Set your firebase app here
      // options: FirebaseOptions(apiKey: 'apiKey', appId: 'appId', messagingSenderId: 'messagingSenderId', projectId: 'projectId')
      );

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

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    FirebaseAuth.instance.signInWithEmailAndPassword(
        email: 'your email', password: 'your password');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomRight,
              child: ChatEntryWidget(
                chatService: FirebaseChatService(),
                onTap: _onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => chatNavigatorUserStory(
            ChatUserStoryConfiguration(
              chatService: FirebaseChatService(),
              chatOptionsBuilder: (ctx) => const ChatOptions(),
            ),
            context),
      ),
    );
  }
}
