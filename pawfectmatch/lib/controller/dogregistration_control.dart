import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pawfectmatch/blocs/active_dog/active_dog_cubit.dart';
import 'package:pawfectmatch/models/models.dart';
import 'package:pawfectmatch/resources/reusable_widgets.dart';
import 'package:pawfectmatch/screens/home_screen.dart';
import 'package:pawfectmatch/screens/interestselection_screen.dart';

class DogRegistrationControl {
  late DocumentReference<Map<String, dynamic>> dogRef;
  var formatter = DateFormat('yyyy-MM-dd');

  Future<void> saveProfilePic(Uint8List? image) async {
    try {
      String profileurl =
          await uploadImgToStorage(dogRef.id, image!, FirebaseStorage.instance);
      await FirebaseFirestore.instance
          .collection('dogs')
          .doc(dogRef.id)
          .update({'profilepicture': profileurl});
    } catch (e) {
      // Handle any potential errors here
      print("Error saving profile picture: $e");
    }
  }

  Future<void> addToDatabase(
      String ownerUid,
      String name,
      String bio,
      bool gender,
      String breed,
      String birthday,
      // String medID, //removed field
      String? purpose,
      List <String>? activities,
      bool isVax,
      List<Map<String,dynamic>> selectedVaccines,
      Uint8List? image,
      BuildContext context) async {
  try{
    // Create a Dog instance
    Dog newDog = Dog(
      dogId: '', //temporarily set as blank
      bio: bio,
      birthday: birthday,
      breed: breed,
      isMale: gender,
      isVaccinated: isVax,
      vaccines: selectedVaccines,
      // medID: medID, //medID field is removed, but commented for now
      purpose: purpose,
      activities: activities,
      name: name,
      owner: ownerUid,
      profilePicture: '',
      avgRating: 0,
    );

    dogRef = await FirebaseFirestore.instance
        .collection('dogs')
        .add(newDog.toJson());

    String dogDocumentId = dogRef.id;

    DocumentSnapshot dogSnapshot = await dogRef.get();

    //update the dogId attribute of the document of the newly registered dog
    if (dogSnapshot.exists) {
      Map<String, dynamic>? data = dogSnapshot.data() as Map<String, dynamic>?;
      if (data != null && (data['dogId'] == null || data['dogId'] == '')) {
        // Step 4: Update the dogId only if it's empty
        String dogDocumentId = dogRef.id;
        await dogRef.update({'dogId': dogDocumentId});
        print("Dog ID updated to: $dogDocumentId");
      } else {
        print("Dog ID already exists and won't be overwritten.");
      }
    }

    await FirebaseFirestore.instance
      .collection('users')
      .doc(ownerUid)
      .update({
        'ownedDogs': FieldValue.arrayUnion([dogDocumentId]) // Add dog ID to the array
      });


    //set the newly created dog profile will as the currently active profile 
    if (context.mounted) {
          context.read<ActiveDogCubit>().setActiveDog(dogDocumentId);
    }

    await FirebaseFirestore.instance
      .collection('users')
      .doc(ownerUid)
      .update({
        'activeDogId': dogDocumentId // Add dog ID to the array
      });

    saveProfilePic(image);

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }catch(e){
    print("Failed to add dog profile: $e");
  }
  }
}
