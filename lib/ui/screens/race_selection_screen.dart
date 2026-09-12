import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/races_data.dart';
import '../../state/race_selection_provider.dart';
import '../widgets/choice_tree.dart';
import 'class_selection_screen.dart';

class RaceSelectionScreen extends ConsumerWidget {
  const RaceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(raceSelectionNotifierProvider);
    final notifier = ref.read(raceSelectionNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Scegli la tua specie')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...allRaces.map((race) {
                  final isSelected = state.selectedRace?.id == race.id;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        child: ListTile(
                          title: Text(race.name),
                          subtitle: Text(race.description),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle)
                              : null,
                          onTap: () => notifier.selectRace(race),
                        ),
                      ),
                      if (isSelected) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            top: 8,
                            bottom: 4,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tratti',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              ...race.fixedTraits.map((t) => Text('• $t')),
                            ],
                          ),
                        ),
                        ChoiceTree(
                          choices: race.choices,
                          selections: state.selections,
                          onOptionToggle: (choice, id) => choice.isSingleSelect
                              ? notifier.selectSingle(choice, id)
                              : notifier.toggleMulti(choice, id),
                          indent: 16,
                        ),
                      ],
                      const SizedBox(height: 8),
                    ],
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: state.isComplete
                  ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ClassSelectionScreen(),
                      ),
                    )
                  : null,
              child: const Text('Continua'),
            ),
          ),
        ],
      ),
    );
  }
}
