import 'package:pawfectmatch/models/dog_model.dart'; // Import Dog model

class Match {
  final String id;
  final String matchedDogId;
  final String matchedDogName; // Include the dog's name
  final DateTime appointmentDateTime;
  final bool isCompleted;
  final bool isCanceled;

  Match({
    required this.id,
    required this.matchedDogId,
    required this.matchedDogName,
    required this.appointmentDateTime,
    required this.isCompleted,
    required this.isCanceled,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      matchedDogId: json['matchedDogId'],
      matchedDogName: json['matchedDogName'],
      appointmentDateTime: DateTime.parse(json['appointmentDateTime']),
      isCompleted: json['isCompleted'],
      isCanceled: json['isCanceled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchedDogId': matchedDogId,
      'matchedDogName': matchedDogName,
      'appointmentDateTime': appointmentDateTime.toIso8601String(),
      'isCompleted': isCompleted,
      'isCanceled': isCanceled,
    };
  }

  Match copyWith({String? matchedDogName}) {
    return Match(
      id: id,
      matchedDogId: matchedDogId,
      matchedDogName: matchedDogName ?? this.matchedDogName,
      appointmentDateTime: appointmentDateTime,
      isCompleted: isCompleted,
      isCanceled: isCanceled,
    );
  }
}
