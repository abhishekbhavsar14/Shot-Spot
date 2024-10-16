import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<types.Message> _messages = [];
  late types.User _user;  // Now it's late-initialized
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _loadMessages();
  }

  void _initializeUser() {
    // Check if FirebaseAuth has a current user, otherwise use a dummy user
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      _user = types.User(id: currentUser.uid);
    } else {
      _user = types.User(id: 'dummy_user', firstName: 'Dummy', lastName: 'User');
    }
  }

  void _loadMessages() {
    FirebaseFirestore.instance
        .collection('chats')
        .doc('chat_id')
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      final messages = snapshot.docs.map((doc) {
        final data = doc.data();
        return types.TextMessage(
          id: doc.id,
          author: types.User(id: data['userId']),
          text: data['text'],
          createdAt: (data['timestamp'] as Timestamp).millisecondsSinceEpoch,
        );
      }).toList();

      setState(() {
        _messages = messages;
      });
    });
  }

  void _sendMessage(String text) {
    final message = {
      'text': text,
      'userId': _user.id,  // Use the dummy user ID if no real user
      'timestamp': FieldValue.serverTimestamp(),
    };

    FirebaseFirestore.instance
        .collection('chats')
        .doc('chat_id')
        .collection('messages')
        .add(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Chat(
        theme:  DefaultChatTheme(
    primaryColor: Colors.green,  // Change background color of sent messages
    inputBackgroundColor: Colors.amber, // Input area background
    inputTextColor: Colors.black,       // Text color in input area
    sentMessageBodyTextStyle: TextStyle(
    color: Colors.white,   // Text color for sent messages
    ),
        ),
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
      ),
    );
  }

  void _handleSendPressed(types.PartialText message) {
    _sendMessage(message.text);
  }
}
