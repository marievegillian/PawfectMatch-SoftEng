// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:pawfectmatch/controller/chatlist_control.dart';

// class ChatListScreen extends StatefulWidget {
//   const ChatListScreen({Key? key}) : super(key: key);

//   @override
//   State<ChatListScreen> createState() => _ChatListScreenState();
// }

// class _ChatListScreenState extends State<ChatListScreen> {
//   late List<Map<String, dynamic>> conversations = [];
//   late String uid;
//   String otherdoguid = '';
//   String otherUserDogName = '';
//   String otherUserDogPhoto = '';
//   // String lastMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     uid = FirebaseAuth.instance.currentUser!.uid;
//     // Fetch conversations when the widget is initialized
//     fetchConversations();
//   }

//   Future<void> fetchConversations() async {
//     try {
//       conversations = await getConversations(uid);
//       setState(() {}); // Trigger a rebuild with the fetched data
//     } catch (error) {
//       // Handle errors
//       print('Error fetching conversations: $error');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           backgroundColor: const Color(0xff011F3F),
//           title: const Text(
//             "Messages",
//             style: TextStyle(
//               fontWeight: FontWeight.w500,
//               fontSize: 28,
//               color: Colors.white,
//             ),
//           ),
//           centerTitle: true,
//           automaticallyImplyLeading: false,
//         ),
//         body: ListView.builder(
//           itemCount: conversations.length,
//           itemBuilder: (context, index) {
//             return buildConversationItem(conversations[index], uid);
//           },
//         ));
//   }
// }

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawfectmatch/controller/chatlist_control.dart'; // Import DateFormat

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late String uid;
  late Stream<List<Map<String, dynamic>>> conversationsStream;
  late StreamController<List<Map<String, dynamic>>> controller;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    controller = StreamController<List<Map<String, dynamic>>>();
    // Initialize the stream
    conversationsStream = getConversationsStream(uid, controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff011F3F),
        title: const Text(
          "Messages",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: conversationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<Map<String, dynamic>> conversations = snapshot.data ?? [];
            return ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                return buildConversationItem(conversations[index], uid);
              },
            );
          }
        },
      ),
    );
  }
}