import 'package:equatable/equatable.dart';
import 'package:pawfectmatch/models/models.dart';

class DogMatch extends Equatable{
  final int id;
  final String dogId;
  final Dog matchedDog;
  //final List<Chat>? chat;

  DogMatch({
    required this.id, 
    required this.dogId, 
    required this.matchedDog,
    //required this.chat,
    });
  
  @override
  List<Object?> get props => [id, dogId, matchedDog];



}