import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pawfectmatch/blocs/swipe/swipe_bloc.dart';
import 'package:pawfectmatch/firebase_service.dart';
import 'package:pawfectmatch/models/dog_model.dart';
import 'package:pawfectmatch/repositories/database_repository.dart';

import 'package:pawfectmatch/widgets/widgets.dart';


class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SwipeBloc>()..add(LoadDogs());
    
  }


  DatabaseRepository databaseRepository = DatabaseRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Color(0xffF1F6F8),
      body: BlocBuilder<SwipeBloc, SwipeState>(
        builder: (context, state) {
          if(state is SwipeLoaded) {
            var dogCount = state.dogs.length;
            return Column(
              children: [
              InkWell(
                onDoubleTap: () {
                  Navigator.pushNamed(context, '/dogs', 
                  arguments: state.dogs[0]);
                },
                child: Draggable<Dog>(
                            data: state.dogs[0],
                            child: DogCard(dog: state.dogs[0]),
                            feedback: DogCard(dog: state.dogs[0]),
                            childWhenDragging: (dogCount > 1)
                            ? DogCard(dog: state.dogs[1])
                            : Container(),
                            onDragEnd: (drag) {
                if (drag.offset.dx < 0) {
                  context.read<SwipeBloc>()..add(SwipeLeft(dogs: state.dogs[0]));
                  print('Swiped left');
                } else {
                  context.read<SwipeBloc>()..add(SwipeRight(dogs: state.dogs[0], context: context));
                  print('Swiped right');
                }
                            },
                            ),
              ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal:70 ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    context.read<SwipeBloc>()..add(SwipeLeft(dogs: state.dogs[0]));
                    print('Swiped left');
                  },
                  child: ChoiceButton(
                    width: 70, 
                    height: 70, 
                    size: 30, 
                    color: Colors.redAccent, 
                    icon: Icons.clear_rounded,
                    ),
                ),
                InkWell(
                  onTap: () {
                    context.read<SwipeBloc>()..add(SwipeRight(dogs: state.dogs[0], context: context));
                    print('Swiped right');
                  },
                  child: ChoiceButton(
                  width: 70, 
                  height: 70, 
                  size: 30, 
                  color: Colors.greenAccent, 
                  icon: Icons.favorite,
                  ),
                ),
              ],
            ),
          ),
            ],
            );
          }
          else if(state is SwipeLoading){
            return Center(child: CircularProgressIndicator(),
            );
          }
          if (state is SwipeError) {
            return Center(
              child: Text('Oh no, come back for more soon.',
                  style: Theme.of(context).textTheme.headlineSmall),
            );
          } else {
            return Text('Something went wrong.');
          }
        },
      ),
    );
  }
}

