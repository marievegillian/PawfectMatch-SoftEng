import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pawfectmatch/controller/dogregistration_control.dart';
import 'package:pawfectmatch/models/dog_model.dart';
import 'package:pawfectmatch/resources/reusable_widgets.dart';
import 'package:pawfectmatch/screens/interestselection_screen.dart';

class DogRegistrationScreen extends StatefulWidget {
  const DogRegistrationScreen({super.key});

  @override
  State<DogRegistrationScreen> createState() => _DogRegistrationScreenState();
}

class _DogRegistrationScreenState extends State<DogRegistrationScreen> {
  final TextEditingController _nameTxtCtrl = TextEditingController();
  final TextEditingController _bioTxtCtrl = TextEditingController();
  final TextEditingController _breedTxtCtrl = TextEditingController();

  Gender? selectedGender;
  List<String> _dogBreeds = [];
  bool isLoading = true;
  Vaccinated? selectedVaxStatus;
  List<Map<String, dynamic>> selectedVaccines = [];
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
    fetchDogBreeds();
  }

  //For vaccine options
  String? selectedVaccine;
  TextEditingController _otherVaccineCtrl = TextEditingController();
  bool showOtherVaccineField = false;

   // Fetch dog breeds from the API and flatten the JSON structure
  Future<void> fetchDogBreeds() async {
    final response = await http.get(Uri.parse('https://dog.ceo/api/breeds/list/all')); // Replace with your API URL
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);

      // Extract the "message" part of the response which contains the breeds
      Map<String, dynamic> breedData = jsonData['message'];
      
      List<String> flattenedBreeds = [];

      // Flatten the JSON structure
      breedData.forEach((key, value) {
        if (value is List && value.isEmpty) {
          // If there are no sub-breeds, add the main breed
          flattenedBreeds.add(_capitalize(key));
        } else if (value is List) {
          // If there are sub-breeds, combine them with the main breed
          value.forEach((subBreed) {
            flattenedBreeds.add(_capitalize(subBreed) + ' ' + _capitalize(key));
          });
        } else {
          // Fallback if value is not a list
          flattenedBreeds.add(_capitalize(key));
        }
      });

      // Update the UI with the flattened breeds
      setState(() {
        _dogBreeds = flattenedBreeds;
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load dog breeds');
    }
  }

  // Helper function to capitalize the first letter of each word
  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

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

                const Text("Breed"),
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                     if (textEditingValue.text == '') {
                        return const Iterable<String>.empty();
                      }
                      return _dogBreeds.where((String breed) {
                        return breed.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });                    
                  },
                  onSelected: (String selection) {
                    _breedTxtCtrl.text = selection; // Set the selected breed to the text controller
                    print('Selected: $selection');
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController fieldTextEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return TextField(
                      controller: fieldTextEditingController, // Use the internal controller of the Autocomplete
                      focusNode: focusNode,
                      cursorColor: Colors.white,
                      style: TextStyle(
                        color: const Color(0xff011F3F).withOpacity(0.9),
                      ),
                      decoration: InputDecoration(
                        labelText: "Enter your dog's breed",
                        labelStyle: TextStyle(
                          color: const Color(0xff011F3F).withOpacity(0.9),
                        ),
                        filled: true,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        fillColor: Colors.white.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(width: 0, style: BorderStyle.solid),
                        ),
                      ),
                    );
                  },
                ),

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

                const SizedBox(height: 40),
            
                const Text("Vaccination Status",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 18, color: Color(0xff011F3F))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
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
                        style: TextStyle(fontSize: 18, color: Color(0xff011F3F))),

                    const SizedBox(width: 20),

                    Radio(
                      value: Vaccinated.isNotVaccinated,
                      groupValue: selectedVaxStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedVaxStatus = value as Vaccinated;

                           // If "Not Vaccinated" is selected, clear the vaccines list
                          if (selectedVaxStatus == Vaccinated.isNotVaccinated) {
                            selectedVaccines.clear();
                            print("Vaccine list cleared due to 'Not Vaccinated' selection.");
                          }

                          // Optionally print the updated vaccination status and vaccine list
                          print('Vaccination Status: $selectedVaxStatus');
                          printSelectedVaccines();
                        });
                      },
                    ),
                    const Text("Not Vaccinated",
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 18, color: Color(0xff011F3F))),
                  ],
                ),

                // Vaccination type details (shown only if vaccinated is selected)
                Visibility(
                  visible: selectedVaxStatus == Vaccinated.isVaccinated,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Select Vaccines", style: TextStyle(fontSize: 18, color: Color(0xff011F3F))),
                      buildVaccineCheckbox('Rabies'),
                      buildVaccineCheckbox('Distemper'),
                      buildVaccineCheckbox('Hepatitis'),
                      buildVaccineCheckbox('Parainfluenza'),
                      buildVaccineCheckbox('Parvovirus'),
                      buildVaccineCheckbox('Leptospirosis'),
                      buildVaccineCheckbox('Bordetella (Kennel Cough)'),   
                      buildVaccineCheckbox('Lyme Disease'), 
                      buildVaccineCheckbox('Canine Influenza'),  
                      buildVaccineCheckbox('Coronavirus'),      
                      buildVaccineCheckbox('Canine Herpes Virus'),                                   
                    ],
                  ),
                ),

                const SizedBox(
                  height: 40,
                ),

                loginRegisterButton(context, false, () {                  
                  // tempSaveDogData();
                   _onNextButtonPressed();
                })
              ],
            ),
          ),
        ),
      ),
    );
  }

