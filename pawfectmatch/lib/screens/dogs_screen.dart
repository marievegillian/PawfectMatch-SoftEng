import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pawfectmatch/blocs/swipe/swipe_bloc.dart';
import 'package:pawfectmatch/models/models.dart';
import 'package:pawfectmatch/widgets/choice_button.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfectmatch/repositories/database_repository.dart';


class DogsScreen extends StatelessWidget {
  static const String routeName = '/dogs';

  static Route route({required Dog dog}) {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (context) => DogsScreen(dog: dog),
    );
  }

  final Dog dog;

  const DogsScreen({
    required this.dog,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 1.9,
            child: Stack(
              children: [
                Hero(
                  tag: 'dog_image',
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        image: DecorationImage(
                          image: NetworkImage(dog.profilePicture),
                          fit: BoxFit.cover
                          ), 
                        ),
                      ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 60,
                    ),
                    child: BlocBuilder<SwipeBloc, SwipeState>(
                      builder: (context, state) {
                        if (state is SwipeLoading) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (state is SwipeLoaded) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () {
                                  context.read<SwipeBloc>()..add(SwipeLeft(dogs: state.dogs[0]));
                                  Navigator.pop(context);
                                  print('Swiped Left');
                                },
                                child: ChoiceButton(
                                  width: 70,
                                  height: 70,
                                  size: 30,
                                  color: Colors.redAccent, 
                                  icon: Icons.clear_rounded
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  context.read<SwipeBloc>()..add(SwipeRight(dogs: state.dogs[0], context: context));
                                  Navigator.pop(context);
                                  print('Swiped Right');
                                },
                                child: ChoiceButton(
                                  width: 70,
                                  height: 70,
                                  size: 30,
                                  color: Colors.greenAccent, 
                                  icon: Icons.favorite
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Text('Something went wrong.');
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${dog.name}, ${dog.calculateAge()}',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                FutureBuilder<GeoPoint?>(
                  // Use FutureBuilder to asynchronously get the logged-in dog's location
                  future: DatabaseRepository().getDogLocation(DatabaseRepository().loggedInOwner),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error loading location');
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return Text('Location not available');
                    } else {
                      GeoPoint? loggedInDogLocation = snapshot.data;

                      return FutureBuilder<GeoPoint?>(
                        future: DatabaseRepository().getDogLocation(dog.owner),
                        builder: (context, otherDogSnapshot) {
                          if (otherDogSnapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (otherDogSnapshot.hasError) {
                            return Text('Error loading other dog\'s location');
                          } else if (!otherDogSnapshot.hasData || otherDogSnapshot.data == null) {
                            return Text('Other dog\'s location not available');
                          } else {
                            GeoPoint? otherDogLocation = otherDogSnapshot.data;
                            double distance = loggedInDogLocation != null
                                ? calculateDistance(loggedInDogLocation, otherDogLocation!)
                                : 0.0;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${distance.toStringAsFixed(2)} km',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      );
                    }
                  },
                ),
                SizedBox(height: 15,),
                Text('Bio', 
                style:TextStyle(
                      fontSize: 20.0,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold, 
                      color: Colors.black
                      ),
                    ),
                Text('${dog.bio}', 
                style:TextStyle(
                      fontSize: 15.0,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.normal, 
                      color: Colors.black
                      ),
                    ),
                SizedBox(height: 10,),
                Text('Breed', 
                style:TextStyle(
                      fontSize: 17.0,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold, 
                      color: Colors.black
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5.0),
                      margin: const EdgeInsets.only(
                        top:5.0,
                        right: 5.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        gradient: LinearGradient(colors: [
                          Colors.blueGrey,
                          Colors.black,
                        ])),
                      child:Text('${dog.breed}',
                      style:TextStyle(
                      fontSize: 15.0,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.normal, 
                      color: Colors.white)
                    )
                ),
                SizedBox(height: 10,),
                Text('Vaccination Status', 
                style:TextStyle(
                      fontSize: 17.0,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold, 
                      color: Colors.black
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5.0),
                      margin: const EdgeInsets.only(
                        top:5.0,
                        right: 5.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        gradient: LinearGradient(colors: [
                          Colors.blueGrey,
                          Colors.black,
                        ])),
                      child:Text(
                      dog.isVaccinated ? 'Complete' : 'Incomplete',
                      style:TextStyle(
                      fontSize: 15.0,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.normal, 
                      color: Colors.white)
                    )
                ),
                SizedBox(height: 15,),
                Text('Medical Info', 
                style:TextStyle(
                      fontSize: 17.0,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold, 
                      color: Colors.black
                      ),
                    ),
                Text('Med ID: ${dog.medID}', 
                style:TextStyle(
                      fontSize: 15.0,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.normal, 
                      color: Colors.black
                      ),
                    ),
              ]
              ),
            )
        ],
      ),
    );
  }

   double calculateDistance(GeoPoint location1, GeoPoint location2) {
  const double earthRadius = 6371; // Radius of the earth in kilometers

  // Convert latitude and longitude from degrees to radians
  double lat1 = location1.latitude * (pi / 180);
  double lon1 = location1.longitude * (pi / 180);
  double lat2 = location2.latitude * (pi / 180);
  double lon2 = location2.longitude * (pi / 180);

  // Calculate the change in coordinates
  double dLat = lat2 - lat1;
  double dLon = lon2 - lon1;

  // Haversine formula to calculate distance
  double a = pow(sin(dLat / 2), 2) +
      cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  // Calculate the distance in kilometers
  double distance = earthRadius * c;

  return distance;
}

}