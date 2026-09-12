import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/classes_data.dart';
import '../../models/ability_score_improvement.dart';
import '../../models/choice.dart';
import '../../state/ability_scores_provider.dart';
import '../../state/background_selection_provider.dart';
import '../../state/class_selection_provider.dart';
import '../widgets/asi_editor.dart';
import '../widgets/choice_card.dart';
import '../widgets/choice_tree.dart';
import 'background_selection_screen.dart';

class ClassSelectionScreen extends ConsumerWidget {
  const ClassSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(classSelectionNotifierProvider);
    final notifier = ref.read(classSelectionNotifierProvider.notifier);
    final baseScores = ref.watch(abilityScoresNotifierProvider).baseScores;
    final bgBonuses = ref.watch(
      backgroundSelectionNotifierProvider.select((s) => s.abilityBonuses),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Choose your Class')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...allClasses.map((charClass) {
                  final isSelected = state.selectedClass?.id == charClass.id;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        child: ListTile(
                          title: Text(charClass.name),
                          subtitle: Text('Hit Die: d${charClass.hitDie}'),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle)
                              : null,
                          onTap: () => notifier.selectClass(charClass),
                        ),
                      ),
                      if (isSelected) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            top: 4,
                            bottom: 4,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Character Level: ',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: state.targetLevel > 1
                                    ? () => notifier.setTargetLevel(
                                        state.targetLevel - 1,
                                      )
                                    : null,
                              ),
                              Text(
                                '${state.targetLevel}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed:
                                    state.targetLevel < state.maxSelectableLevel
                                    ? () => notifier.setTargetLevel(
                                        state.targetLevel + 1,
                                      )
                                    : null,
                              ),
                              if (state.maxSelectableLevel == 1)
                                Expanded(
                                  child: Text(
                                    '  (level customization not yet available for this class)',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            top: 4,
                            bottom: 4,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Traits',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              ...state.cumulativeFixedTraits.map(
                                (t) => Text('• $t'),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: Builder(
                            builder: (context) {
                              final skillChoice = Choice(
                                id: '${charClass.id}_skills',
                                title:
                                    'Choose ${charClass.skillChoiceCount} skills',
                                minSelections: charClass.skillChoiceCount,
                                maxSelections: charClass.skillChoiceCount,
                                options: charClass.skillOptions
                                    .map((s) => ChoiceOption(id: s, label: s))
                                    .toList(),
                              );
                              final selected =
                                  state.selections[skillChoice.id] ?? const {};
                              return ChoiceCard(
                                choice: skillChoice,
                                selectedOptionIds: selected,
                                onOptionToggle: notifier.toggleMulti,
                              );
                            },
                          ),
                        ),

                        ChoiceTree(
                          choices: state.topLevelActiveChoices,
                          selections: state.selections,
                          onOptionToggle: (choice, id) => choice.isSingleSelect
                              ? notifier.selectSingle(choice, id)
                              : notifier.toggleMulti(choice, id),
                          indent: 16,
                        ),
                        ...List.generate(state.asiChoices.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 16, top: 12),
                            child: AsiEditor(
                              index: index,
                              asi: state.asiChoices[index],
                              currentTotals: asiCurrentTotals(
                                baseScores: baseScores,
                                backgroundBonuses: bgBonuses,
                                asiChoices: state.asiChoices,
                                excludingIndex: index,
                              ),
                              onModeChanged: notifier.setAsiMode,
                              onPlusTwoChanged: notifier.setAsiPlusTwo,
                              onFirstPlusOneChanged:
                                  notifier.setAsiFirstPlusOne,
                              onSecondPlusOneChanged:
                                  notifier.setAsiSecondPlusOne,
                            ),
                          );
                        }),
                        if (charClass.startingEquipmentOptions.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 16, top: 12),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Choose your Starting Equipment',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                    ...charClass.startingEquipmentOptions.map((
                                      option,
                                    ) {
                                      return RadioListTile<String>(
                                        title: Text(option.label),
                                        value: option.id,
                                        groupValue:
                                            state.startingEquipmentOptionId,
                                        onChanged: (id) => notifier
                                            .setStartingEquipmentOption(id!),
                                      );
                                    }),
                                  ],
                                ),
                              ),
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
                        builder: (_) => const BackgroundSelectionScreen(),
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
