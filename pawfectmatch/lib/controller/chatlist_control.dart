import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pawfectmatch/screens/screens.dart';

// Future<List<Map<String, dynamic>>> getConversations(String loggedUserId) async {
//   try {
//     // Query the "conversations" collection where the logged user's ID matches either user1 or user2
//     QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance
//         .collection('conversations')
//         .where('user1', isEqualTo: loggedUserId)
//         .get();

//     List<Map<String, dynamic>> conversations1 =
//         await Future.wait(querySnapshot1.docs.map((doc) async {
//       // Get the last message from the 'messages' subcollection
//       QuerySnapshot messagesSnapshot = await doc.reference
//           .collection('messages')
//           .orderBy('timestamp', descending: true)
//           .limit(1)
//           .get();

//       String lastMessage = '';
//       String formattedTimestamp = '';
//       if (messagesSnapshot.docs.isNotEmpty) {
//         lastMessage = messagesSnapshot.docs.first['messageContent'];
//         Timestamp timestamp = messagesSnapshot.docs.first['timestamp'];
//         // Convert Timestamp to DateTime
//         DateTime dateTime = timestamp.toDate();
//         // Format DateTime as desired (in 12-hour clock format with AM/PM)
//         formattedTimestamp = DateFormat('jm').format(dateTime);
//       }

//       return {
//         'conversationId': doc.id,
//         'otherUserId': doc['user2'],
//         'lastMessage': lastMessage,
//         'timestamp': formattedTimestamp,
//       };
//     }).toList());

//     // Query again for conversations where the logged user's ID matches user2
//     QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
//         .collection('conversations')
//         .where('user2', isEqualTo: loggedUserId)
//         .get();

//     List<Map<String, dynamic>> conversations2 =
//         await Future.wait(querySnapshot2.docs.map((doc) async {
//       // Get the last message from the 'messages' subcollection
//       QuerySnapshot messagesSnapshot = await doc.reference
//           .collection('messages')
//           .orderBy('timestamp', descending: true)
//           .limit(1)
//           .get();

//       String lastMessage = '';
//       String formattedTimestamp = '';

//       if (messagesSnapshot.docs.isNotEmpty) {
//         lastMessage = messagesSnapshot.docs.first['messageContent'];
//         Timestamp timestamp = messagesSnapshot.docs.first['timestamp'];
//         // Convert Timestamp to DateTime
//         DateTime dateTime = timestamp.toDate();
//         // Format DateTime as desired (in 12-hour clock format with AM/PM)
//         formattedTimestamp = DateFormat('jm').format(dateTime);
//       }

//       return {
//         'conversationId': doc.id,
//         'otherUserId': doc['user1'],
//         'lastMessage': lastMessage,
//         'timestamp': formattedTimestamp,
//       };
//     }).toList());

//     // Combine the results from both queries
//     List<Map<String, dynamic>> conversations = [
//       ...conversations1,
//       ...conversations2
//     ];

//     return conversations;
//   } catch (error) {
//     print('Error getting conversations: $error');
//     rethrow;
//   }
// }

Future<Map<String, String>> fetchOtherDogData(String otherDogId) async {
  try {
    DocumentSnapshot dogSnapshot = await FirebaseFirestore.instance
        .collection('dogs')
        .doc(otherDogId)
        .get();

    String dogName = dogSnapshot['name'];
    String dogPhoto = dogSnapshot['profilepicture'];

    String ownerId = dogSnapshot['owner'];

    DocumentSnapshot ownerSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(ownerId)
        .get();

    String ownerName = ownerSnapshot['username'];

    return {'name': dogName, 'photo': dogPhoto, 'ownername': ownerName};
  } catch (e) {
    print('Error fetching dog data: $e');
    return {'name': '', 'photo': ''}; // Handle the error appropriately
  }
}

Future<Map<String, String>> fetchMyDogData(String activeDogId) async {
  try {
    DocumentSnapshot dogSnapshot = await FirebaseFirestore.instance
        .collection('dogs')
        .doc(activeDogId)
        .get();

    String dogName = dogSnapshot['name'];
    // String dogPhoto = dogSnapshot['profilepicture'];

    return {'name': dogName};
  } catch (e) {
    print('Error fetching dog data: $e');
    return {'name': '', 'photo': ''};
  }
}

