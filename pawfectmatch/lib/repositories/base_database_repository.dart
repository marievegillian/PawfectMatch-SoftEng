import 'package:pawfectmatch/models/dog_model.dart';

abstract class BaseDatabaseRepository {
  Stream<Dog> getDog(String dogId);
  Stream<List<Dog>> getDogs();
}
