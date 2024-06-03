import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final CollectionReference dogsCollection = FirebaseFirestore.instance.collection('dogs');


  Future<List<Map<String, dynamic>>> getDogsExcludingLoggedInDog(String doguid) async {
    try {
      // Get a reference to the dogs collection
      CollectionReference dogsCollection = FirebaseFirestore.instance.collection('dogs');

      // Get all dogs excluding the logged-in dog
      QuerySnapshot querySnapshot = await dogsCollection.where('doguid', isNotEqualTo: doguid).get();

      // Convert QuerySnapshot to List<Map<String, dynamic>>
      List<Map<String, dynamic>> dogsData = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      // Return the list of dogs as JSON objects
      return dogsData;
    } catch (e) {
      print('Error fetching dogs: $e');
      return [];
    }
  }

   Future<bool> getLoggedInDogIsMale(String loggedInDogUid) async {
    try {
      DocumentSnapshot dogSnapshot = await dogsCollection.doc(loggedInDogUid).get();

      // Replace 'gender' with the actual field name in your dog model that represents gender
      bool isMale = dogSnapshot.get('isMale') == 'true';

      return isMale;
    } catch (e) {
      print('Error fetching dog details: $e');
      return false; // Return a default value or handle the error accordingly
    }
  }


  Future<void> updateLikedDogs(String dogUid, List<String> likedDogOwnerIds) async {
  try {
    // Get a reference to the 'likedDogs' subcollection for the specified dog
    CollectionReference<Map<String, dynamic>> likedDogsCollection =
        dogsCollection.doc(dogUid).collection('likedDogs');

    // Fetch the current liked dogs for the user
    QuerySnapshot<Map<String, dynamic>> likedDogsSnapshot =
        await likedDogsCollection.get();
    List<String> currentLikedDogs =
        likedDogsSnapshot.docs.map((doc) => doc.id).toList();

    // Combine the existing liked dogs with the new ones and remove duplicates
     List<String> updatedLikedDogs =
        Set<String>.from([...currentLikedDogs, ...likedDogOwnerIds]).toList();

    // Clear existing documents in the 'likedDogs' subcollection
    await likedDogsCollection.get().then(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
          doc.reference.delete();
        }
      },
    );

    // Add new documents with empty data to represent liked dogs
    updatedLikedDogs.forEach((likedDogOwnerId) async {
      await likedDogsCollection.doc(likedDogOwnerId).set({'owner': likedDogOwnerId});
    });

    print('Liked dogs updated successfully');
  } catch (e) {
    print('Error updating liked dogs in Firestore: $e');
  }
}


}
