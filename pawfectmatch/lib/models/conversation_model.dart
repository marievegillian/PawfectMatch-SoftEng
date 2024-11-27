
import 'package:pawfectmatch/models/models.dart';

class Conversation {
  String lastMessageId;
  String dog1Id;
  String dog2Id;
  List<Message> messages;

  Conversation({
    required this.lastMessageId,
    required this.dog1Id,
    required this.dog2Id,
    required this.messages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    // Assuming 'messages' is a List<Map<String, dynamic>> in the JSON
    List<dynamic> rawMessages = json['messages'] ?? [];
    List<Message> parsedMessages =
        rawMessages.map((message) => Message.fromJson(message)).toList();

    return Conversation(
      lastMessageId: json['lastMessageId'] ?? '',
      dog1Id: json['dog1Id'] ?? '',
      dog2Id: json['dog2Id'] ?? '',
      messages: parsedMessages,
    );
  }
}