import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pawfectmatch/models/models.dart';


Widget messageInput(
    TextEditingController ctrl, String convoID, String uid, String otherid) {
  return SizedBox(
      height: 50,
      child: TextField(
        controller: ctrl,
        enableSuggestions: true,
        autocorrect: true,
        cursorColor: Colors.white,
        style: TextStyle(color: const Color(0xff011F3F).withOpacity(0.9)),
        decoration: InputDecoration(
          labelText: 'Enter message...',
          suffixIcon: GestureDetector(
            onTap: () {
              // Call a function to send the message
              sendMessage(ctrl.text, convoID, uid, otherid);
              // Clear the text field after sending the message
              ctrl.clear();
            },
            child: const Icon(
              Icons.send_rounded,
              color: Color(0xff011F3F),
            ),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: const BorderSide(width: 0, style: BorderStyle.solid),
          ),
        ),
        keyboardType: TextInputType.multiline,
      ));
}

Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
  try {
    // Query the "messages" subcollection of the specified conversation
    QuerySnapshot messagesSnapshot = await FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp',
            descending: false) // You can adjust the ordering as needed
        .get();

    // Convert the messages to a list of maps
    List<Map<String, dynamic>> messages = messagesSnapshot.docs.map((doc) {
      return {
        'senderId': doc['senderId'],
        'receiverId': doc['receiverId'],
        'messageContent': doc['messageContent'],
        'timestamp': doc['timestamp'],
      };
    }).toList();

    return messages;
  } catch (error) {
    print('Error getting messages: $error');
    rethrow;
  }
}

Widget buildMessageItem(
  Map<String, dynamic> message,
  String uid,
  String otherdogname,
  String otherphoto,
  String mydogname,
  String otheruser,
) {
  var isMyMessage = (message['senderId'] == uid);
  var alignment = isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start;
  var crossAxisAlignment =
      isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;

  // Check if the message content is not 'null'
  var messageContent = message['messageContent'];
  bool shouldShowMessage = messageContent != uid && messageContent != otheruser;

  // Check if there are other messages in the list
  bool hasOtherMessages = message.length > 1;

  return shouldShowMessage
      ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Column(
              crossAxisAlignment: crossAxisAlignment,
              children: [
                Row(
                  mainAxisAlignment: alignment,
                  children: [
                    if (!isMyMessage)
                      CircleAvatar(
                        backgroundImage: NetworkImage(otherphoto),
                        radius: 20,
                      ),
                    SizedBox(width: 8), // Adjust the spacing as needed
                    Column(
                      crossAxisAlignment: crossAxisAlignment,
                      children: [
                        Text(isMyMessage ? mydogname : otherdogname),
                        chatBubble(messageContent, isMyMessage),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        )
      : hasOtherMessages
          ? const SizedBox.shrink()
          : const SizedBox(
              child: Center(
                child: Text('Start a conversation. Say hello!'),
              ),
            );
}

void sendMessage(
    String message, String convoID, String uid, String otherid) async {
  try {
    // Get the reference to the messages subcollection of the conversation
    CollectionReference messagesRef = FirebaseFirestore.instance
        .collection('conversations')
        .doc(convoID)
        .collection('messages');

    // Create a Message object to represent the data
    Message newMessage = Message(
      messageContent: message,
      receiverId: otherid,
      senderId: uid,
      timestamp: Timestamp.now(),
    );

    // Convert the Message object to a Map using the toJson method
    Map<String, dynamic> messageData = newMessage.toJson();

    // Add the message to the subcollection
    DocumentReference messageDocRef = await messagesRef.add(messageData);

    // Get the ID of the last sent message
    String lastMessageId = messageDocRef.id;

    // Update the conversation document with the new lastMessageId
    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(convoID)
        .update({
      'lastMessage': lastMessageId,
    });

    print('Message sent successfully.');
  } catch (e) {
    print('Error sending message: $e');
  }
}

Widget chatBubble(String message, bool isMyMessage) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: isMyMessage ? const Color(0xff006AFF) : Colors.grey,
    ),
    child: Text(message, style: const TextStyle(color: Colors.white)),
  );
}

Stream<QuerySnapshot<Map<String, dynamic>>> messageStream(String convoID) {
  return FirebaseFirestore.instance
      .collection('conversations')
      .doc(convoID)
      .collection('messages')
      .orderBy('timestamp')
      .snapshots();
}

