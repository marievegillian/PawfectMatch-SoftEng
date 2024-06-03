import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

//REUSABLE CODE GOES HERE TO MINIMIZE CODE DUPLICATION

pickImage(ImageSource src) async {
  final ImagePicker imgPicker = ImagePicker();
  XFile? file = await imgPicker.pickImage(source: src);
  if (file != null) {
    return await file.readAsBytes();
  }
}

Future<String> uploadImgToStorage(
    String childname, Uint8List file, FirebaseStorage _storage) async {
  Reference ref = _storage.ref().child(childname);
  UploadTask uploadTask = ref.putData(file);
  TaskSnapshot snapshot = await uploadTask;
  String download = await snapshot.ref.getDownloadURL();

  return download;
}

Center logoWidget(String imageurl) {
  return Center(
    child: SvgPicture.asset(
      imageurl,
      fit: BoxFit.fitWidth,
      width: 150,
      height: 150,
    ),
  );
}

Container editProfileButton(BuildContext context, Function onTap) {
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
                return const Color(0xff0F3E48).withOpacity(0.8);
              }
              return const Color(0xff0F3E48);
            }),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)))),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Edit Profile",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 18),
            ),
            SizedBox(
              width: 7,
            ),
            Icon(
              Icons.edit_square,
              color: Colors.white,
            ),
          ],
        )),
  );
}

SizedBox reusableInputTextField(
    String text, TextEditingController ctrl, TextInputType texttype) {
  return SizedBox(
    height: 50,
    child: TextField(
      controller: ctrl,
      enableSuggestions: true,
      autocorrect: true,
      cursorColor: Colors.white,
      style: TextStyle(color: const Color(0xff011F3F).withOpacity(0.9)),
      decoration: InputDecoration(
        labelText: text,
        labelStyle: TextStyle(color: const Color(0xff011F3F).withOpacity(0.9)),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(width: 0, style: BorderStyle.solid),
        ),
      ),
      keyboardType: texttype,
    ),
  );
}

// TextField reusablePasswordField(String text, TextEditingController ctrl) {
//   bool isPWVisible = false;
//   // IconData visible = Icons.visibility;
//   // IconData invisible = Icons.visibility_off;
//   return TextField(
//     controller: ctrl,
//     obscureText: !isPWVisible,
//     enableSuggestions: false,
//     autocorrect: false,
//     cursorColor: Colors.white,
//     style: TextStyle(color: const Color(0xff011F3F).withOpacity(0.9)),
//     decoration: InputDecoration(
//       suffixIcon: GestureDetector(
//         onTap: () {
//           isPWVisible = !isPWVisible;
//         },
//         child: const Icon(Icons.visibility, color: Color(0xff011F3F)),
//       ),
//       labelText: text,
//       labelStyle: TextStyle(color: const Color(0xff011F3F).withOpacity(0.9)),
//       filled: true,
//       floatingLabelBehavior: FloatingLabelBehavior.never,
//       fillColor: Colors.white.withOpacity(0.3),
//       border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(5),
//           borderSide: const BorderSide(width: 0, style: BorderStyle.solid)),
//     ),
//     keyboardType: TextInputType.visiblePassword,
//   );
// }

Container loginRegisterButton(
    BuildContext context, bool isLogin, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return const Color(0xff011F3F).withOpacity(0.8);
            }
            return const Color(0xff011F3F);
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)))),
      child: Text(
        isLogin ? "Log-in" : "Register",
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
  );
}

class ReusablePasswordField extends StatefulWidget {
  final String text;
  final TextEditingController ctrl;

  const ReusablePasswordField({required this.text, required this.ctrl});

  @override
  _ReusablePasswordFieldState createState() => _ReusablePasswordFieldState();
}

class _ReusablePasswordFieldState extends State<ReusablePasswordField> {
  bool isPWVisible = false;
  IconData visible = Icons.visibility_off;
  IconData invisible = Icons.visibility;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 50,
        child: TextField(
          controller: widget.ctrl,
          obscureText: !isPWVisible,
          enableSuggestions: false,
          autocorrect: false,
          cursorColor: Colors.white,
          style: TextStyle(color: const Color(0xff011F3F).withOpacity(0.9)),
          decoration: InputDecoration(
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  isPWVisible = !isPWVisible;
                });
              },
              child: Icon(
                isPWVisible ? visible : invisible,
                color: const Color(0xff011F3F),
              ),
            ),
            labelText: widget.text,
            labelStyle:
                TextStyle(color: const Color(0xff011F3F).withOpacity(0.9)),
            filled: true,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            fillColor: Colors.white.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(width: 0, style: BorderStyle.solid),
            ),
          ),
          keyboardType: TextInputType.visiblePassword,
        ));
  }
}

enum Gender {
  male,
  female,
}

enum Vaccinated {
  isVaccinated,
  isNotVaccinated,
}