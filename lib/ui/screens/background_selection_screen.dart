import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/backgrounds_data.dart';
import '../../models/ability_scores.dart';
import '../../models/background_ability_choice.dart';
import '../../state/background_selection_provider.dart';
import '../widgets/choice_tree.dart';
import 'ability_scores_screen.dart';

class BackgroundSelectionScreen extends ConsumerWidget {
  const BackgroundSelectionScreen({super.key});

  String _abilityLabel(Ability a) {
    switch (a) {
      case Ability.strength:
        return 'Forza';
      case Ability.dexterity:
        return 'Destrezza';
      case Ability.constitution:
        return 'Costituzione';
      case Ability.intelligence:
        return 'Intelligenza';
      case Ability.wisdom:
        return 'Saggezza';
      case Ability.charisma:
        return 'Carisma';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(backgroundSelectionNotifierProvider);
    final notifier = ref.read(backgroundSelectionNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Scegli il tuo background')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...allBackgrounds.map((bg) {
                  final isSelected = state.selectedBackground?.id == bg.id;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        child: ListTile(
                          title: Text(bg.name),
                          subtitle: Text(bg.description),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle)
                              : null,
                          onTap: () => notifier.selectBackground(bg),
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
                                'Talento Origine: ${bg.originFeatName}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Text(bg.originFeatDescription),
                              const SizedBox(height: 6),
                              Text(
                                'Competenze: ${bg.skillProficiencies.join(', ')}',
                              ),
                              Text('Strumenti: ${bg.toolProficiency}'),
                            ],
                          ),
                        ),
                        ChoiceTree(
                          choices: state.activeChoices,
                          selections: state.selections,
                          onOptionToggle: (choice, id) => choice.isSingleSelect
                              ? notifier.selectSingle(choice, id)
                              : notifier.toggleMulti(choice, id),
                          indent: 16,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Distribuisci i bonus di caratteristica',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              RadioListTile<AllocationMode>(
                                title: const Text('+1 a tutte e tre'),
                                value: AllocationMode.onePlusOnePlusOne,
                                groupValue: state.abilityChoice.mode,
                                onChanged: (mode) => notifier.setMode(mode!),
                              ),
                              RadioListTile<AllocationMode>(
                                title: const Text('+2 a una, +1 a un\'altra'),
                                value: AllocationMode.twoPlusOne,
                                groupValue: state.abilityChoice.mode,
                                onChanged: (mode) => notifier.setMode(mode!),
                              ),
                              if (state.abilityChoice.mode ==
                                  AllocationMode.twoPlusOne) ...[
                                Text(
                                  'Chi riceve +2:',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Wrap(
                                  spacing: 8,
                                  children: bg.abilityScoreOptions.map((a) {
                                    return ChoiceChip(
                                      label: Text(_abilityLabel(a)),
                                      selected:
                                          state.abilityChoice.plusTwo == a,
                                      onSelected: (_) => notifier.setPlusTwo(a),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Chi riceve +1:',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Wrap(
                                  spacing: 8,
                                  children: bg.abilityScoreOptions
                                      .where(
                                        (a) => a != state.abilityChoice.plusTwo,
                                      )
                                      .map((a) {
                                        return ChoiceChip(
                                          label: Text(_abilityLabel(a)),
                                          selected:
                                              state.abilityChoice.plusOne == a,
                                          onSelected: (_) =>
                                              notifier.setPlusOne(a),
                                        );
                                      })
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
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
                        builder: (_) => const AbilityScoresScreen(),
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
