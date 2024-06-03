import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawfectmatch/screens/home_screen.dart';
import 'package:pawfectmatch/screens/registration_screen.dart';

class LoginControl {
  Future<void> signUserIn(BuildContext context, TextEditingController emailCtrl,
      TextEditingController passwordCtrl) async {
    // Sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text,
        password: passwordCtrl.text,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      showErrorDialog(context, e.code);
    }
  }

  void showErrorDialog(BuildContext context, String errorCode) {
    String message = '';
    switch (errorCode) {
      // Cases for different error codes
      case 'INVALID_LOGIN_CREDENTIALS':
        message = "Incorrect email or password. Please try again.";
        break;
      case 'invalid-email':
        message =
            "The email you have entered is not a valid email. Please try again.";
        break;
      case 'channel-error':
        message = "Please enter an email and password.";
        break;
      default:
        message = errorCode;
        break;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(message),
        );
      },
    );
  }

  Row registerOption(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Login below or ",
          style: TextStyle(
            color: Color(0xff011F3F),
            fontWeight: FontWeight.normal,
            fontSize: 18,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegistrationScreen(),
              ),
            );
          },
          child: const Text(
            "create an account",
            style: TextStyle(
              color: Color(0xff011F3F),
              fontWeight: FontWeight.w600,
              fontSize: 18,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
