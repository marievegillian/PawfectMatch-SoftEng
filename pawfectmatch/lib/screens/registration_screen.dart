import 'package:flutter/material.dart';
import 'package:pawfectmatch/resources/reusable_widgets.dart';
import 'package:pawfectmatch/controller/registration_control.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _pwTxtCtrl = TextEditingController();
  final TextEditingController _emailTxtCtrl = TextEditingController();
  final TextEditingController _userTxtCtrl = TextEditingController();
  final TextEditingController _contactTxtCtrl = TextEditingController();
  final TextEditingController _cpwTxtCtrl = TextEditingController();
  final TextEditingController _fnTxtCtrl = TextEditingController();
  final TextEditingController _lnTxtCtrl = TextEditingController();
  bool _isAgreed = false;

  final RegistrationControl _registrationControl = RegistrationControl();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xffc8dcf4),
          image: DecorationImage(
            image: AssetImage('assets/img_group_4.png'),
            fit: BoxFit.cover,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text("Create an account",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 36,
                        color: Color(0xff011F3F),
                        fontWeight: FontWeight.w600)),
                //Redirects you to the login page.
                _registrationControl.loginOption(context),
                const SizedBox(height: 30),
                const Text("Username",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, color: Color(0xff011F3F))),
                reusableInputTextField(
                    "Enter username", _userTxtCtrl, TextInputType.text),
                const SizedBox(height: 20),
                const Text("Email",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, color: Color(0xff011F3F))),
                reusableInputTextField("Enter email address", _emailTxtCtrl,
                    TextInputType.emailAddress),
                const SizedBox(height: 20),
                const Text("Contact Number",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, color: Color(0xff011F3F))),
                reusableInputTextField(
                    "Enter phone number", _contactTxtCtrl, TextInputType.phone),
                const SizedBox(height: 20),
                const Text("First Name",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, color: Color(0xff011F3F))),
                reusableInputTextField(
                    "Enter first name", _fnTxtCtrl, TextInputType.text),
                const SizedBox(height: 20),
                const Text("Last Name",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, color: Color(0xff011F3F))),
                reusableInputTextField(
                    "Enter last name", _lnTxtCtrl, TextInputType.text),
                const SizedBox(height: 20),
                const Text("Password",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, color: Color(0xff011F3F))),
                ReusablePasswordField(
                  text: "Enter password",
                  ctrl: _pwTxtCtrl,
                ),
                const SizedBox(height: 20),
                const Text("Confirm Password",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, color: Color(0xff011F3F))),
                ReusablePasswordField(
                  text: "Confirm password",
                  ctrl: _cpwTxtCtrl,
                ),
                Row(
                  children: [
                    Checkbox(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                      activeColor: const Color(0xff011F3F),
                      value: _isAgreed,
                      onChanged: (value) {
                        setState(() {
                          _isAgreed = value!;
                        });
                      },
                    ),
                    const Text(
                      "I agree to the ",
                      style: TextStyle(
                        color: Color(0xff545F71),
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _registrationControl.showEULA(context);
                      },
                      child: const Text(
                        "User Agreement",
                        style: TextStyle(
                          color: Color(0xff545F71),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                loginRegisterButton(context, false, () {
                  _registrationControl.signUserUp(
                      _isAgreed,
                      _userTxtCtrl.text,
                      _emailTxtCtrl.text,
                      _pwTxtCtrl.text,
                      _cpwTxtCtrl.text,
                      _contactTxtCtrl.text,
                      _fnTxtCtrl.text,
                      _lnTxtCtrl.text,
                      context);
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
