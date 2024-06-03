import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawfectmatch/controller/chat_control.dart';
import 'package:pawfectmatch/screens/appointment_screen.dart';

class ChatScreen extends StatefulWidget {
  final String otherDogName;
  final String otherDogPhotoUrl;
  final String convoID;
  final String otherUser;

  const ChatScreen(
      {super.key,
      required this.otherDogName,
      required this.otherDogPhotoUrl,
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

  Future<void> fetchUserData(otheruid) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(otheruid)
          .get();

      // Extract the data from the document snapshot
      otherusername = userSnapshot['username'];

      setState(() {});
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> fetchConversations() async {
    try {
      messages = await getMessages(widget.convoID);
      setState(() {});
    } catch (error) {
      print('Error fetching conversations: $error');
    }
  }

  Future<void> fetchDogData(String ownerUid) async {
    try {
      QuerySnapshot dogSnapshot = await FirebaseFirestore.instance
          .collection('dogs')
          .where('owner', isEqualTo: ownerUid)
          .get();

      if (dogSnapshot.docs.isNotEmpty) {
        DocumentSnapshot dogData = dogSnapshot.docs.first;
        dogName = dogData['name'];
        setState(() {});
      }
    } catch (e) {
      print('Error fetching dog data: $e');
    }
  }



  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    fetchUserData(widget.otherUser);
    fetchConversations();
    fetchDogData(uid);
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
                  '$otherusername\'s dog',
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
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to the appointment screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppointmentScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(9),
              ),
              icon: const Icon(
                Icons.calendar_today_rounded,
                color: Color(0xff011F3F),
              ),
              label: const Text(
                'Set Schedule',
                style: TextStyle(
                  color: Color(0xff011F3F),
                ),
              ),
            ),
          ),
        ],
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
                      uid,
                      widget.otherDogName,
                      widget.otherDogPhotoUrl,
                      dogName,
                      widget.otherUser,
                    );
                  },
                );
              },
            ),
          ),
          messageInput(_msgTxtCtrl, widget.convoID, uid, widget.otherUser),
        ],
      ),
    );
  }
}