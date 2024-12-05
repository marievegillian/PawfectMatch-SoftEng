import 'package:get_it/get_it.dart';
import 'package:pawfectmatch/blocs/active_dog/active_dog_cubit.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<ActiveDogCubit>(() => ActiveDogCubit());
}