bool _validateFields({bool showDialogs = true}) {
  // Check if any required fields are empty
  if (_nameTxtCtrl.text.isEmpty ||
      _bioTxtCtrl.text.isEmpty ||
      selectedGender == null ||
      _breedTxtCtrl.text.isEmpty ||
      selectedVaxStatus == null) {
    if (showDialogs) {
      _showAlertDialog(
        "Incomplete Information",
        "Please ensure all fields are filled out before proceeding.",
      );
    }
    return false; // Validation failed
  }

  // Check if vaccinated but no vaccines are selected
  if (selectedVaxStatus == Vaccinated.isVaccinated &&
      selectedVaccines.isEmpty) {
    if (showDialogs) {
      _showAlertDialog(
        "No Vaccine Selected",
        "Please select at least 1 vaccine before proceeding.",
      );
    }
    return false; // Validation failed
  }

  return true; // All fields are valid
}

void _onNextButtonPressed() {
  if (_validateFields()) {
    tempSaveDogData();  
  }
}

void _showAlertDialog(String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}


void tempSaveDogData(){
  bool isMale = true;
  Gender? gender = selectedGender;
  Vaccinated? vaxstatus = selectedVaxStatus;
  String  purpose = '';
  List <String> activities = [];

  (gender == Gender.male) ? isMale = true : isMale = false;

  bool isVax = true;
  (vaxstatus == Vaccinated.isVaccinated) ? isVax = true : isVax = false;

  String formattedDate = formatter.format(selectedDate);
  String base64Image = image == null ? '' : base64Encode(image!);


  // Create a Dog instance
  Dog newDog = Dog(
    dogId: '',
    bio: _bioTxtCtrl.text,
    birthday: formattedDate,
    breed: _breedTxtCtrl.text,
    isMale: isMale,
    isVaccinated: isVax,
    vaccines: selectedVaccines,
    purpose: purpose,
    activities: activities,
    name: _nameTxtCtrl.text,
    owner: uid,
    profilePicture: base64Image,
    avgRating: 0,
  );
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => InterestSelectionScreen(newDog: newDog),
  ),
  );
}

Widget buildVaccineCheckbox(String vaccineName) {
  return CheckboxListTile(
    title: Text(vaccineName),
    // Ensure the value reflects the selection status
    value: selectedVaccines.any((vaccine) => vaccine['name'] == vaccineName),
    onChanged: (bool? isSelected) {
      setState(() {
        if (isSelected != null && isSelected) {
          // Add the vaccine if selected
          selectedVaccines.add({'name': vaccineName, 'date': DateTime.now().toString()});
        } else {
          // Remove the vaccine if unselected
          selectedVaccines.removeWhere((vaccine) => vaccine['name'] == vaccineName);
        }

        // Print the updated list to the console
        printSelectedVaccines();
      });
    },
  );
}

// Function to print selected vaccines (optional for debugging)
void printSelectedVaccines() {
  print("Selected Vaccines:");
  for (var vaccine in selectedVaccines) {
    print('Vaccine Name: ${vaccine['name']}, Date: ${vaccine['date']}');
  }
}


}