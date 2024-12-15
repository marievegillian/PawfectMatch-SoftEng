import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawfectmatch/controller/chat_control.dart';

import '../models/models.dart';
// import 'package:pawfectmatch/screens/appointment_screen.dart';

class ChatScreen extends StatefulWidget {
  final String myDogId;
  final String myDogName;
  final String otherDogName;
  final String otherDogPhotoUrl;
  final String otherOwnerName;
  final String convoID;
  final String otherUser;

  const ChatScreen(
      {super.key,
      required this.myDogId,
      required this.myDogName,
      required this.otherDogName,
      required this.otherDogPhotoUrl,
      required this.otherOwnerName,
      required this.convoID,
      required this.otherUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String uid;
  String otherusername = '';
  String dogName = '';
  final TextEditingController _msgTxtCtrl = TextEditingController();
  late List<Map<String, dynamic>> messages = [];
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;   
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff011F3F),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.otherDogPhotoUrl),
              radius: 18,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherDogName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${widget.otherOwnerName}\'s dog',
                  // widget.ownerName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: messageStream(widget.convoID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                // Convert the snapshot data to a list of messages
                List<Map<String, dynamic>> messages =
                    snapshot.data!.docs.map((doc) => doc.data()).toList();

                // Scroll to the bottom after the ListView is built
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollController
                      .jumpTo(_scrollController.position.maxScrollExtent);
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return buildMessageItem(
                      messages[index],
                      // uid,
                      widget.myDogId,
                      widget.otherDogName,
                      widget.otherDogPhotoUrl,
                      widget.myDogName,
                      widget.otherUser,
                    );
                  },
                );
              },
            ),
          ),
          messageInput(_msgTxtCtrl, widget.convoID, widget.myDogId, widget.otherUser), 
        ],
      ),
    );
  }
}