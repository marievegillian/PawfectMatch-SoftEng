  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:geolocator/geolocator.dart';
  import 'package:pawfectmatch/firebase_service.dart';
  import '/models/models.dart';
  import '/models/match_model.dart'; 
  import 'repositories.dart';


  class DatabaseRepository extends BaseDatabaseRepository {
    final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

    @override
    Stream<Dog> getDog(String dogId) {
      print('Getting dog from DB');
      return _firebaseFirestore
          .collection('dogs')
          .doc(dogId)
          .snapshots()
          .map((snap) => Dog.fromJson(snap.data() as Map<String, dynamic>));
    }

    @override
    Stream<List<Dog>> getDogs() {
      try {
        // Query the "dogs" collection
        setLoggedInOwner();
        setLoggedInDog();
        
        return _firebaseFirestore
            .collection('dogs')
            .snapshots()
            .map((snap) => snap.docs
                .map((doc) => Dog.fromJson(doc.data() as Map<String, dynamic>))
                .where((dog) => dog.owner != loggedInOwner)
                .toList());
      } catch (error) {
        print('Error getting dogs: $error');
        rethrow;
      }
    }
    
    String loggedInOwner = FirebaseAuth.instance.currentUser!.uid;
    String loggedInDogUid = '';


    void setLoggedInOwner() {
      try {
        loggedInOwner = FirebaseAuth.instance.currentUser!.uid;
      } catch (e) {
        // Handle the case where there is no logged-in user
        print('error in getting uid: $e');
        loggedInOwner = ''; // Set to an appropriate default value
      }
    }

    Future<void> setLoggedInDog() async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(loggedInOwner).get();

      // Use the Users.fromJson method to create an instance of Users from the JSON data
      Users user = Users.fromJson(userSnapshot.data() as Map<String, dynamic>);
      loggedInDogUid = user.dogId;

      // Get the dog using the updated getDog method and print its name
      await getDog(loggedInDogUid).first.then((dog) {
        print('Logged in dog name: ${dog.name}');
        
        // Update the location of the dog in the 'dogs' collection
        updateDogLocation(loggedInDogUid);
      });
    } catch (e) {
      print('Setting Logged in Dog Failed: $e');
    }
  }


    Future<void> updateLikedDogsInFirestore(String likedDogOwnerId) async {
      try {
        String loggedInUserId = loggedInDogUid;
        print('Liked Dogs Owner: $likedDogOwnerId');
        await FirebaseService().updateLikedDogs(loggedInUserId, [likedDogOwnerId]);
        
      } catch (e) {
        print('Error updating liked dogs in Firestore: $e');
      }
    }
    
  Future<bool> isDogLiked(String dogOwnerId, String likedDogOwnerId) async {
    try {
      // Get the dogOwned by awaiting the result of getDogOwned
      String? dog1 = await getDogOwned(dogOwnerId);

      if (dog1 != null && dog1.isNotEmpty) {
        CollectionReference<Map<String, dynamic>> likedDogsCollection =
            _firebaseFirestore.collection('dogs').doc(dog1).collection('likedDogs');

        print('Checking if $likedDogOwnerId is liked by $dog1');

        // Check if the document exists in 'likedDogs' subcollection
        bool isLiked = (await likedDogsCollection.doc(likedDogOwnerId).get()).exists;

        print('Result: $isLiked');

        return isLiked;
      } else {
        // Handle the case where dog1 is null or empty
        print('DogOwned is null or empty for ownerId: $dogOwnerId');
        return false;
      }
    } catch (error) {
      print('Error checking liked dogs: $error');
      return false;
    }
  }


  Future<List<String>> getLikedDogs() async {
    try {
      // Get a reference to the 'likedDogs' subcollection for the logged-in dog
      CollectionReference<Map<String, dynamic>> likedDogsCollection =
          _firebaseFirestore.collection('dogs').doc(loggedInDogUid).collection('likedDogs');

      // Get all documents in the 'likedDogs' subcollection
      QuerySnapshot<Map<String, dynamic>> likedDogsSnapshot =
          await likedDogsCollection.get();

      // Extract the 'owner' field from each document
      List<String> likedDogOwners = likedDogsSnapshot.docs
          .map((doc) => doc.data()['owner'] as String)
          .toList();

      return likedDogOwners;
    } catch (error) {
      print('Error getting liked dog owners: $error');
      return [];
    }
  }

  Future<List<Match>> getMatches() async {
    try {
      // Fetch matches from Firestore
      QuerySnapshot<Map<String, dynamic>> matchesSnapshot =
          await _firebaseFirestore.collection('matches').get();

      // Convert the QuerySnapshot to a List<Match>
      List<Match> matches = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in matchesSnapshot.docs) {
        Match match = Match.fromJson(doc.data() as Map<String, dynamic>);

        // Fetch the dog's name using the getDog method
        Dog matchedDog = await getDog(match.matchedDogId).first;

        // Update the matchedDogName in the match object
        match = match.copyWith(matchedDogName: matchedDog.name);

        matches.add(match);
      }

      return matches;
    } catch (error) {
      print('Error getting matches: $error');
      return [];
    }
  }

  Future<void> createAppointment(Match match) async {
    try {
      // Create a new document in the 'matches' collection
      await _firebaseFirestore.collection('matches').doc(match.id).set(match.toJson());
    } catch (error) {
      print('Error creating appointment: $error');
    }
  }

