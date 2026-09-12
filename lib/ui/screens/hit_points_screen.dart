import 'package:dnd_prova/ui/screens/character_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ability_score_improvement.dart';
import '../../models/ability_scores.dart';
import '../../state/ability_scores_provider.dart';
import '../../state/background_selection_provider.dart';
import '../../state/class_selection_provider.dart';
import '../../state/hit_points_provider.dart';

class HitPointsScreen extends ConsumerWidget {
  const HitPointsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classState = ref.watch(classSelectionNotifierProvider);
    final hp = ref.watch(hitPointsNotifierProvider);
    final hpNotifier = ref.read(hitPointsNotifierProvider.notifier);
    final scores = ref.watch(abilityScoresNotifierProvider);
    final bgBonuses = ref.watch(
      backgroundSelectionNotifierProvider.select((s) => s.abilityBonuses),
    );
    final asiBonuses = classState.asiBonuses;
    final combinedBonuses = mergeAbilityBonusMaps([bgBonuses, asiBonuses]);
    final conModifier = scores.modifierFor(
      Ability.constitution,
      bonuses: combinedBonuses,
    );

    final charClass = classState.selectedClass;
    final targetLevel = classState.targetLevel;
    final hitDie = charClass?.hitDie ?? 8;

    return Scaffold(
      appBar: AppBar(title: const Text('Hit Points')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Level 1: max Hit Die (d$hitDie) + CON modifier ($conModifier) = ${hitDie + conModifier}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                if (targetLevel < 2)
                  const Text('No additional rolls needed at level 1.')
                else
                  ...List.generate(targetLevel - 1, (i) {
                    final level = i + 2;
                    final rolled = hp.rolls[level];
                    return Card(
                      child: ListTile(
                        title: Text('Level $level'),
                        subtitle: rolled != null
                            ? Text(
                                'Rolled: $rolled + CON mod ($conModifier) = ${rolled + conModifier < 1 ? 1 : rolled + conModifier}',
                              )
                            : const Text('Not rolled yet'),
                        trailing: ElevatedButton(
                          onPressed: () =>
                              hpNotifier.rollForLevel(level, hitDie),
                          child: Text(
                            rolled == null ? 'Roll d$hitDie' : 'Reroll',
                          ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 16),
                if (hp.isCompleteFor(targetLevel))
                  Text(
                    'Total Hit Points: ${hp.totalHitPoints(hitDie: hitDie, targetLevel: targetLevel, conModifier: conModifier)}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: hp.isCompleteFor(targetLevel)
                  ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CharacterSummaryScreen(),
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
