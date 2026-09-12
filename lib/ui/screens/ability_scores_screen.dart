import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ability_scores.dart';
import '../../state/ability_scores_provider.dart';
import '../../state/background_selection_provider.dart';
import '../../state/class_selection_provider.dart';
import '../../models/ability_score_improvement.dart';
import 'hit_points_screen.dart';

class AbilityScoresScreen extends ConsumerWidget {
  const AbilityScoresScreen({super.key});

  String _labelFor(Ability ability) {
    switch (ability) {
      case Ability.strength:
        return 'Strength';
      case Ability.dexterity:
        return 'Dexterity';
      case Ability.constitution:
        return 'Constitution';
      case Ability.intelligence:
        return 'Intelligence';
      case Ability.wisdom:
        return 'Wisdom';
      case Ability.charisma:
        return 'Charisma';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scores = ref.watch(abilityScoresNotifierProvider);
    final notifier = ref.read(abilityScoresNotifierProvider.notifier);
    final bonuses = ref.watch(
      backgroundSelectionNotifierProvider.select((s) => s.abilityBonuses),
    );
    final asiBonuses = ref.watch(
      classSelectionNotifierProvider.select((s) => s.asiBonuses),
    );
    final combinedBonuses = mergeAbilityBonusMaps([bonuses, asiBonuses]);

    return Scaffold(
      appBar: AppBar(title: const Text('Assign Ability Scores')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Points remaining: ${scores.pointsRemaining} / $pointBuyBudget',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: Ability.values.map((ability) {
                final base = scores.baseScores[ability]!;
                final backgroundBonus = bonuses[ability] ?? 0;
                final classBonus = asiBonuses[ability] ?? 0;
                final bonus = backgroundBonus + classBonus;
                final total = base + bonus;
                final modifier = scores.modifierFor(
                  ability,
                  bonuses: combinedBonuses,
                );
                final modifierText = modifier >= 0 ? '+$modifier' : '$modifier';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _labelFor(ability),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              if (bonus > 0)
                                Text(
                                  backgroundBonus > 0 && classBonus > 0
                                      ? 'includes +$backgroundBonus from background and +$classBonus from class progression'
                                      : backgroundBonus > 0
                                      ? 'includes +$backgroundBonus from background'
                                      : 'includes +$classBonus from class progression',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: scores.canDecrease(ability)
                              ? () => notifier.decrease(ability)
                              : null,
                        ),
                        SizedBox(
                          width: 36,
                          child: Text(
                            '$total',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: scores.canIncrease(ability)
                              ? () => notifier.increase(ability)
                              : null,
                        ),
                        SizedBox(
                          width: 56,
                          child: Text(
                            '($modifierText)',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: scores.isComplete
                  ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HitPointsScreen(),
                      ),
                    )
                  : null,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
