import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pawfectmatch/screens/dogregistration_screen.dart';
import 'package:pawfectmatch/screens/login_screen.dart';

class RegistrationControl {
  Row loginOption(BuildContext context) {
    return Row(
      children: [
        const Text(
          "Enter your account details below or ",
          style: TextStyle(
              color: Color(0xff545F71),
              fontWeight: FontWeight.normal,
              fontSize: 18),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const LoginScreen()));
          },
          child: const Text(
            "log in",
            style: TextStyle(
              color: Color(0xff545F71),
              fontWeight: FontWeight.w600,
              fontSize: 18,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  void showEULA(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        "User Agreement",
                        style: TextStyle(
                            color: Color(0xff011F3F),
                            fontSize: 36,
                            fontWeight: FontWeight.w600),
                      ),
                      const Text(
                        "By using this dog matchmaking application, you agree to the following terms and conditions:\n",
                        style: TextStyle(
                          color: Color(0xff011F3F),
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        "1. Abuse of Features: ",
                        style: TextStyle(
                            color: Color(0xff011F3F),
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      const Text(
                        "Users are prohibited from engaging in any behavior that may be deemed abusive, harmful, or disruptive to other users. This includes, but is not limited to:\n\u2022Posting offensive, inappropriate, or misleading content.\n\u2022Harassing, bullying, or intimidating other users.\n\u2022Sharing false information, engaging in fraudulent activities, or misrepresenting yourself or your pets.\n",
                        style: TextStyle(
                          color: Color(0xff011F3F),
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        "2. Restriction on External Transactions: ",
                        style: TextStyle(
                            color: Color(0xff011F3F),
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      const Text(
                        "Users are expressly prohibited from conducting or facilitating any form of external transactions within the application. This includes, but is not limited to:\n\u2022Offering dogs or puppies for sale or purchase.\n\u2022Advertising breeding services for monetary gain.\n\u2022Promoting or facilitating any form of commercial or unauthorized activity that involves the direct exchange of money or goods outside the scope of this application.\n",
                        style: TextStyle(
                          color: Color(0xff011F3F),
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        "3. Reporting Violations: ",
                        style: TextStyle(
                            color: Color(0xff011F3F),
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      const Text(
                        "Users are encouraged to report any violations of these terms by other users. Suspected abuses should be reported promptly for investigation and appropriate action by the application administrators.\n",
                        style: TextStyle(
                          color: Color(0xff011F3F),
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        "4. Account Suspension or Termination: ",
                        style: TextStyle(
                            color: Color(0xff011F3F),
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      const Text(
                        "The application reserves the right to suspend or terminate user accounts that violate these terms and conditions. This action may be taken without prior notice if the user is found to be in breach of the agreement.\n",
                        style: TextStyle(
                          color: Color(0xff011F3F),
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        "5. Compliance with Laws and Regulations: ",
                        style: TextStyle(
                            color: Color(0xff011F3F),
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      const Text(
                        "Users must comply with all relevant laws and regulations governing pet ownership, breeding, and online conduct in their respective jurisdictions. Any user found in violation may face legal consequences\n\n",
                        style: TextStyle(
                          color: Color(0xff011F3F),
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        "By continuing to use this application, you acknowledge that you have read and understood the terms and agree to abide by them. Failure to comply may result in the termination of your account.\n",
                        style: TextStyle(
                          color: Color(0xff011F3F),
                          fontSize: 16,
                        ),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          minimumSize:
                              MaterialStateProperty.all(const Size(100, 40)),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Close"),
                      )
                    ],
                  ))),
        );
      },
    );
  }

  Future<void> addToDatabase(
      String uid,
      String username,
      String firstname,
      String lastname,
      String email,
      String password,
      String contactnumber) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'username': username,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'password': password,
      'contactnumber': contactnumber,
      'profilepicture': '',
      'dog': '',
    });
  }

  Future<void> signUserUp(
      bool isAgreed,
      String username,
      String email,
      String password,
      String cpassword,
      String contactnumber,
      String firstname,
      String lastname,
      BuildContext context) async {
    //Sign up
    try {
      if (isAgreed) {
        if (password == cpassword) {
          UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password);

          //Use the newly generated UID as the same document name in Firestore
          String uid = userCredential.user?.uid ?? '';

          addToDatabase(uid, username, firstname, lastname, email, password,
              contactnumber);

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const DogRegistrationScreen()));
        } else {
          showErrorDialog("PWNOMATCH", context);
        }
      } else {
        showErrorDialog("NOEULA", context);
      }
    } on FirebaseAuthException catch (e) {
      showErrorDialog(e.code, context);
    }
  }

  void showErrorDialog(String errorcode, BuildContext context) {
    String message = '';
    switch (errorcode) {
      case 'PWNOMATCH':
        message = "Passwords don't match. Please try again.";
        break;
      case 'NOEULA':
        message = "Please agree to the User Agreement.";
        break;
      case 'weak-password':
        message = "Password too short. Please try again.";
        break;
      default:
        message = errorcode;
        break;
    }
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(message),
          );
        });
  }
}
