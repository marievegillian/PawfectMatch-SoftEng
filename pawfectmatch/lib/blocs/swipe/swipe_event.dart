part of 'swipe_bloc.dart';

abstract class SwipeEvent extends Equatable {
  const SwipeEvent();

  @override
  List<Object?> get props => [];

  
}

class LoadDogs extends SwipeEvent {
  LoadDogs();

  @override
  List<Object?> get props => [];
}

class UpdateHome extends SwipeEvent {
  final List<Dog>? dogs;

  UpdateHome({
    required this.dogs,
  });

  @override
  List<Object?> get props => [dogs];
}

class SwipeLeft extends SwipeEvent{
  final Dog dogs;

  const SwipeLeft({required this.dogs});

  @override
  List<Object> get props => [dogs];
}

class SwipeRight extends SwipeEvent{
  final Dog dogs;
  final BuildContext context; // Include BuildContext in the event

  SwipeRight({
    required this.dogs,
    required this.context,
  });


  @override
  List<Object> get props => [dogs];
}

