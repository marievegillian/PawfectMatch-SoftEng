import 'package:flutter/material.dart';
import 'package:pawfectmatch/screens/screens.dart';

import '../models/dog_model.dart';

class DogCard extends StatelessWidget{
  final Dog dog;

  const DogCard({Key? key,
  required this.dog,
  }) : super (key: key);

   @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'dog_image',
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
        child: SizedBox(
          height: MediaQuery.of(context).size.height / 1.5,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(dog.profilePicture),
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 8,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(200, 0, 0, 0),
                      Color.fromARGB(0, 0, 0, 0),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${dog.name}, ${dog.calculateAge()}',
                      style: TextStyle(
                        fontSize: 35.0,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(width: 10),
                        GestureDetector(
                          child: SizedBox(
                            width: 45,
                            height: 45,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                color: const Color(0xff0F3E48),
                                padding: const EdgeInsets.all(2),
                                child: const Icon(
                                  Icons.arrow_downward_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DogsScreen(dog: dog),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}