Future<List<Appointment>> getAppointmentsByStatus(String status) async {
  try {
    // Query the 'appointments' collection based on the provided status
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firebaseFirestore
        .collection('appointments')
        .where('status', isEqualTo: status)
        .where('user', isEqualTo: loggedInOwner)
        .get();

    // Extract appointments from the documents
    List<Appointment> appointments = snapshot.docs.map((doc) {
      return Appointment.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();

    return appointments;
  } catch (error) {
    print('Error getting appointments by status: $error');
    throw error; // Rethrow the error for handling in the calling code
  }
}



  Future<bool> checkMatch(String likedDogOwnerId) async {
    try {
      // Get the current user's dog ID
      setLoggedInOwner();
      setLoggedInDog();

      // Check if the liked dog has liked the current user's dog
      bool isMatch = await isDogLiked(likedDogOwnerId, loggedInOwner) && await isDogLiked(loggedInOwner, likedDogOwnerId);

      return isMatch;
    } catch (error) {
      print('Error checking match: $error');
      return false;
    }
  }

 Future<String> getDogOwned(String ownerId) async {
  try {
    // Get a reference to the 'user' document
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await _firebaseFirestore.collection('users').doc(ownerId).get();

    // Check if the document exists
    if (userSnapshot.exists) {
      // Retrieve the 'dog' field from the document
      String dogOwned = userSnapshot.data()?['dog'];
      print('got the dog owned: $dogOwned');

      // Use await to get the dog asynchronously
      Dog? dog = await getDog(dogOwned).first;
      
      // Check if the dog is not null before returning its name
      if (dog != null) {
        return dog.name;
      } else {
        // Handle the case where the dog is not found
        print('Dog not found for ownerId: $ownerId');
        return '';
      }
    } else {
      print('User document not found for ownerId: $ownerId');
      return '';
    }
  } catch (error) {
    print('Error getting dogOwned: $error');
    return '';
  }
}



  Future<void> updateMatchInfo(String dogOwnerId, String matchedDogOwnerId) async {
    try {
      // Perform the necessary actions to update match information in Firestore
      // For example, you can update a 'matches' collection or fields in the 'dogs' collection
      // Update the 'matches' field in Firestore for the specified dog
      await _firebaseFirestore
          .collection('dogs')
          .doc(dogOwnerId)
          .update({
        'matches': FieldValue.arrayUnion([matchedDogOwnerId]),
      });
    } catch (error) {
      print('Error updating match info in Firestore: $error');
    }
  }

  Future<void> updateMatched(String likedDogOwnerId) async {
    try {
      // Get the current user's dog ID
      setLoggedInOwner();
      setLoggedInDog();

      // Get the dog owned by the liked dog owner
      String matchedDogOwnerId = likedDogOwnerId;

      if (matchedDogOwnerId.isNotEmpty) {
        // Check if the match already exists
        bool matchExists = await checkMatchExists(loggedInOwner, likedDogOwnerId);

        if (!matchExists) {
          // Update 'matches' collection for user1 (logged-in owner)
          await _firebaseFirestore.collection('matches').add({
            'user1': loggedInOwner,
            'user2': likedDogOwnerId,
          });

          // Update 'matches' collection for user2 (liked dog owner)
          await _firebaseFirestore.collection('matches').add({
            'user1': likedDogOwnerId,
            'user2': loggedInOwner,
          });
        } else {
          print('Match already exists between $loggedInOwner and $likedDogOwnerId');
        }
      } else {
        print('Matched dog not found for ownerId: $likedDogOwnerId');
      }
    } catch (error) {
      print('Error updating matched info in Firestore: $error');
    }
  }

  Future<bool> checkMatchExists(String user1, String user2) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firebaseFirestore
          .collection('matches')
          .where('user1', isEqualTo: user1)
          .where('user2', isEqualTo: user2)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (error) {
      print('Error checking match existence: $error');
      return false;
    }
  }

  Future<void> createConversation(String user1Id, String user2Id) async {
    try {
      // Check if a conversation already exists in 'user1'
      QuerySnapshot existingConversations1 = await FirebaseFirestore.instance
          .collection('conversations')
          .where('user1', isEqualTo: user1Id)
          .where('user2', isEqualTo: user2Id)
          .get();

      QuerySnapshot existingConversations2 = await FirebaseFirestore.instance
          .collection('conversations')
          .where('user1', isEqualTo: user2Id)
          .where('user2', isEqualTo: user1Id)
          .get();

      if (existingConversations1.docs.isEmpty &&
          existingConversations2.docs.isEmpty) {
        // If no conversation exists between the two, create a new conversation
        DocumentReference conversationRef =
            FirebaseFirestore.instance.collection('conversations').doc();

        // Create a messages subcollection inside the conversation
        CollectionReference messagesRef = conversationRef.collection('messages');

        // Add an initial message
        DocumentReference initialMessageRef = await messagesRef.add({
          'senderId': user1Id,
          'receiverId': user2Id,
          'messageContent': user1Id,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Get the ID of the initial message
        String initialMessageId = initialMessageRef.id;

        // Add conversation details with the initial message ID as lastMessage
        await conversationRef.set({
          'user1': user1Id,
          'user2': user2Id,
          'lastMessage': initialMessageId,
          // Add any other details you want to store about the conversation
        });

        print('Conversation created successfully.');
      } else {
        print('Conversation already exists.');
      }
    } catch (e) {
      print('Error creating conversation: $e');
    }
  }

  Future<void> updateDogLocation(String dogId) async {
    try {
      // Get the current user's location
      Position position = await Geolocator.getCurrentPosition();

      // Update the 'location' field in the 'dogs' collection
      await _firebaseFirestore.collection('dogs').doc(dogId).update({
        'location': GeoPoint(position.latitude, position.longitude),
      });

      print('Dog location updated successfully.');
    } catch (e) {
      print('Error updating dog location: $e');
    }
  }

  Future<GeoPoint?> getLoggedInDogLocation() async {
  try {
    // Check if loggedInDogUid is not empty or null
    if (loggedInDogUid.isNotEmpty) {
      // Retrieve the logged-in dog's document
      DocumentSnapshot<Map<String, dynamic>> dogSnapshot =
          await _firebaseFirestore.collection('dogs').doc(loggedInDogUid).get();

      // Check if the document exists
      if (dogSnapshot.exists) {
        // Retrieve the 'location' field from the document
        GeoPoint? location = dogSnapshot.data()?['location'];
        print('Got Logged In Dogs Location');
        return location;
      } else {
        print('Dog document not found for ID: $loggedInDogUid');
        return null;
      }
    } else {
      print('loggedInDogUid is empty or null');
      return null;
    }
  } catch (error) {
    print('Error getting logged-in dog location: $error');
    return null;
  }
}


  Future<GeoPoint?> getDogLocation(String ownerUid) async {
  try {
    // Query the 'dogs' collection based on ownerUid
    QuerySnapshot<Map<String, dynamic>> dogsSnapshot =
        await _firebaseFirestore
            .collection('dogs')
            .where('owner', isEqualTo: ownerUid)
            .get();

    // Check if any documents were found
    if (dogsSnapshot.docs.isNotEmpty) {
      // Retrieve the first document and its 'location' field
      GeoPoint? location = dogsSnapshot.docs.first.data()['location'];
      return location;
    } else {
      print('No dog found for owner ID: $ownerUid');
      return null;
    }
  } catch (error) {
    print('Error getting dog location: $error');
    return null;
  }
}

Future<void> CancelAppointment(String appointmentId) async {
  try {
    // Get the reference to the specific appointment document
    DocumentReference<Map<String, dynamic>> appointmentRef =
        _firebaseFirestore.collection('appointments').doc(appointmentId);

    // Update the status field
    await appointmentRef.update({
      'status': 'cancelled',
    });
  } catch (error) {
    print('Error updating appointment status: $error');
    throw error; // Rethrow the error for handling in the calling code
  }
}

Future<void> confirmAppointment(String appointmentId) async {
  try {
    // Get the reference to the specific appointment document
    DocumentReference<Map<String, dynamic>> appointmentRef =
        _firebaseFirestore.collection('appointments').doc(appointmentId);

    // Update the status field
    await appointmentRef.update({
      'status': 'upcoming',
    });
  } catch (error) {
    print('Error updating appointment status: $error');
    throw error; // Rethrow the error for handling in the calling code
  }
}
Future<void> PaidAppointment(String appointmentId) async {
  try {
    // Get the reference to the specific appointment document
    DocumentReference<Map<String, dynamic>> appointmentRef =
        _firebaseFirestore.collection('appointments').doc(appointmentId);

    // Update the status field
    await appointmentRef.update({
      'status': 'completed',
    });
  } catch (error) {
    print('Error updating appointment status: $error');
    throw error; // Rethrow the error for handling in the calling code
  }
}
 
 }
