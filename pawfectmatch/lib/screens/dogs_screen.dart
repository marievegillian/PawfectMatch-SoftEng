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
      body: SingleChildScrollView(
      child: Column(
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
                const Text('Bio', 
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
                SizedBox(
                  height: 15,
                ),
                Text('Medical Info', 
                style:TextStyle(
                      fontSize: 15.0,
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
                //Block button starts here
                Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: 50.0,
                  ),
                child: Container(
                  padding: const EdgeInsets.all(18.0),
                  margin: const EdgeInsets.only(
                    top: 25.0,
                    right: 5.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    color: Colors.red,
                  ),
                  child: InkWell(
                      onTap: () async {
                        // Show confirmation dialog
                        bool? confirm = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false, // User must tap a button
                          builder: (BuildContext context) {
                            return AlertDialog(                            
                              title: 
                              const Center(
                                child: Text(
                                  'Confirm Block',
                                   style: TextStyle(
                                    fontSize: 25.0,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w700,                      
                                    color: Color.fromARGB(255, 7, 34, 62),
                                  ),
                                ),
                              ),
                              content: const Text('Are you sure you want to block this user? You cannot undo this action.'),
                              // ),
                              actions: <Widget>[
                                // Column to stack buttons vertically
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0), // Rounded corners
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop(true); // User tapped 'Confirm'
                                      },
                                      child: const Center(
                                        child: Text(
                                          'Yes, block',
                                            style: TextStyle(
                                            fontSize: 18.0,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.bold,                      
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5.0), // Space between buttons
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white, // Background color
                                        // onPrimary: Colors.white, // Text color
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0), // Rounded corners
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop(false); // User tapped 'Cancel'
                                      },
                                      child: const Center(
                                        child: Text(
                                          'Nevermind, go back',
                                          style: TextStyle(
                                          fontSize: 18.0,
                                          fontFamily: 'Roboto',
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

                        // if (confirm == true) {
                        //   // Perform the block action
                        //   String currentUserId = DatabaseRepository().loggedInOwner;
                        //   String ownerIdToBlock = dog.owner;

                        //   await DatabaseRepository().blockProfile(currentUserId, ownerIdToBlock);

                        //   // Show confirmation message
                        //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        //     content: Text('Profile blocked successfully'),
                        //   ));

                        //   // Optionally, navigate back or perform additional actions
                        //   Navigator.pop(context);
                        // }
                      
                        // if (confirm == true) {
                        //     context.read<SwipeBloc>().add(BlockOwner(dogs: state.dogs[0], context: context));
                        //     Navigator.pop(context);
                        // }

                         if (confirm == true) {                          
                            context.read<SwipeBloc>().add(BlockOwner(dogs: dog, context: context));
                            Navigator.pop(context);  // Optionally, you can navigate back after blocking
                          }
                    },
                    child: Center(
                      child: Text(
                        'Block this profile',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,                      
                          color: Colors.white,
                        ),                  
                      ),
                    ),               
                    ),                  
                  ),
                ),
                ),
              ]
              ),
            )
        ],
      ),
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