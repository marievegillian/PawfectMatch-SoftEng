// lib/models/dog_profile.dart

class DogProfile {
  final String name;
  final String bio;
  final String breed;
  final bool isMale;
  final bool isVaccinated;
  final String birthday;
  final String profilePicture;
  final String owner;
  final String medID;

  DogProfile({
    required this.name,
    required this.bio,
    required this.breed,
    required this.isMale,
    required this.isVaccinated,
    required this.birthday,
    required this.profilePicture,
    required this.owner,
    required this.medID,
  });

  factory DogProfile.fromJson(Map<String, dynamic> json) {
    return DogProfile(
      name: json['name'],
      bio: json['bio'],
      breed: json['breed'],
      isMale: json['isMale'],
      isVaccinated: json['isVaccinated'],
      birthday: json['birthday'],
      profilePicture: json['profilepicture'],
      owner: json['owner'],
      medID: json['medID'],
    );
  }
}
