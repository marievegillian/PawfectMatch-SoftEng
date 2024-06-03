import 'package:flutter/material.dart';
import 'package:pawfectmatch/resources/reusable_widgets.dart';
import 'package:pawfectmatch/controller/login_control.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _pwTxtCtrl = TextEditingController();
  final TextEditingController _emailTxtCtrl = TextEditingController();

  //Instantiate controller
  final LoginControl _loginControl = LoginControl();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xffF1F6F8),
          image: DecorationImage(
            image: AssetImage('assets/img_group_24.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              logoWidget('assets/Logo.svg'),
              const SizedBox(height: 50),
              const Center(
                child: Text(
                  "Welcome",
                  style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff011F3F)),
                ),
              ),
              //Redirects you to the registration page.
              _loginControl.registerOption(context),
              const SizedBox(height: 50),
              const Text("Email",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 18, color: Color(0xff011F3F))),
              reusableInputTextField(
                  "Enter email", _emailTxtCtrl, TextInputType.emailAddress),
              const SizedBox(height: 35),
              const Text("Password",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 18, color: Color(0xff011F3F))),
              ReusablePasswordField(
                text: "Enter password",
                ctrl: _pwTxtCtrl,
              ),
              const SizedBox(
                height: 60,
              ),
              loginRegisterButton(context, true, () {
                _loginControl.signUserIn(context, _emailTxtCtrl, _pwTxtCtrl);
              })
            ],
          ),
        )),
      ),
    );
  }
}
