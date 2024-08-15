import 'package:pawfectmatch/models/models.dart';
/*
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
}*/

// promptbot_model.dart
import 'promptmessages_model.dart';

class PromptBot {
  String lastMessageId;
  List<PromptMessage> messages;

  PromptBot({
    required this.lastMessageId,
    required this.messages,
  });

  factory PromptBot.fromJson(Map<String, dynamic> json) {
    List<dynamic> rawMessages = json['messages'] ?? [];
    List<PromptMessage> parsedMessages =
        rawMessages.map((message) => PromptMessage.fromJson(message)).toList();

    return PromptBot(
      lastMessageId: json['lastMessageId'] ?? '',
      messages: parsedMessages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastMessageId': lastMessageId,
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }
}
