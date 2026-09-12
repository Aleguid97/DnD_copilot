import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/hit_points.dart';

part 'hit_points_provider.g.dart';

@riverpod
class HitPointsNotifier extends _$HitPointsNotifier {
  final Random _random = Random();

  @override
  HitPointsState build() => const HitPointsState();

  void rollForLevel(int level, int hitDie) {
    final result = 1 + _random.nextInt(hitDie);
    final updated = Map<int, int>.from(state.rolls);
    updated[level] = result;
    state = state.copyWith(rolls: updated);
  }

  void loadRolls(Map<int, int> rolls) {
    state = HitPointsState(rolls: rolls);
  }

  void reset() {
    state = const HitPointsState();
  }
}
