class Dog {
  String bio;
  String birthday;
  String breed;
  bool isMale;
  bool isVaccinated;
  String medID;
  String name;
  String owner;
  String profilePicture;
  double avgRating;
  List<String> likedDogs; // New field for storing liked dog IDs

  Dog({
    required this.bio,
    required this.birthday,
    required this.breed,
    required this.isMale,
    required this.isVaccinated,
    required this.medID,
    required this.name,
    required this.owner,
    required this.profilePicture,
    required this.avgRating,
    this.likedDogs = const [], // Initialize with an empty list
  });

  factory Dog.fromJson(Map<String, dynamic> json) {
    return Dog(
      bio: json['bio'] ?? '',
      birthday: json['birthday'] ?? '',
      breed: json['breed'] ?? '',
      isMale: json['isMale'] ?? false,
      isVaccinated: json['isVaccinated'] ?? false,
      medID: json['medID'] ?? '',
      name: json['name'] ?? '',
      owner: json['owner'] ?? '',
      profilePicture: json['profilepicture'] ?? '',
      avgRating: (json['avgRating'] ?? 0).toDouble(),
      likedDogs: List<String>.from(json['likedDogs'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bio': bio,
      'birthday': birthday,
      'breed': breed,
      'isMale': isMale,
      'isVaccinated': isVaccinated,
      'medID': medID,
      'name': name,
      'owner': owner,
      'profilepicture': profilePicture,
      'avgRating': avgRating,
      'likedDogs': likedDogs,
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