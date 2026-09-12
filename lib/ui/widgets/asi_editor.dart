import 'package:flutter/material.dart';
import '../../models/ability_score_improvement.dart';
import '../../models/ability_scores.dart';

class AsiEditor extends StatelessWidget {
  final int index;
  final AsiChoice asi;
  final Map<Ability, int> currentTotals; // ability totals BEFORE this ASI
  final void Function(int index, AsiAllocationMode mode) onModeChanged;
  final void Function(int index, Ability ability) onPlusTwoChanged;
  final void Function(int index, Ability ability) onFirstPlusOneChanged;
  final void Function(int index, Ability ability) onSecondPlusOneChanged;

  const AsiEditor({
    super.key,
    required this.index,
    required this.asi,
    required this.currentTotals,
    required this.onModeChanged,
    required this.onPlusTwoChanged,
    required this.onFirstPlusOneChanged,
    required this.onSecondPlusOneChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ability Score Improvement #${index + 1}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            RadioListTile<AsiAllocationMode>(
              title: const Text('+2 to one ability'),
              value: AsiAllocationMode.twoInOne,
              groupValue: asi.mode,
              onChanged: (mode) => onModeChanged(index, mode!),
            ),
            RadioListTile<AsiAllocationMode>(
              title: const Text('+1 to two abilities'),
              value: AsiAllocationMode.onePlusOne,
              groupValue: asi.mode,
              onChanged: (mode) => onModeChanged(index, mode!),
            ),
            if (asi.mode == AsiAllocationMode.twoInOne)
              Wrap(
                spacing: 8,
                children: Ability.values.map((a) {
                  final wouldExceed = (currentTotals[a] ?? 10) + 2 > 20;
                  return ChoiceChip(
                    label: Text('${a.name} (${currentTotals[a]})'),
                    selected: asi.plusTwo == a,
                    onSelected: wouldExceed
                        ? null
                        : (_) => onPlusTwoChanged(index, a),
                  );
                }).toList(),
              )
            else ...[
              Text('First +1:', style: Theme.of(context).textTheme.bodySmall),
              Wrap(
                spacing: 8,
                children: Ability.values.map((a) {
                  final wouldExceed = (currentTotals[a] ?? 10) + 1 > 20;
                  return ChoiceChip(
                    label: Text('${a.name} (${currentTotals[a]})'),
                    selected: asi.firstPlusOne == a,
                    onSelected: wouldExceed
                        ? null
                        : (_) => onFirstPlusOneChanged(index, a),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text('Second +1:', style: Theme.of(context).textTheme.bodySmall),
              Wrap(
                spacing: 8,
                children: Ability.values
                    .where((a) => a != asi.firstPlusOne)
                    .map((a) {
                      final wouldExceed = (currentTotals[a] ?? 10) + 1 > 20;
                      return ChoiceChip(
                        label: Text('${a.name} (${currentTotals[a]})'),
                        selected: asi.secondPlusOne == a,
                        onSelected: wouldExceed
                            ? null
                            : (_) => onSecondPlusOneChanged(index, a),
                      );
                    })
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
