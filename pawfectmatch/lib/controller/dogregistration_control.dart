import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pawfectmatch/models/models.dart';
import 'package:pawfectmatch/resources/reusable_widgets.dart';
import 'package:pawfectmatch/screens/home_screen.dart';

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
      String uid,
      String name,
      String bio,
      Gender? gender,
      String breed,
      DateTime selectedDate,
      String medID,
      Vaccinated? vaxstatus,
      Uint8List? image,
      BuildContext context) async {
    bool isMale = true;
    (gender == Gender.male) ? isMale = true : isMale = false;

    bool isVax = true;
    (vaxstatus == Vaccinated.isVaccinated) ? isVax = true : isVax = false;

    String formattedDate = formatter.format(selectedDate);

    // Create a Dog instance
    Dog newDog = Dog(
      bio: bio,
      birthday: formattedDate,
      breed: breed,
      isMale: isMale,
      isVaccinated: isVax,
      medID: medID,
      name: name,
      owner: uid,
      profilePicture: '',
      avgRating: 0,
    );

    // dogRef = await FirebaseFirestore.instance.collection('dogs').add({
    //   'name': name,
    //   'bio': bio,
    //   'isMale': isMale,
    //   'breed': breed,
    //   'birthday': formattedDate,
    //   'medID': medID,
    //   'isVaccinated': isVax,
    //   'profilepicture': '',
    //   'owner': uid,
    // });
    // Add the dog to the 'dogs' collection
    dogRef = await FirebaseFirestore.instance
        .collection('dogs')
        .add(newDog.toJson());

    String dogDocumentId = dogRef.id;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'dog': dogDocumentId});

    saveProfilePic(image);

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }
}
