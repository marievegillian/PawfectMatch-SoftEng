import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this for Firebase
import 'package:pawfectmatch/controller/dogregistration_control.dart';
import 'package:pawfectmatch/models/dog_model.dart';
import 'package:pawfectmatch/screens/home_screen.dart'; // Import your Dog model

class InterestSelectionScreen extends StatefulWidget {
  final Dog newDog;

  const InterestSelectionScreen({Key? key, required this.newDog}) : super(key: key);

  @override
  _InterestSelectionScreenState createState() => _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  // List of interests
  final List<String> interests = [
    'Hiking', 'Walks', 'Playing Catch', 'Swimming',
    'Gobbling on treats', 'Performing tricks',
    'Tug of War', 'Agility Courses', 'Chasing',
    'Digging', 'Cuddling', 'Fetching', 'Scent Tracking', 'Running'
  ];

  final DogRegistrationControl _dogRegistrationControl =
      DogRegistrationControl();
  late String uid;
  Uint8List? image;
  String profilePictureUrl = '';

  // List to keep track of selected interests
  List<String> selectedInterests = [];

  // For storing the selected purpose
  String? selectedPurpose;

  // List of purposes
  final List<String> purposes = [
    'Breeding partner for my dog',
    'Companion to hang out with',
    'Still figuring it out'
  ];

  // Function to handle interest selection
  void toggleInterest(String interest) {
    setState(() {
      if (selectedInterests.contains(interest)) {
        selectedInterests.remove(interest); // Deselect if already selected
      } else {
        selectedInterests.add(interest); // Add to selected if not already
      }
    });
  }

  // Function to handle saving data
  Future<void> _saveProfileToDatabase() async {
    late DocumentReference<Map<String, dynamic>> dogRef;

    if (selectedPurpose == null || selectedInterests.isEmpty) {
      // Show an error if not all fields are selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both interests and a purpose')),
      );
      return;
    }

    // Combine dog profile data and activities
    Dog fullProfile = widget.newDog; // Access the passed Dog instance
    fullProfile.activities = selectedInterests; // Add selected activities
    fullProfile.purpose = selectedPurpose; // Add selected purpose
    Uint8List imageBytes = base64Decode(fullProfile.profilePicture);
    

    _dogRegistrationControl.addToDatabase(
      fullProfile.owner,
      fullProfile.name,
      fullProfile.bio,
      fullProfile.isMale,
      fullProfile.breed,
      fullProfile.birthday,
      fullProfile.purpose,
      fullProfile.activities,
      fullProfile.isVaccinated,
      fullProfile.vaccines,
      imageBytes,
      context
    );

    // Show confirmation or navigate to another screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Account created successfully')),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xffFFDD82),
          image: DecorationImage(
            image: AssetImage('assets/img_group_25.png'),
            fit: BoxFit.cover,
          ),
        ),
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            // padding: const EdgeInsets.all(16.0),            
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Let's get to know your dog better",                    
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 28,
                        color: Color(0xff011F3F),
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 30),
                // Purpose selection (radio buttons)
                Text(
                  'What are you looking for?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ...purposes.map((purpose) => RadioListTile<String>(
                      title: Text(purpose),
                      value: purpose,
                      groupValue: selectedPurpose,
                      onChanged: (value) {
                        setState(() {
                          selectedPurpose = value;
                        });
                      },
                      contentPadding: EdgeInsets.symmetric(vertical: 0), // Set padding to reduce gap
                    )),
                SizedBox(height: 20),

                // Interest selection (GridView inside a fixed height container)
                Text(
                  'What activities do your dog enjoy?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  height: 300, // Adjust height as needed
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Number of items per row
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.5, // Width to height ratio for each tile
                    ),
                    itemCount: interests.length,
                    itemBuilder: (context, index) {
                      String interest = interests[index];
                      bool isSelected = selectedInterests.contains(interest);

                      return GestureDetector(
                        onTap: () => toggleInterest(interest),
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blueAccent
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blueAccent
                                  : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            interest,
                            textAlign: TextAlign.center, // Center align text horizontally
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 20),

                // Save button
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
                    child: ElevatedButton(
                      onPressed: _saveProfileToDatabase,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.pressed)) {
                            return const Color(0xff011F3F).withOpacity(0.8);
                          }
                          return const Color(0xff011F3F);
                        }),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)))
                        ),
                      child: Text(
                        'Get Your Pup On!',
                        style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
