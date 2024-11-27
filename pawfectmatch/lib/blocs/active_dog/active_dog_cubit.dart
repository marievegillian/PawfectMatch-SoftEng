import 'package:bloc/bloc.dart';

class ActiveDogCubit extends Cubit<String> {
  ActiveDogCubit() : super(''); // Initial active dog ID

  void setActiveDog(String dogId) {
    emit(dogId);
  }
}
