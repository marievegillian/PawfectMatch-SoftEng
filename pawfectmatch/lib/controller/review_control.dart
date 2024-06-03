import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfectmatch/models/models.dart';

Future<void> createReview(Review review) async {
  try {
    // Extract revieweeid from the review object
    String revieweeId = review.revieweeId;

    // Get a reference to the Firestore collection
    CollectionReference reviewsCollection =
        FirebaseFirestore.instance.collection('reviews');

    // Add the review to the 'reviews' collection
    await reviewsCollection.add(review.toJson());

    print('Review created successfully.');
    recalculateAverageRating(revieweeId);
  } catch (e) {
    print('Error creating review: $e');
    // Handle the error (e.g., show an error message to the user)
  }
}

Future<void> recalculateAverageRating(String revieweeId) async {
  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('reviews')
        .where('reviewee', isEqualTo: revieweeId)
        .get();

    if (querySnapshot.size > 0) {
      double totalRating = 0.0;

      for (var doc in querySnapshot.docs) {
        totalRating += doc['rating'];
      }

      double averageRating = totalRating / querySnapshot.size;

      // Update the averageRating in the user's document in Firestore
      await FirebaseFirestore.instance
          .collection('dogs')
          .doc(revieweeId)
          .update({'avgRating': averageRating});
    }
  } catch (e) {
    print('Error calculating average rating: $e');
  }
}

Future<List<Map<String, dynamic>>> getReviewsByReviewee(
    String revieweeId) async {
  try {
    // Execute the query
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('reviews')
        .where('reviewee', isEqualTo: revieweeId)
        .get();

    // Extract data from the documents
    List<Map<String, dynamic>> reviews = querySnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.data())
        .toList();

    return reviews;
  } catch (e) {
    print('Error getting reviews: $e');
    return [];
  }
}
