// promptmessages_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PromptMessage {
  final String messageContent;
  final Timestamp timestamp;
  final String userID;

  PromptMessage({
    required this.messageContent,
    required this.timestamp,
    required this.userID,
  });

  factory PromptMessage.fromJson(Map<String, dynamic> json) {
    return PromptMessage(
      messageContent: json['messageContent'],
      timestamp: json['timestamp'],
      userID: json['userID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageContent': messageContent,
      'timestamp': timestamp,
      'userID': userID,
    };
  }
}
