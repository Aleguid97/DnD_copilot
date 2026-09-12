import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/character_basics.dart';

part 'character_basics_provider.g.dart';

@riverpod
class CharacterBasicsNotifier extends _$CharacterBasicsNotifier {
  @override
  CharacterBasics build() => const CharacterBasics();

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setAge(int? age) {
    state = state.copyWith(age: age);
  }

  void setHeight(String height) {
    state = state.copyWith(height: height);
  }

  void setWeight(String weight) {
    state = state.copyWith(weight: weight);
  }

  void setImagePath(String? path) {
    state = state.copyWith(imagePath: path);
  }
}
