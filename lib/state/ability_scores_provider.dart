import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/ability_scores.dart';

part 'ability_scores_provider.g.dart';

@riverpod
class AbilityScoresNotifier extends _$AbilityScoresNotifier {
  @override
  AbilityScores build() {
    return AbilityScores();
  }

  void increase(Ability ability) {
    state = state.increase(ability);
  }

  void decrease(Ability ability) {
    state = state.decrease(ability);
  }

  void reset() {
    state = AbilityScores();
  }
}