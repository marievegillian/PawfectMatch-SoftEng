// swipe_state.dart
part of 'swipe_bloc.dart';

abstract class SwipeState extends Equatable {
  const SwipeState();

  @override
  List<Object> get props => [];
}

class SwipeLoading extends SwipeState {}

class SwipeLoaded extends SwipeState {
  final List<Dog> dogs;

  const SwipeLoaded({
    required this.dogs,
  });

  @override
  List<Object> get props => [dogs];
}

class SwipeError extends SwipeState {}