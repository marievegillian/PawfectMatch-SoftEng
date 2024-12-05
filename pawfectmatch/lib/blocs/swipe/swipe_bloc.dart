import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pawfectmatch/models/models.dart';
import 'package:pawfectmatch/repositories/repositories.dart';
import 'package:pawfectmatch/utils/filter_manager.dart';
import 'package:pawfectmatch/widgets/matched_popup.dart';
import 'package:geolocator/geolocator.dart';

part 'swipe_event.dart';
part 'swipe_state.dart';

class SwipeBloc extends Bloc<SwipeEvent, SwipeState> {
  final DatabaseRepository _databaseRepository;

  SwipeBloc({
    required DatabaseRepository databaseRepository,
  })  : _databaseRepository = databaseRepository, 
        super(SwipeLoading()){
    on<LoadDogs>(_onLoadDogs);
    on<UpdateHome>(_onUpdateHome);
    on<SwipeLeft>(_onSwipeLeft);
    on<SwipeRight>(_onSwipeRight);
    on<BlockOwner>(_onBlockOwner);

  }

void _onLoadDogs(
  LoadDogs event,
  Emitter<SwipeState> emit,
) async {
  try {
    emit(SwipeLoading()); // Emit SwipeLoading state before loading dogs

    // Fetch dogs from the repository
    final dogsStream = _databaseRepository.getDogs();

    // Listen to the stream and get the first result
    final List<Dog> allDogs = await dogsStream.first;

    // Fetch liked dogs
    final List<String> likedDogs = await _databaseRepository.getLikedDogs();

    // Fetch blocked owners
    final List<String> blockedOwners = await _databaseRepository.getBlockedOwners();

    //get the filtered dogs based on the filter feature
    
    print('All Dogs: ${allDogs.map((dog) => dog.owner).toList()}');
    print('Liked Dogs Owners: $likedDogs');
    print('Blocked Owners: $blockedOwners');

    // Filter out liked dogs
    // final List<Dog> filteredDogs =
    //     allDogs.where((dog) => !likedDogsOwners.contains(dog.owner)).toList();

    // Filter out liked dogs and blocked owners //ORIGINAL
    // final List<Dog> filteredDogs = allDogs.where((dog) =>
    //     !likedDogs.contains(dog.dogId) &&
    //     !blockedOwners.contains(dog.owner)).toList();

    // Get filters dynamically
    final filters = FilterManager().filters;
    print('Filters: $filters');

    // Max distance for filtering
    final double? maxDistance = filters['maxDistance']; // Max distance in kilometers
    final GeoPoint? userLocation = await _databaseRepository.getDogLocation(DatabaseRepository().loggedInOwner); // Fetch user's actual location

    if (userLocation == null) {
      print('Error: User location is not available');
      emit(SwipeError());
      return;
    }

    // Fetch all dog locations asynchronously
    Map<String, GeoPoint?> dogLocations = {};
    for (var dog in allDogs) {
      dogLocations[dog.owner] = await _databaseRepository.getDogLocation(dog.owner);
    }

    // Apply filters
    final List<Dog> filteredDogs = allDogs.where((dog) {
      int dogAge = 0;
    //int dogDistance = 0;
      // print("Dog name: ${dog.name}; Dog location" ${dog.}");

      if(dog.birthday!= ''){
        dogAge = calculateAge(dog.birthday);
      }

      if (likedDogs.contains(dog.dogId) || blockedOwners.contains(dog.owner)) {
        return false;
      }

      if (filters['gender'] != 'Any' && dog.isMale != (filters['gender'] == 'Male')) {
        return false;
      }      

      if (dogAge < filters['ageRange'].start || dogAge > filters['ageRange'].end) {
        return false;
      }

      //TEMPORARILY COMMENTED
      //DO NOT REMOVE!
      // if (filters['breeds'].isNotEmpty && !filters['breeds'].contains(dog.breed)) {
      //   return false;
      // }

      print("im calculating distance here yo");

      // Distance filter
      if (maxDistance != null) {
        final GeoPoint? dogLocation = dogLocations[dog.owner];
        if (dogLocation != null) {
          double distance = calculateDistance(
            userLocation.latitude,
            userLocation.longitude,
            dogLocation.latitude,
            dogLocation.longitude,
          );
          print("Dog name: ${dog.name}, Dog distance: $distance");

          if (distance > maxDistance) return false;
          
        }
      } else {
        print("distance is null.....");
        return true;
      }

      return true;
    }).toList();

    
    print('Filtered Dogs: ${filteredDogs.map((dog) => dog.owner).toList()}');

    emit(SwipeLoaded(dogs: filteredDogs));
  } catch (error) {
    print('Error loading dogs: $error');
    emit(SwipeError());
  }
}

int calculateAge(String birthday) {
    DateTime now = DateTime.now();    
    DateTime birthDate = DateTime.parse(birthday);
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

double calculateDistance(
  double startLatitude,
  double startLongitude,
  double endLatitude,
  double endLongitude,
) {
  print("im calculating distance here yo");
  return Geolocator.distanceBetween(
    startLatitude,
    startLongitude,
    endLatitude,
    endLongitude,
  ) / 1000; // Convert meters to kilometers
}

  void _onUpdateHome(
    UpdateHome event,
    Emitter<SwipeState> emit,
  ) {
    print('i am going insane UPDATE HOME');
    if (event.dogs != null) {
      emit(SwipeLoaded(dogs: event.dogs!));
    } else {
      emit(SwipeError());
    }
  }

  void _onSwipeLeft(
    SwipeLeft event,
    Emitter<SwipeState> emit,
  ) {
    if (state is SwipeLoaded) {
      final state = this.state as SwipeLoaded;
      List<Dog> dogs = List.from(state.dogs)..remove(event.dogs);

      if (dogs.isNotEmpty) {
        emit(SwipeLoaded(dogs: dogs));
      } else {
        emit(SwipeError());
      }
    }
  }

void _onSwipeRight(
  SwipeRight event,
  Emitter<SwipeState> emit,
) async {
  if (state is SwipeLoaded) {
    final state = this.state as SwipeLoaded;
    //remove the liked dog/s from the list of dogs to be displayed in the matching screen 
    List<Dog> dogs = List.from(state.dogs)..remove(event.dogs);      
   
    if (dogs.isNotEmpty) {
      emit(SwipeLoaded(dogs: dogs));

      // Get the owner ID of the swiped dog
      String likedDogId = event.dogs.dogId;
      print("The dog id liked was: $likedDogId");

      // Update the likedDogs collection in Firestore
      await _databaseRepository.updateLikedDogsInFirestore(likedDogId); 

      bool isMatch = await _databaseRepository.checkMatch(likedDogId);

      if (isMatch) {
        // Update the matches collection in Firestore
        print('Updating matches collection...');
        await _databaseRepository.updateMatched(likedDogId);
        print('Matches collection updated successfully.');

        // Show the matched popup
        print('Showing matched popup...');
        _showMatchedPopup(event.context, event.dogs.profilePicture);
        print('Matched popup displayed.');

        // Create a conversation
        String loggedInDog =  _databaseRepository.loggedInDogUid;
        print('Creating conversation...');
        await _databaseRepository.createConversation(loggedInDog, likedDogId); //change this to the dog currently on
        print('Conversation created successfully.');
      }
    } else {
      emit(SwipeError());
    }
  }
}



void _showMatchedPopup(BuildContext context, String dogProfilePictureUrl) {
  print('Navigating to matched popup screen...');
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => MatchedPopup(dogProfilePictureUrl: dogProfilePictureUrl),
    ),
  );
}


void _onBlockOwner(
  BlockOwner event,
  Emitter<SwipeState> emit,
) async {
  if (state is SwipeLoaded) {
    final state = this.state as SwipeLoaded;
    //remove the liked dog/s from the list of dogs to be displayed in the matching screen 
    // List<Dog> dogs = List.from(state.dogs)..remove(event.dogs);   
    List<Dog> dogs = List.from(state.dogs)
      ..removeWhere((dog) => dog.owner == event.dogs.owner);   
   
    if (dogs.isNotEmpty) {
      emit(SwipeLoaded(dogs: dogs));

      // Get the owner ID of the swiped dog
      String blockedOwnerId = event.dogs.owner;

      // Update the likedDogs collection in Firestore
      await _databaseRepository.updateBlockedOwnersInFirestore(blockedOwnerId);
      print('User blocked successfully');

    } else {
      emit(SwipeError());
    }
  }
}
  
}