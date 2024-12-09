// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:pawfectmatch/blocs/swipe/swipe_bloc.dart';
// import '../models/models.dart';

// class BlockButton extends StatelessWidget {
//   final Dog dog;

//   const BlockButton({Key? key, required this.dog}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(minWidth: 100.0),
//         child: Container(
//           padding: const EdgeInsets.all(18.0),
//           margin: const EdgeInsets.only(top: 25.0, right: 5.0),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(15.0),
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.5),
//                 spreadRadius: 2,
//                 blurRadius: 5,
//                 offset: const Offset(0, 3),
//               ),
//             ],
//           ),
//           child: InkWell(
//             onTap: () async {
//               bool? confirm = await showDialog<bool>(
//                 context: context,
//                 barrierDismissible: false,
//                 builder: (BuildContext context) {
//                   return AlertDialog(
//                     title: const Center(
//                       child: Text(
//                         'Confirm Block',
//                         style: TextStyle(
//                           fontSize: 25.0,
//                           fontWeight: FontWeight.w700,
//                           color: Color.fromARGB(255, 7, 34, 62),
//                         ),
//                       ),
//                     ),
//                     content: const Text(
//                       'Are you sure you want to block this user? You cannot undo this action.',
//                     ),
//                     actions: [
//                       Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.red,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                             ),
//                             onPressed: () {
//                               Navigator.of(context).pop(true);
//                             },
//                             child: const Text(
//                               'Yes, block',
//                               style: TextStyle(
//                                 fontSize: 18.0,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 5.0),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                             ),
//                             onPressed: () {
//                               Navigator.of(context).pop(false);
//                             },
//                             child: const Text(
//                               'Nevermind, go back',
//                               style: TextStyle(
//                                 fontSize: 18.0,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.blue,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   );
//                 },
//               );

//               if (confirm == true) {
//                 context.read<SwipeBloc>().add(BlockOwner(dogs: dog, context: context));
//                 Navigator.pop(context); 
//               }
//             },
//             child: const Text(
//               'Block this profile',
//               style: TextStyle(
//                 fontSize: 16.0,
//                 fontWeight: FontWeight.bold,
//                 color: Color.fromARGB(255, 255, 10, 10),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pawfectmatch/blocs/swipe/swipe_bloc.dart';
import '../models/models.dart';

class BlockButton extends StatelessWidget {
  final Dog dog;

  const BlockButton({Key? key, required this.dog}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), 
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Container(
            padding: const EdgeInsets.all(18.0),
            margin: const EdgeInsets.only(top: 25.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: InkWell(
              onTap: () async {
                bool? confirm = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Center(
                        child: Text(
                          'Confirm Block',
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 7, 34, 62),
                          ),
                        ),
                      ),
                      content: const Text(
                        'Are you sure you want to block this user? You cannot undo this action.',
                        style: TextStyle(
                            fontSize: 15.0,
                            color: Color.fromARGB(255, 7, 34, 62),
                        ),
                      ),
                      actions: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text(
                                  'Yes, block',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text(
                                  'Nevermind, go back',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  context.read<SwipeBloc>().add(BlockOwner(dogs: dog, context: context));
                  Navigator.pop(context);
                }
              },
              child:Center(
                child: const Text(
                  'Block this profile',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 10, 10),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
