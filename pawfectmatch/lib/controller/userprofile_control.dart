import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawfectmatch/screens/login_screen.dart';
import 'package:pawfectmatch/payment/paymongo_service.dart';
import 'package:url_launcher/url_launcher.dart';

void signUserOut(BuildContext context) {
  FirebaseAuth.instance.signOut();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const LoginScreen(),
    ),
  );
}

void createProfileBoostCheckout(BuildContext context) async {
  final paymentService = PaymentService();

  try {
    final response = await paymentService.createCheckoutSession(
      description: 'Boost profile for 3 days',
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

void _launchCheckoutPage(String checkoutUrl) async {
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
              "Boost Profile",
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
