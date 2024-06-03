import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pawfectmatch/controller/dogregistration_control.dart';
import 'package:pawfectmatch/resources/reusable_widgets.dart';

class DogRegistrationScreen extends StatefulWidget {
  const DogRegistrationScreen({super.key});

  @override
  State<DogRegistrationScreen> createState() => _DogRegistrationScreenState();
}

class _DogRegistrationScreenState extends State<DogRegistrationScreen> {
  final TextEditingController _nameTxtCtrl = TextEditingController();
  final TextEditingController _bioTxtCtrl = TextEditingController();
  final TextEditingController _breedTxtCtrl = TextEditingController();
  final TextEditingController _medTxtCtrl = TextEditingController();

  Gender? selectedGender;
  Vaccinated? selectedVaxStatus;
  DateTime selectedDate = DateTime.now();
  var formatter = DateFormat('yyyy-MM-dd');

  final DogRegistrationControl _dogRegistrationControl =
      DogRegistrationControl();
  late String uid;
  Uint8List? image;
  String profilePictureUrl = '';

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
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
      });
    }
  }

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      image = img;
    });
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
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text("Let's get your furry friend on board!",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 36,
                        color: Color(0xff011F3F),
                        fontWeight: FontWeight.w600)),
                const Text(
                  "Enter your dog's information below",
                  style: TextStyle(
                      color: Color(0xff545F71),
                      fontWeight: FontWeight.normal,
                      fontSize: 18),
                ),
                const SizedBox(height: 30),
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
                                backgroundImage:
                                    NetworkImage(profilePictureUrl),
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
                const SizedBox(
                  height: 20,
                ),
                const Text("Name",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, color: Color(0xff011F3F))),
                reusableInputTextField(
                    "Enter your dog's name", _nameTxtCtrl, TextInputType.text),
                const SizedBox(height: 20),
                const Text("Bio",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, color: Color(0xff011F3F))),
                TextField(
                  controller: _bioTxtCtrl,
                  enableSuggestions: false,
                  autocorrect: true,
                  cursorColor: Colors.white,
                  style: TextStyle(
                      color: const Color(0xff011F3F).withOpacity(0.9)),
                  decoration: InputDecoration(
                    labelText: "Tell us a bit about your dog",
                    labelStyle: TextStyle(
                        color: const Color(0xff011F3F).withOpacity(0.9)),
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                          const BorderSide(width: 0, style: BorderStyle.solid),
                    ),
                  ),
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 20),
                const Text("Gender",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, color: Color(0xff011F3F))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Radio button for Male
                    Radio(
                      value: Gender.male,
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value as Gender;
                        });
                      },
                    ),
                    const Text("Male",
                        textAlign: TextAlign.left,
                        style:
                            TextStyle(fontSize: 18, color: Color(0xff011F3F))),

                    // Add some spacing between radio buttons
                    const SizedBox(width: 20),

                    // Radio button for Female
                    Radio(
                      value: Gender.female,
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value as Gender;
                        });
                      },
                    ),
                    const Text("Female",
                        textAlign: TextAlign.left,
                        style:
                            TextStyle(fontSize: 18, color: Color(0xff011F3F))),
                  ],
                ),
                const Text("Breed",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, color: Color(0xff011F3F))),
                reusableInputTextField("Enter your dog's breed", _breedTxtCtrl,
                    TextInputType.text),
                const SizedBox(height: 20),
                const Text("Birthday",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, color: Color(0xff011F3F))),
                GestureDetector(
                    onTap: () {
                      _selectDate(context); // Show the date picker when tapped
                    },
                    child: SizedBox(
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              formatter.format(selectedDate),
                              style: TextStyle(
                                color: const Color(0xff011F3F).withOpacity(0.9),
                                fontSize: 16, // Adjust the font size as needed
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
                const SizedBox(height: 20),
                const Text("Medical ID",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, color: Color(0xff011F3F))),
                reusableInputTextField("Enter your dog's Medical ID",
                    _medTxtCtrl, TextInputType.text),
                const SizedBox(height: 20),
                const Text("Vaccination Status",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, color: Color(0xff011F3F))),
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
                        style:
                            TextStyle(fontSize: 18, color: Color(0xff011F3F))),

                    // Add some spacing between radio buttons
                    const SizedBox(width: 20),

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
                    const Text("Not Vaccinated",
                        textAlign: TextAlign.left,
                        style:
                            TextStyle(fontSize: 18, color: Color(0xff011F3F))),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                loginRegisterButton(context, false, () {
                  _dogRegistrationControl.addToDatabase(
                      uid,
                      _nameTxtCtrl.text,
                      _bioTxtCtrl.text,
                      selectedGender,
                      _breedTxtCtrl.text,
                      selectedDate,
                      _medTxtCtrl.text,
                      selectedVaxStatus,
                      image,
                      context);
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
