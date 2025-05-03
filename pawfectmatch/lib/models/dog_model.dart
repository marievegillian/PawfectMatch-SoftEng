/*
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

  String fetchGender(){
    if(!isMale){
      return 'Female';
    }
    return 'Male';
  }  
}*/

import 'dart:math';

class Dog {
  String dogId;
  String bio;
  String birthday;
  String breed;
  String size;
  bool isMale;
  bool isVaccinated;
  String name;
  String owner;
  String profilePicture;
  double avgRating;
  double similarity = 0.0;
  List<Map<String, dynamic>> vaccines;
  String? purpose;
  List<String>? activities;
  List<String> likedDogs;
  List<String> blockedUsers;
  //List<double>? tasteProfile; // New field
  
  Dog({
    required this.dogId,
    required this.bio,
    required this.birthday,
    required this.breed,
    required this.size,
    required this.isMale,
    required this.isVaccinated,
    required this.name,
    required this.owner,
    required this.profilePicture,
    required this.avgRating,
    this.purpose,
    this.activities = const [],
    this.vaccines = const [],
    this.likedDogs = const [],
    this.blockedUsers = const [],
    //this.tasteProfile, // Initialize tasteProfile
  });

  factory Dog.fromJson(Map<String, dynamic> json) {
    return Dog(
      dogId: json['dogId'] ?? '',
      bio: json['bio'] ?? '',
      birthday: json['birthday'] ?? '',
      breed: json['breed'] ?? '',
      size: json['size'] ?? 'medium',
      isMale: json['isMale'] ?? false,
      isVaccinated: json['isVaccinated'] ?? false,
      name: json['name'] ?? '',
      owner: json['owner'] ?? '',
      profilePicture: json['profilepicture'] ?? '',
      avgRating: (json['avgRating'] ?? 0).toDouble(),
      purpose: json['purpose'] ?? '',
      activities: List<String>.from(json['activities'] ?? []),
      vaccines: List<Map<String, dynamic>>.from(json['vaccines'] ?? []),
      likedDogs: List<String>.from(json['likedDogs'] ?? []),
      blockedUsers: List<String>.from(json['blockedUsers'] ?? []),
      //tasteProfile: List<double>.from(json['tasteProfile'] ?? []), // Convert Firestore data
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dogId': dogId,
      'bio': bio,
      'birthday': birthday,
      'breed': breed,
      'size': size,
      'isMale': isMale,
      'isVaccinated': isVaccinated,
      'name': name,
      'owner': owner,
      'profilepicture': profilePicture,
      'avgRating': avgRating,
      'purpose': purpose,
      'activities': activities,
      'vaccines': vaccines,
      'likedDogs': likedDogs,
      'blockedUsers': blockedUsers,
      //'tasteProfile': tasteProfile, // Store in Firestore
    };
  }

  int get sizeNumeric {
    return {'small': 1, 'medium': 2, 'large': 3}[size] ?? 0;
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

  String fetchGender() {
    return isMale ? 'Male' : 'Female';
  }

  // Activity vectors (fixed)
  static const Map<String, List<double>> activityVectors = {
    "hiking": [1, 0, 0, 0, 5, 1],
    "walks": [1, 0, 0, 0, 3, 3],
    "playing catch": [1, 1, 0, 0, 4, 2],
    "swimming": [1, 0, 0, 0, 5, 2],
    "gobbling on treats": [0, 0, 1, 0, 1, 5],
    "performing tricks": [0, 0, 0, 1, 2, 3],
    "tug of war": [0, 1, 0, 0, 4, 2],
    "agility courses": [1, 1, 0, 1, 5, 2],
    "chasing": [1, 1, 0, 0, 5, 1],
    "digging": [1, 0, 0, 1, 3, 2],
    "cuddling": [0, 0, 1, 0, 0, 5],
    "fetching": [1, 1, 0, 0, 4, 2],
    "scent tracking": [0, 0, 0, 1, 2, 3],
    "running": [1, 0, 0, 0, 5, 1],
  };

  // Compute average activity vector
  static List<double> averageVector(List<String>? activityList) {
    if (activityList == null || activityList.isEmpty) return List.filled(6, 0.0);
    
    List<List<double>> vectors = activityList
        .where((activity) => activityVectors.containsKey(activity))
        .map((activity) => activityVectors[activity]!)
        .toList();

    List<double> avgVector = List.filled(6, 0.0);
    for (var vector in vectors) {
      for (int i = 0; i < vector.length; i++) {
        avgVector[i] += vector[i];
      }
    }
    return avgVector.map((v) => v / vectors.length).toList();
  }
}