Widget buildConversationItem(Map<String, dynamic> conversation, String activeDogId) {
  return FutureBuilder(
    // future: fetchOtherDogData(conversation['otherUserId']),
    future: Future.wait([
      fetchOtherDogData(conversation['otherUserId']),  // Fetch other dog data
      fetchMyDogData(activeDogId),  // Fetch your dog data
    ]),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        // Map<String, String> dogData = snapshot.data as Map<String, String>;
        Map<String, String> otherDogData = snapshot.data![0];
        Map<String, String> myDogData = snapshot.data![1];

        return Container(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            leading: SizedBox(
              width: 60,
              height: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(500),
                child: Image.network(
                  otherDogData['photo'] ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  otherDogData['name'] ?? '',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500),
                ),
                Text(
                  "${conversation['timestamp']}", // Replace 'timestamp' with the actual field name
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            subtitle: conversation['lastMessage'] == activeDogId ||
                    conversation['lastMessage'] == conversation['otherUserId']
                ? const Text(
                    "Start a conversation. Say hello!",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  )
                : Text(
                    conversation['lastMessage'] ?? '',
                    maxLines: 1, // Limit to one line
                    overflow: TextOverflow.ellipsis, // Add ellipses at the end
                  ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    myDogId: activeDogId,
                    myDogName: myDogData['name'] ?? '',
                    otherDogName: otherDogData['name'] ?? '',
                    otherDogPhotoUrl: otherDogData['photo'] ?? '',
                    otherOwnerName: otherDogData['ownername'] ?? '',
                    convoID: conversation['conversationId'],
                    otherUser: conversation['otherUserId'], //this is the dog id
                  ),
                ),
              );
            },
          ),
        );
      } else {
        return const ListTile(
          title: Text('Loading...'),
          leading: CircularProgressIndicator(),
        );
      }
    },
  );
}

Future<void> createConversation(String user1Id, String user2Id) async {
  try {
    // Check if a conversation already exists in 'user1'
    QuerySnapshot existingConversations1 = await FirebaseFirestore.instance
        .collection('conversations')
        .where('user1', isEqualTo: user1Id)
        .where('user2', isEqualTo: user2Id)
        .get();

    QuerySnapshot existingConversations2 = await FirebaseFirestore.instance
        .collection('conversations')
        .where('user1', isEqualTo: user2Id)
        .where('user2', isEqualTo: user1Id)
        .get();

    if (existingConversations1.docs.isEmpty &&
        existingConversations2.docs.isEmpty) {
      // If no conversation exists between the two, create a new conversation
      DocumentReference conversationRef =
          FirebaseFirestore.instance.collection('conversations').doc();

      // Create a messages subcollection inside the conversation
      CollectionReference messagesRef = conversationRef.collection('messages');

      // Add an initial message
      DocumentReference initialMessageRef = await messagesRef.add({
        'senderId': user1Id,
        'receiverId': user2Id,
        'messageContent': user1Id,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Get the ID of the initial message
      String initialMessageId = initialMessageRef.id;

      // Add conversation details with the initial message ID as lastMessage
      await conversationRef.set({
        'user1': user1Id,
        'user2': user2Id,
        'lastMessage': initialMessageId,
        // Add any other details you want to store about the conversation
      });

      print('Conversation created successfully.');
    } else {
      print('Conversation already exists.');
    }
  } catch (e) {
    print('Error creating conversation: $e');
  }
}

Stream<List<Map<String, dynamic>>> getConversationsStream(String loggedDogId,
    StreamController<List<Map<String, dynamic>>> controller) {
  try {
    // Create a function to add conversations to the stream
    void addConversationsToStream() async {
      List<Map<String, dynamic>> conversations1 =
          await getConversationsForUser(loggedDogId, 'user1');
      List<Map<String, dynamic>> conversations2 =
          await getConversationsForUser(loggedDogId, 'user2');

      // Combine the results from both queries
      List<Map<String, dynamic>> conversations = [
        ...conversations1,
        ...conversations2
      ];

      // Add conversations to the stream
      controller.add(conversations);
    }

    // Listen to snapshots for user1
    FirebaseFirestore.instance
        .collection('conversations')
        .where('user1', isEqualTo: loggedDogId)
        .snapshots()
        .listen((_) => addConversationsToStream());

    // Listen to snapshots for user2
    FirebaseFirestore.instance
        .collection('conversations')
        .where('user2', isEqualTo: loggedDogId)
        .snapshots()
        .listen((_) => addConversationsToStream());
  } catch (error) {
    print('Error getting conversations: $error');
    rethrow;
  }

  return controller.stream;
}

Future<List<Map<String, dynamic>>> getConversationsForUser(
    String dogId, String field) async {
  // Query conversations based on the specified field (user1 or user2)
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('conversations')
      .where(field, isEqualTo: dogId)
      .get();

  return await Future.wait(querySnapshot.docs.map((doc) async {
    // Your existing logic for conversations
    QuerySnapshot messagesSnapshot = await doc.reference
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    String lastMessage = '';
    String formattedTimestamp = '';

    if (messagesSnapshot.docs.isNotEmpty) {
      var data = messagesSnapshot.docs.first.data() as Map<String, dynamic>;
      // Check if "messageContent" exists in the data
      if (data!.containsKey('messageContent')) {
        lastMessage = data?['messageContent'];
      }

      // Similarly, check for other fields like 'timestamp' and handle them accordingly

      Timestamp timestamp = data?['timestamp'];
      // Convert Timestamp to DateTime
      DateTime dateTime = timestamp.toDate();
      // Format DateTime as desired (in 12-hour clock format with AM/PM)
      formattedTimestamp = DateFormat('jm').format(dateTime);
    }

    return {
      'conversationId': doc.id,
      'otherUserId': field == 'user1' ? doc['user2'] : doc['user1'],
      'lastMessage': lastMessage,
      'timestamp': formattedTimestamp,
    };
  }).toList());
}
