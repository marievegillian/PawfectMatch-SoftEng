import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String messageContent;
  String receiverId;
  String senderId;
  Timestamp timestamp;

  Message({
    required this.messageContent,
    required this.receiverId,
    required this.senderId,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageContent: json['messageContent'] ?? '',
      receiverId: json['receiverId'] ?? '',
      senderId: json['senderId'] ?? '',
      timestamp: json['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageContent': messageContent,
      'receiverId': receiverId,
      'senderId': senderId,
      'timestamp': timestamp,
    };
  }
}
