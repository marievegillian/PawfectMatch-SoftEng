import 'package:intl/intl.dart';

class Dog {
  String bio;
  String birthday;
  String breed;
  bool isMale;
  bool isVaccinated;
  // String medID;
  String name;
  String owner;
  String profilePicture;
  double avgRating;
  List<Map<String,dynamic>> vaccines; 
  List<String> likedDogs; // New field for storing liked dog IDs
  List<String> blockedUsers; 

  Dog({
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
    this.vaccines = const [],
    this.likedDogs = const [], // Initialize with an empty list
    this.blockedUsers= const [], // Initialize with an empty list
  });

  factory Dog.fromJson(Map<String, dynamic> json) {
    return Dog(
      bio: json['bio'] ?? '',
      birthday: json['birthday'] ?? '',
      breed: json['breed'] ?? '',
      isMale: json['isMale'] ?? false,
      isVaccinated: json['isVaccinated'] ?? false,
      // medID: json['medID'] ?? '',
      name: json['name'] ?? '',
      owner: json['owner'] ?? '',
      profilePicture: json['profilepicture'] ?? '',
      avgRating: (json['avgRating'] ?? 0).toDouble(),
      vaccines: List<Map<String,dynamic>>.from(json['vaccines'] ?? []),
      likedDogs: List<String>.from(json['likedDogs'] ?? []),
      blockedUsers: List<String>.from(json['blockedUsers'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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