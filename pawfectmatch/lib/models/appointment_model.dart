
import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String user;
  final Timestamp date;
  final String dog;
  final String status;

  Appointment({
    required this.id,
    required this.user,
    required this.date,
    required this.dog,
    required this.status
  });

    factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      user: json['user'] ?? '',
      dog: json['dog'] ?? '',
      status: json['status'] ?? '',
      date: json['dateTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'dog': dog,
      'status': status,
      'dateTime': date,
    };
  }
}