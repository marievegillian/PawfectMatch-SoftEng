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
