import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawfectmatch/screens/login_screen.dart';
import 'package:pawfectmatch/payment/paymongo_service.dart';
import 'package:pawfectmatch/utils/filter_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<int> getDogProfileCount(String userId) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('ownedDogs')
        .get();

    return querySnapshot.docs.length;
  } catch (e) {
    print('Error fetching dog profiles count: $e');
    return 0; // Return 0 on failure to avoid errors
  }
}

Future<int> getArrayLength(String userId) async {
  try {
    // Reference to your Firestore document
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users') // Collection name
        .doc(userId) // Document ID
        .get();

    // Check if the document exists and the field is present
    if (documentSnapshot.exists && documentSnapshot.data() != null) {
      List<dynamic> itemsArray = documentSnapshot.get('ownedDogs');
      return itemsArray.length; // Return the length of the array
    } else {
      return 0; // Return 0 if document or field doesn't exist
    }
  } catch (e) {
    print('Error fetching array length: $e');
    return 0; // Return 0 on error
  }
}

void signUserOut(BuildContext context) {
  FirebaseAuth.instance.signOut();
  clearPreferences();
  clearFilters();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const LoginScreen(),
    ),
  );
}

Future<void> clearPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

void clearFilters() {
  FilterManager().filters = {
    'gender': 'Any',
    'ageRange': const RangeValues(0, 20),
    'breeds': [],
    'maxDistance': null,
  };
}

void createAdditionalDogCheckout(BuildContext context) async {
  final paymentService = PaymentService();

  try {
    final response = await paymentService.createCheckoutSession(
      description: 'Add additional dog profile',
      successUrl: 'https://marievegillian.github.io/Redirect/',
      lineItems: [
        {
          "currency": "PHP",
          "amount": 10000, // Amount in cents (PHP 100.00)
          "name": "Additional Dog Profile",
          "quantity": 1,
          "description": "Add a third or more dog profile",
        },
      ],
    );

    print('Checkout Session Created: ${response['data']}');

    // Redirect user to the checkout URL
    final checkoutUrl = response['data']['attributes']['checkout_url'];
    if (checkoutUrl != null) {
      _launchCheckoutPage(checkoutUrl);
    }
  } catch (e) {
    print('Error creating checkout session: $e');
  }
}

void createProfileBoostCheckout(BuildContext context) async {
  final paymentService = PaymentService();

  try {
    final response = await paymentService.createCheckoutSession(
      description: 'Boost profile for 3 days',
      successUrl: 'https://marievegillian.github.io/Redirect/',
      lineItems: [
        {
          "currency": "PHP",
          "amount": 5000, // Amount in cents (PHP 70.00)
          "name": "Boost profile visibility",
          "quantity": 1,
          "description": "Boost",
        },
      ],
    );

    print('Checkout Session Created: ${response['data']}');
    // Redirect user to the checkout session's URL if needed
    final checkoutUrl = response['data']['attributes']['checkout_url'];
    if (checkoutUrl != null) {
      _launchCheckoutPage(checkoutUrl);
    }
  } catch (e) {
    print('Error creating checkout session: $e');
  }
}

Future<void> handleAddDogPayment(BuildContext context) async {
  final paymentService = PaymentService();

  try {
    final response = await paymentService.createCheckoutSession(
      description: 'Add Additional Dog Profile',
      successUrl: 'https://marievegillian.github.io/Redirect/',
      lineItems: [
        {
          "currency": "PHP",
          "amount": 10000, // PHP 100.00 (in cents)
          "name": "Additional Dog Profile",
          "quantity": 1,
          "description": "Add a 3rd dog profile",
        },
      ],
    );

    // Redirect user to PayMongo checkout URL
    final checkoutUrl = response['data']['attributes']['checkout_url'];
    if (checkoutUrl != null) {
      await _launchCheckoutPage(checkoutUrl);
    }
  } catch (e) {
    print('Error processing payment: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to process payment.')),
    );
  }
}

Future<void> _launchCheckoutPage(String checkoutUrl) async {
  final Uri url = Uri.parse(checkoutUrl);
  if (await canLaunchUrl(url)) {
    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  } else {
    throw 'Could not launch $checkoutUrl';
  }
}

// void _launchCheckoutPage(String checkoutUrl) async {
//   final Uri url = Uri.parse(checkoutUrl);
//   if (await canLaunchUrl(url)) {
//     await launchUrl(
//       url,
//       mode: LaunchMode.externalApplication,
//     );
//   } else {
//     throw 'Could not launch $checkoutUrl';
//   }
// }

Container signOutButton(BuildContext context, Function onTap) {
  return Container(
    width: 185,
    height: 43,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    child: ElevatedButton(
        onPressed: () {
          onTap();
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return const Color(0xffFF2C2C).withOpacity(0.8);
              }
              return const Color(0xffFF2C2C);
            }),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)))),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Sign Out",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 18),
            ),
            SizedBox(
              width: 7,
            ),
            Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ],
        )),
  );
}

Container boostButton(BuildContext context, Function onTap) {
  return Container(
    width: 185,
    height: 43,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    child: ElevatedButton(
        onPressed: () {
          onTap();
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return const Color(0xffFF2C2C).withOpacity(0.8);
              }
              return const Color(0xffFF2C2C);
            }),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)))),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Boost",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 18),
            ),
            SizedBox(
              width: 7,
            ),
            Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ],
        )),
  );
}

GestureDetector clickableDogPicture(BuildContext context, Function onTap) {
  return GestureDetector(
    onTap: () {},
    //child: If user has no dogs, there would just be a blank circle provided by nullDog();
    //If user has 1 dog, there would be two circles, one of the dog and one with nullDog() to signify that the user can add another dog
    //If user has 2 dogs, again there would be three circles, two of which would be the dogs, and the third one with nullDog().
    //If user has 3 dogs, then there would just be three pictures of dogs, since the maximum amount is 3.
  );
}

SizedBox nullDog() {
  return SizedBox(
      width: 100,
      height: 100,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Container(
          color: Colors.black,
        ),
      ));
}
