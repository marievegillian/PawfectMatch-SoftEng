class Users {
  final String contactNumber;
  final String dogId;
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final String profilePicture;
  final String username;
  List<String> likedDogs; // New field for storing liked dog IDs


  Users({
    required this.contactNumber,
    required this.dogId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.profilePicture,
    required this.username,
    this.likedDogs = const [], // Initialize with an empty list

  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      contactNumber: json['contactnumber'] ?? '',
      dogId: json['dog'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstname'] ?? '',
      lastName: json['lastname'] ?? '',
      password: json['password'] ?? '',
      profilePicture: json['profilepicture'] ?? '',
      username: json['username'] ?? '',
      likedDogs: List<String>.from(json['likedDogs'] ?? []), // Parse liked dogs from JSON

    );
  }

  // Method to add a liked dog ID
  void addLikedDog(String dogId) {
    likedDogs.add(dogId);
  }

  // Method to remove a liked dog ID
  void removeLikedDog(String dogId) {
    likedDogs.remove(dogId);
  }

  // Convert the user data to a JSON format
  Map<String, dynamic> toJson() {
    return {
      'contactnumber': contactNumber,
      'dog': dogId,
      'email': email,
      'firstname': firstName,
      'lastname': lastName,
      'password': password,
      'profilepicture': profilePicture,
      'username': username,
      'likedDogs': likedDogs,
    };
  }
  
}
