/*
// import 'package:dialogflow_flutter/dialogflow_flutter.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class PromptBotController {
//   Dialogflow _dialogflow;

//   PromptBotController() {
//     _initializeDialogflow();
//   }

//   void _initializeDialogflow() async {
//     AuthGoogle authGoogle = await AuthGoogle(fileJson: "path/to/your/credentials.json").build();
//     _dialogflow = Dialogflow(authGoogle: authGoogle, language: Language.english);
//   }

//   Future<String> handleUserMessage(String text) async {
//     AIResponse response = await _dialogflow.detectIntent(text);
//     String preference = response.getMessage() ?? '';

//     // Query the database for dog profiles based on the preference
//     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//         .collection('dog_profiles')
//         .where('preferences', arrayContains: preference)
//         .get();

//     List<dynamic> suggestions = querySnapshot.docs.map((doc) => doc['name']).toList();
//     return suggestions.isNotEmpty
//         ? 'Here are some dogs you might like: ${suggestions.join(', ')}'
//         : 'No matching dogs found.';
//   }
// }
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pawfectmatch/models/models.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dog_profile.dart';
/*
class PromptBotController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /*
  Future<void> sendUserMessage(String message, String userID) async {
    try {
      Map<String, dynamic> userMessage = PromptMessage(
        messageContent: message,
        timestamp: Timestamp.now(),
        userID: userID,
      ).toJson();

      await _firestore.collection('promptConversations').doc(userID).collection('messages').add(userMessage);

      await _firestore.collection('promptConversations').doc(userID).update({
        'lastMessage': message,
      });
    } catch (e) {
      print('Error sending user message: $e');
    }
  }*/
  Future<void> sendUserMessage(String message, String convoID, String userID) async {
  try {
    // Get the reference to the user's conversation document
    DocumentReference convoDocRef = _firestore.collection('promptConversations').doc(convoID);

    // Check if the document exists
    DocumentSnapshot convoDoc = await convoDocRef.get();

    if (!convoDoc.exists) {
      // If the document does not exist, create it
      await convoDocRef.set({
        'userID': userID,
        'lastMessage': message,
      });
    } else {
      // If the document exists, update the lastMessage field
      await convoDocRef.update({
        'lastMessage': message,
      });
    }

    // Add the user's message to the messages subcollection
    Map<String, dynamic> userMessage = PromptMessage(
      messageContent: message,
      timestamp: Timestamp.now(),
      userID: userID,
    ).toJson();

    await convoDocRef.collection('messages').add(userMessage);

  } catch (e) {
    print('Error sending user message: $e');
  }
}

  /*
  Future<void> sendBotReply(String reply, String userID) async {
    try {
      Map<String, dynamic> botReply = PromptMessage(
        messageContent: reply,
        timestamp: Timestamp.now(),
        userID: '100', // Bot userID
      ).toJson();

      await _firestore.collection('promptConversations').doc(userID).collection('messages').add(botReply);

      await _firestore.collection('promptConversations').doc(userID).update({
        'lastMessage': reply,
      });
    } catch (e) {
      print('Error sending bot reply: $e');
    }
  }*/
    
  Future<void> sendBotReply(String reply, String convoID, String userID) async {
  try {
    // Get the reference to the user's conversation document
    DocumentReference convoDocRef = _firestore.collection('promptConversations').doc(convoID);

    // Check if the document exists
    DocumentSnapshot convoDoc = await convoDocRef.get();

    if (!convoDoc.exists) {
      // If the document does not exist, create it
      await convoDocRef.set({
        'userID': userID,
        'lastMessage': reply,
      });
    } else {
      // If the document exists, update the lastMessage field
      await convoDocRef.update({
        'lastMessage': reply,
      });
    }

    // Add the bot's reply to the messages subcollection
    Map<String, dynamic> botReply = PromptMessage(
      messageContent: reply,
      timestamp: Timestamp.now(),
      userID: '100', // Bot userID
    ).toJson();

    await convoDocRef.collection('messages').add(botReply);

  } catch (e) {
    print('Error sending bot reply: $e');
  }
}


}
*/

class PromptBotController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<PromptMessage>> getMessages(String userID) async {
    try {
      // Assuming you have a collection 'conversations' with documents for each user
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('promptConversations')
          .doc(userID)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      // Map the snapshot data to List<PromptMessage>
      List<PromptMessage> messages = snapshot.docs.map((doc) {
        return PromptMessage.fromJson(doc.data());
      }).toList();

      return messages;
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  Future<void> sendUserMessage(String message, String userID) async {
    try {
      final conversationRef = FirebaseFirestore.instance
          .collection('promptConversations')
          .doc(userID); // Check for user's document

      // Fetch the document to determine if it exists
      DocumentSnapshot docSnapshot = await conversationRef.get();

      if (docSnapshot.exists) {
        // Document exists, update it with new message
        await conversationRef.collection('messages').add({
          'messageContent': message,
          'timestamp': Timestamp.now(),
          'userID': userID,
        });
      } else {
        // Document does not exist, create a new document and add the message
        await conversationRef.set({
          'lastMessage': message,
          'userID': userID,
        });
        await conversationRef.collection('messages').add({
          'messageContent': message,
          'timestamp': Timestamp.now(),
          'userID': userID,
        });
      }
    } catch (e) {
      print('Error sending user message: $e');
    }
  }

  Future<void> sendBotReply(String botReply, String userID) async {
    try {
      final conversationRef = FirebaseFirestore.instance
          .collection('promptConversations')
          .doc(userID); // Check for user's document

      // Fetch the document to determine if it exists
      DocumentSnapshot docSnapshot = await conversationRef.get();

      if (docSnapshot.exists) {
        // Document exists, update it with the bot reply
        await conversationRef.collection('messages').add({
          'messageContent': botReply,
          'timestamp': Timestamp.now(),
          'userID': '100', // Assume '100' is the bot's ID
        });
      } else {
        // Document does not exist, create a new document and add the bot reply
        await conversationRef.set({
          'lastMessage': botReply,
          'userID': userID,
        });
        await conversationRef.collection('messages').add({
          'messageContent': botReply,
          'timestamp': Timestamp.now(),
          'userID': '100', // Assume '100' is the bot's ID
        });
      }
    } catch (e) {
      print('Error sending bot reply: $e');
    }
  }

  Future<List<DogProfile>> fetchDogProfiles(String userInput) async {
    final url = 'http://127.0.0.1:5000/filter_dogs';
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'input': userInput}),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // Assuming the AI returns a list of dog profiles in JSON
      return data.map((json) => DogProfile.fromJson(json)).take(3).toList();
    } else {
      throw Exception('Failed to load dog profiles');
    }
  }
}
