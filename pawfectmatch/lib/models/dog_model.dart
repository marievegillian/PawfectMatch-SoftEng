import 'dart:typed_data';

import 'package:intl/intl.dart';

class Dog {
  String dogId;
  String bio;
  String birthday;
  String breed;
  bool isMale;
  bool isVaccinated;
  // String medID;
  String name;
  String owner;
  String profilePicture;
  // Uint8List? profilePicture;
  double avgRating;
  List<Map<String,dynamic>> vaccines; 
  String? purpose;
  List<String>? activities;
  List<String> likedDogs; // New field for storing liked dog IDs
  List<String> blockedUsers; 

  Dog({
    required this.dogId,
    required this.bio,
    required this.birthday,
    required this.breed,
    required this.isMale,
    required this.isVaccinated,
    // required this.medID,
    required this.name,
    required this.owner,
    required this.profilePicture,
    required this.avgRating,
    this.purpose,
    this.activities = const [],    
    this.vaccines = const [],
    this.likedDogs = const [], // Initialize with an empty list
    this.blockedUsers= const [], // Initialize with an empty list
  });

  factory Dog.fromJson(Map<String, dynamic> json) {
    return Dog(
      dogId: json['dogId'] ?? '',
      bio: json['bio'] ?? '',
      birthday: json['birthday'] ?? '',
      breed: json['breed'] ?? '',
      isMale: json['isMale'] ?? false,
      isVaccinated: json['isVaccinated'] ?? false,
      name: json['name'] ?? '',
      owner: json['owner'] ?? '',
      profilePicture: json['profilepicture'] ?? '',
      avgRating: (json['avgRating'] ?? 0).toDouble(),
      purpose: json['purpose'] ?? '',
      activities: List<String>.from(json['activities'] ?? []),
      vaccines: List<Map<String,dynamic>>.from(json['vaccines'] ?? []),
      likedDogs: List<String>.from(json['likedDogs'] ?? []),
      blockedUsers: List<String>.from(json['blockedUsers'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dogId':dogId,
      'bio': bio,
      'birthday': birthday,
      'breed': breed,
      'isMale': isMale,
      'isVaccinated': isVaccinated,
      // 'medID': medID, //medID field is removed, but commented for now
      'name': name,
      'owner': owner,
      'profilepicture': profilePicture,
      'avgRating': avgRating,
      'purpose': purpose,
      'activities':activities,
      'vaccines': vaccines,
      'likedDogs': likedDogs,
      'blockedUsers': blockedUsers,
    };
  }
  
  int calculateAge() {
    DateTime now = DateTime.now();    
    DateTime birthDate = DateTime.parse(birthday);
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}