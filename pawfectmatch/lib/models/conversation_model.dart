
import 'package:pawfectmatch/models/models.dart';

class Conversation {
  String lastMessageId;
  String user1Id;
  String user2Id;
  List<Message> messages;

  Conversation({
    required this.lastMessageId,
    required this.user1Id,
    required this.user2Id,
    required this.messages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    // Assuming 'messages' is a List<Map<String, dynamic>> in the JSON
    List<dynamic> rawMessages = json['messages'] ?? [];
    List<Message> parsedMessages =
        rawMessages.map((message) => Message.fromJson(message)).toList();

    return Conversation(
      lastMessageId: json['lastMessageId'] ?? '',
      user1Id: json['user1Id'] ?? '',
      user2Id: json['user2Id'] ?? '',
      messages: parsedMessages,
    );
  }
}