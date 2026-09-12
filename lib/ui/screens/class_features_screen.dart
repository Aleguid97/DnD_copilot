import 'package:flutter/material.dart';
import '../../models/ability_score_improvement.dart';
import '../../models/character_class.dart';
import '../widgets/character_sheet_body.dart' show describeAsi;

class ClassFeaturesScreen extends StatelessWidget {
  final CharacterClass characterClass;
  final int level;
  final Map<String, Set<String>> classSelections;
  final List<AsiChoice> asiChoices;

  const ClassFeaturesScreen({
    super.key,
    required this.characterClass,
    required this.level,
    required this.classSelections,
    required this.asiChoices,
  });

  @override
  Widget build(BuildContext context) {
    final levelEntries = <int, List<String>>{};

    void addTrait(int lvl, String text) {
      levelEntries.putIfAbsent(lvl, () => []).add(text);
    }

    for (final feature in characterClass.levelFeatures) {
      if (feature.level > level) continue;
      for (final t in feature.fixedTraits) {
        addTrait(feature.level, t);
      }
      for (final choice in feature.choices) {
        final selectedIds = classSelections[choice.id] ?? const {};
        final labels = choice.options
            .where((o) => selectedIds.contains(o.id))
            .map((o) => o.label);
        if (labels.isNotEmpty) {
          addTrait(feature.level, '${choice.title}: ${labels.join(', ')}');
        }
      }
    }

    final allClassChoices = characterClass.levelFeatures
        .expand((f) => f.choices)
        .toList();
    for (final choice in allClassChoices) {
      final selectedIds = classSelections[choice.id] ?? const {};
      for (final option in choice.options) {
        if (!selectedIds.contains(option.id)) continue;
        option.levelFeatures.forEach((lvl, feature) {
          if (lvl > level) return;
          for (final t in feature.fixedTraits) {
            addTrait(lvl, t);
          }
          for (final subChoice in feature.choices) {
            final subSelectedIds = classSelections[subChoice.id] ?? const {};
            final labels = subChoice.options
                .where((o) => subSelectedIds.contains(o.id))
                .map((o) => o.label);
            if (labels.isNotEmpty) {
              addTrait(lvl, '${subChoice.title}: ${labels.join(', ')}');
            }
          }
        });
      }
    }

    final sortedLevels = levelEntries.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: Text('${characterClass.name} — Full Features')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (asiChoices.isNotEmpty) ...[
            Text(
              'Ability Score Improvements',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            for (var i = 0; i < asiChoices.length; i++)
              Text('• #${i + 1}: ${describeAsi(asiChoices[i])}'),
            const SizedBox(height: 16),
          ],
          for (final lvl in sortedLevels) ...[
            Text('Level $lvl', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            ...levelEntries[lvl]!.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $t'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
