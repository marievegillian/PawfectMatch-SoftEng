import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pawfectmatch/screens/appointment_screen.dart';
import '/repositories/database_repository.dart'; 

class NewAppointmentScreen extends StatefulWidget {
  final VoidCallback? onAppointmentCreated;

  NewAppointmentScreen({this.onAppointmentCreated});

  @override
  _NewAppointmentScreenState createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  String selectedDog = '';
  DateTime selectedDateTime = DateTime.now();

  Future<List<DropdownMenuItem<String>>> _getMatchedDogs() async {
  try {
    DatabaseRepository databaseRepository = DatabaseRepository();
    await databaseRepository.setLoggedInDog();

    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('matches')
        .where('user1', isEqualTo: databaseRepository.loggedInOwner)
        .get();

    List<DropdownMenuItem<String>> matchedDogs = [];

    // Add a default item with an empty value
    matchedDogs.add(
      DropdownMenuItem<String>(
        value: '',
        child: Text('Select Matched Dog'),
      ),
    );

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      String matchedDog = await databaseRepository.getDogOwned(doc['user2'] as String);

      // Check for duplicates
      if (matchedDogs.any((item) => item.value == matchedDog)) {
        continue;
      }

      if (matchedDog.isNotEmpty) {
        matchedDogs.add(
          DropdownMenuItem<String>(
            value: matchedDog,
            child: Text(matchedDog),
          ),
        );
      }
    }

    return matchedDogs;
  } catch (error) {
    print('Error getting matched dogs: $error');
    return [];
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make New Appointment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<DropdownMenuItem<String>>>(
              future: _getMatchedDogs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No matched dogs available.');
                } else {
                  return DropdownButtonFormField<String>(
                    value: selectedDog,
                    onChanged: (value) {
                      setState(() {
                        selectedDog = value!;
                      });
                    },
                    items: snapshot.data!,
                    decoration: InputDecoration(labelText: 'Select Matched Dog'),
                  );
                }
              },
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDateTime,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );

                if (pickedDate != null) {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    setState(() {
                      selectedDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Select Date and Time',
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today),
                    SizedBox(width: 8),
                    Text(
                      DateFormat('EEE, MMM d, y h:mm a').format(selectedDateTime),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _saveAppointment(selectedDog, selectedDateTime);
              },
              child: Text('Submit Appointment'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAppointment(String selectedDog, DateTime selectedDateTime) async {
  try {
    // Get the reference to the 'appointments' collection
    CollectionReference<Map<String, dynamic>> appointments =
        FirebaseFirestore.instance.collection('appointments');

    // Create a new document with a unique ID
    DocumentReference<Map<String, dynamic>> newAppointmentRef =
        await appointments.add({
      'user': DatabaseRepository().loggedInOwner,
      'dog': selectedDog,
      'dateTime': selectedDateTime,
      'status': 'pending',
      'id': '' // Initialize with an empty string (will be updated later)
    });

    // Get the ID of the newly created appointment
    String appointmentId = newAppointmentRef.id;

    // Update the document with the actual ID
    await newAppointmentRef.update({'id': appointmentId});

    // Print or use the appointment ID as needed
    print('Appointment saved successfully! ID: $appointmentId');

    // Redirect to AppointmentScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AppointmentScreen()),
    );

    widget.onAppointmentCreated?.call();
  } catch (error) {
    print('Error saving appointment: $error');
  }
}


}