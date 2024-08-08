import 'package:pawfectmatch/models/models.dart';

class PromptBot {
  String lastMessageId;
  String dogId;
  List<Message> messages;

  PromptBot({
    required this.lastMessageId,
    required this.dogId,
    required this.messages, //unsure if it will be included
  });

  factory PromptBot.fromJson(Map<String, dynamic> json) {
    // Assuming 'messages' is a List<Map<String, dynamic>> in the JSON
    List<dynamic> rawMessages = json['messages'] ?? [];
    List<Message> parsedMessages =
        rawMessages.map((message) => Message.fromJson(message)).toList();

    return PromptBot(
      lastMessageId: json['lastMessageId'] ?? '',
      dogId: json['dogId'] ?? '',
      messages: parsedMessages,
    );
  }
}