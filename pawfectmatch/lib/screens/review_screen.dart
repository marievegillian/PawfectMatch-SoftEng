import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pawfectmatch/controller/review_control.dart';
import 'package:pawfectmatch/models/models.dart';


class ReviewScreen extends StatefulWidget {
  const ReviewScreen({Key? key}) : super(key: key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final TextEditingController _reviewTxtCtrl = TextEditingController();
  double rating = 0.0;
  String profilepictureurl = '';
  String name = '';
  late String otherdoguid = ''; //retrieve lng diri ang id sa i review na dog

  @override
  void initState() {
    super.initState();
    //Get the dog's id, feed it here para ma get ang name and pfp sa dog
    fetchDogData(otherdoguid);
  }

  Future<void> fetchDogData(String otherdoguid) async {
    try {
      DocumentSnapshot dogSnapshot = await FirebaseFirestore.instance
          .collection('dogs')
          .doc(otherdoguid)
          .get();

      // Use the Dog.fromJson method to create an instance of Dog from the JSON data
      Dog dog = Dog.fromJson(dogSnapshot.data() as Map<String, dynamic>);

      // Update the UI with the data from the Dogs model
      profilepictureurl = dog.profilePicture;
      name = dog.name;

      // Update the UI
      setState(() {});
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top part
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * .55,
              decoration: const BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                  image: AssetImage('assets/img_group_3.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(padding: EdgeInsets.fromLTRB(0, 80, 0, 0)),
                  const Text(
                    'Completed!',
                    style: TextStyle(
                      fontSize: 36.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff545F71),
                    ),
                  ),
                  const SizedBox(height: 20),
                  profilepictureurl.isNotEmpty
                      ? const CircleAvatar(
                          radius: 80.0,
                          backgroundColor: Colors.black,
                        )
                      : CircleAvatar(
                          radius: 80,
                          backgroundImage: NetworkImage(profilepictureurl),
                        ),
                  const SizedBox(height: 5),
                  Text(
                    name.isNotEmpty ? name : 'Dog',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff545F71),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Rate this user:',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Color(0xff545F71),
                    ),
                  ),
                  RatingBar(
                    initialRating: 0,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    glowColor: const Color(0xff545F71),
                    glow: true,
                    glowRadius: 2,
                    tapOnlyMode: true,
                    itemSize: 45,
                    ratingWidget: RatingWidget(
                      full: const Icon(Icons.star_rounded,
                          color: Color(0xff545F71)),
                      half: const Icon(Icons.star_half_rounded,
                          color: Color(0xff545F71)),
                      empty: const Icon(Icons.star_border_rounded,
                          color: Color(0xff545F71)),
                    ),
                    itemPadding: const EdgeInsets.symmetric(horizontal: 2),
                    onRatingUpdate: (value) {
                      setState(() {
                        rating = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            // Bottom part
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * .38,
              color: const Color(0xffB9D4F1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Tell us about your experience:',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Color.fromARGB(255, 52, 58, 68),
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                        child: TextField(
                          controller: _reviewTxtCtrl,
                          maxLines: 7,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            hintText: 'Write your review here...',
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextButton.icon(
                        onPressed: () {
                          Review review = Review(
                              rating: rating,
                              review: _reviewTxtCtrl.text,
                              revieweeId: otherdoguid);

                          createReview(review);
                        },
                        icon: const Icon(Icons.send, color: Colors.white),
                        label: const Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xff545F71),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
