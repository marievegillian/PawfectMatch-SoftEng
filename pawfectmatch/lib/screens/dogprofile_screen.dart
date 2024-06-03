import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pawfectmatch/models/models.dart';
import 'package:pawfectmatch/resources/reusable_widgets.dart';
import 'package:pawfectmatch/screens/home_screen.dart';
import 'package:pawfectmatch/screens/userprofile_screen.dart';
import 'package:pawfectmatch/repositories/repositories.dart';

class DogProfileScreen extends StatefulWidget {
  const DogProfileScreen({super.key});

  @override
  State<DogProfileScreen> createState() => _DogProfileScreenState();
}

class _DogProfileScreenState extends State<DogProfileScreen> {
  late String uid;
  String doguid = '';
  String dogname = '';
  String profilePictureUrl = '';
  String bio = '';
  String birthday = '';
  String breed = '';
  bool isMale = true;
  bool isVaccinated = true;
  String medID = '';
  Uint8List? image;
  DateTime selectedDate = DateTime.now();
  var formatter = DateFormat('yyyy-MM-dd');
  Vaccinated? selectedVaxStatus;
  bool isBirthdayChanged = false;

  DatabaseRepository databaseRepository = DatabaseRepository();


  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      image = img;
      saveProfilePic();
    });
  }

  Future<void> saveProfilePic() async {
    try {
      String profileurl =
          await uploadImgToStorage(doguid, image!, FirebaseStorage.instance);
      await FirebaseFirestore.instance
          .collection('dogs')
          .doc(doguid)
          .update({'profilepicture': profileurl});
    } catch (e) {
      // Handle any potential errors here
      print("Error saving profile picture: $e");
    }
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      // Use the Users.fromJson method to create an instance of Users from the JSON data
      Users user = Users.fromJson(userSnapshot.data() as Map<String, dynamic>);
      doguid = user.dogId;
      fetchDogData();
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> fetchDogData() async {
    try {
      DocumentSnapshot dogSnapshot =
          await FirebaseFirestore.instance.collection('dogs').doc(doguid).get();

      // Use the Dog.fromJson method to create an instance of Dog from the JSON data
      Dog dog = Dog.fromJson(dogSnapshot.data() as Map<String, dynamic>);

     // Set the gender of the logged-in dog

      // Extract the data from the document snapshot
      dogname = dog.name;
      profilePictureUrl = dog.profilePicture;
      bio = dog.bio;
      birthday = dog.birthday;
      breed = dog.breed;
      isMale = dog.isMale;
      isVaccinated = dog.isVaccinated;
      medID = dog.medID;

      // Update the UI with the contact number
      setState(() {});
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900), // Adjust the start date as needed
      lastDate: DateTime(2101), // Adjust the end date as needed
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        isBirthdayChanged = true;
      });
    }
  }

  Future<void> confirmEditProfile(
    String newName,
    String newBio,
    String newBreed,
    String newBirthday,
    String newMedID,
    Vaccinated? newVaxStatus,
  ) async {
    bool isVax;
    (newVaxStatus == Vaccinated.isVaccinated) ? isVax = true : isVax = false;

    // Check if there are no changes
    if (newName.isEmpty &&
        newBio.isEmpty &&
        newBreed.isEmpty &&
        newBirthday.isEmpty &&
        newMedID.isEmpty &&
        newVaxStatus == selectedVaxStatus) {
      // No changes, simply close the dialog
      Navigator.pop(context);
      return;
    }

    // Create a map to store the updated fields
    Map<String, dynamic> updatedFields = {};

    // Conditionally add fields to the map only if the corresponding TextEditingController is not null or empty
    if (newName.isNotEmpty) {
      updatedFields['name'] = newName;
    } else {
      updatedFields['name'] = dogname;
    }
    if (newBio.isNotEmpty) {
      updatedFields['bio'] = newBio;
    } else {
      updatedFields['bio'] = bio;
    }
    if (newBreed.isNotEmpty) {
      updatedFields['breed'] = newBreed;
    } else {
      updatedFields['breed'] = breed;
    }
    if (isBirthdayChanged && newBirthday.isNotEmpty) {
      updatedFields['birthday'] = newBirthday;
    } else {
      updatedFields['birthday'] = birthday;
    }
    if (newMedID.isNotEmpty) {
      updatedFields['medID'] = newMedID;
    } else {
      updatedFields['medID'] = medID;
    }

    // Update the Firestore document with the new values
    await FirebaseFirestore.instance
        .collection('dogs')
        .doc(doguid)
        .update(updatedFields);

    await FirebaseFirestore.instance
        .collection('dogs')
        .doc(doguid)
        .update({'isVaccinated': isVax});

    // Update the local state
    setState(() {});

    // Close the dialog
    Navigator.pop(context);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => UserProfileScreen(),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => HomeScreen(),
      ),
    );
  }

  Future<void> showEditProfileDialog() async {
    final TextEditingController _nameTxtCtrl = TextEditingController();
    final TextEditingController _bioTxtCtrl = TextEditingController();
    final TextEditingController _breedTxtCtrl = TextEditingController();
    final TextEditingController _medTxtCtrl = TextEditingController();

    selectedVaxStatus =
        isVaccinated ? Vaccinated.isVaccinated : Vaccinated.isNotVaccinated;

    // await showDialog(
    //   context: context,
    //   builder: (BuildContext context) {

    //   },
    // );
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xffFFDD82),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 48.0),
                        ],
                      ),
                      // Add your content here
                      Container(
                        padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Name",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 18, color: Color(0xff011F3F))),
                            reusableInputTextField("Enter your dog's name",
                                _nameTxtCtrl, TextInputType.text),
                            const SizedBox(height: 20),
                            const Text("Bio",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 18, color: Color(0xff011F3F))),
                            TextField(
                              controller: _bioTxtCtrl,
                              enableSuggestions: false,
                              autocorrect: true,
                              cursorColor: Colors.white,
                              style: TextStyle(
                                  color:
                                      const Color(0xff011F3F).withOpacity(0.9)),
                              decoration: InputDecoration(
                                labelText: "Tell us a bit about your dog",
                                labelStyle: TextStyle(
                                    color: const Color(0xff011F3F)
                                        .withOpacity(0.9)),
                                filled: true,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                fillColor: Colors.white.withOpacity(0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                      width: 0, style: BorderStyle.solid),
                                ),
                              ),
                              keyboardType: TextInputType.multiline,
                            ),
                            const SizedBox(height: 20),
                            const Text("Breed",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 18, color: Color(0xff011F3F))),
                            reusableInputTextField("Enter your dog's breed",
                                _breedTxtCtrl, TextInputType.text),
                            const SizedBox(height: 20),
                            const Text("Birthday",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 18, color: Color(0xff011F3F))),
                            GestureDetector(
                                onTap: () {
                                  _selectDate(
                                      context); // Show the date picker when tapped
                                },
                                child: SizedBox(
                                  height: 50,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(5),
                                        border:
                                            Border.all(color: Colors.black)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          formatter.format(selectedDate),
                                          style: TextStyle(
                                            color: const Color(0xff011F3F)
                                                .withOpacity(0.9),
                                            fontSize:
                                                16, // Adjust the font size as needed
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                            const SizedBox(height: 20),
                            const Text("Medical ID",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 18, color: Color(0xff011F3F))),
                            reusableInputTextField(
                                "Enter your dog's Medical ID",
                                _medTxtCtrl,
                                TextInputType.text),
                            const SizedBox(height: 20),
                            const Text("Vaccination Status",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 18, color: Color(0xff011F3F))),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // Radio button for Male
                                Radio(
                                  value: Vaccinated.isVaccinated,
                                  groupValue: selectedVaxStatus,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedVaxStatus = value as Vaccinated;
                                    });
                                  },
                                ),
                                const Text("Vaccinated",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xff011F3F))),

                                // Add some spacing between radio buttons
                                // Radio button for Female
                                Radio(
                                  value: Vaccinated.isNotVaccinated,
                                  groupValue: selectedVaxStatus,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedVaxStatus = value as Vaccinated;
                                    });
                                  },
                                ),
                                const Text("Not\nVaccinated",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xff011F3F))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 45,
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5)),
                        child: ElevatedButton(
                          onPressed: () {
                            confirmEditProfile(
                                _nameTxtCtrl.text,
                                _bioTxtCtrl.text,
                                _breedTxtCtrl.text,
                                formatter.format(selectedDate),
                                _medTxtCtrl.text,
                                selectedVaxStatus);
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return const Color(0xff545F71)
                                      .withOpacity(0.8);
                                }
                                return const Color(0xff545F71);
                              }),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)))),
                          child: const Text(
                            "Apply Changes",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 28,
            color: Color(
              0xff011F3F,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.white, // Replace with your desired gradient start color
                Color(
                    0xffFFDD82), // Replace with your desired gradient end color
              ],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 30,
              ),
              Stack(
                children: [
                  image != null
                      ? CircleAvatar(
                          radius: 65,
                          backgroundImage: MemoryImage(image!),
                        )
                      : profilePictureUrl.isNotEmpty
                          ? CircleAvatar(
                              radius: 65,
                              backgroundImage: NetworkImage(profilePictureUrl),
                            )
                          : const CircleAvatar(
                              radius: 65,
                              backgroundImage: NetworkImage(
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRUoJFUtRrXrFtd2LrzEja_cMMlEtreh4CMh1iRrhLL-5RJ4cO7P3Pale5OTxIrgkhFmM8&usqp=CAU'),
                            ),
                  Positioned(
                    bottom: 10,
                    left: 90,
                    child: GestureDetector(
                      child: SizedBox(
                          width: 35,
                          height: 35,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              color: const Color(0xff0F3E48),
                              padding: const EdgeInsets.all(2),
                              child: const Icon(
                                Icons.mode_edit_outline_outlined,
                                color: Colors.white,
                              ),
                            ),
                          )),
                      onTap: () {
                        selectImage();
                      },
                    ),
                  )
                ],
              ),
              Text(
                dogname.isNotEmpty ? dogname : 'Dog',
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 28),
              ),
              const SizedBox(
                height: 10,
              ),
              editProfileButton(context, () {
                showEditProfileDialog();
              }),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.fromLTRB(80, 10, 80, 20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 216, 224, 230),
                  borderRadius:
                      BorderRadius.circular(20), // Adjust the value as needed
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Dog's Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Bio:",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w500)),
                    Text(
                      bio.isNotEmpty ? bio : 'Bio',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    const Text("Gender:",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w500)),
                    Text(
                      isMale ? "Male" : 'Female',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    const Text("Breed:",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w500)),
                    Text(
                      breed.isNotEmpty ? breed : 'Breed',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    const Text("Birthday:",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w500)),
                    Text(
                      birthday.isNotEmpty ? birthday : 'Birthday',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    const Text("Medical ID:",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w500)),
                    Text(
                      medID.isNotEmpty ? medID : 'Medical ID',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    const Text("Vaccination Status:",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w500)),
                    Text(
                      isVaccinated ? "Complete" : 'Incomplete',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: null,
    );
  }
}