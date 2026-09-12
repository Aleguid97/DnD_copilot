import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/backgrounds_data.dart';
import '../../data/classes_data.dart';
import '../../data/database.dart';
import '../../models/ability_score_improvement.dart';
import '../../models/ability_scores.dart';
import '../../models/background_ability_choice.dart';
import '../../models/character_class.dart';
import '../../models/character_save_data.dart';
import '../../models/choice.dart';
import '../../state/class_selection_provider.dart';
import '../../state/database_provider.dart';
import '../../state/hit_points_provider.dart';
import '../widgets/asi_editor.dart';
import '../widgets/choice_tree.dart';

class LevelUpScreen extends ConsumerStatefulWidget {
  final SavedCharacter savedCharacter;
  final int pendingLevel;

  const LevelUpScreen({
    super.key,
    required this.savedCharacter,
    required this.pendingLevel,
  });

  @override
  ConsumerState<LevelUpScreen> createState() => _LevelUpScreenState();
}

class _LevelUpScreenState extends ConsumerState<LevelUpScreen> {
  late CharacterSaveData saveData;
  late int levelBeingConfirmed;

  @override
  void initState() {
    super.initState();
    saveData = CharacterSaveData.fromJson(widget.savedCharacter.dataJson);
    levelBeingConfirmed = saveData.level + 1;
    WidgetsBinding.instance.addPostFrameCallback((_) => _seedProviders());
  }

  CharacterClass _findClass(String id) =>
      allClasses.firstWhere((c) => c.id == id);

  void _seedProviders() {
    final charClass = _findClass(saveData.classId);
    ref
        .read(classSelectionNotifierProvider.notifier)
        .loadForLevelUp(
          charClass: charClass,
          targetLevel: levelBeingConfirmed,
          existingSelections: selectionsFromSerializable(
            saveData.classSelections,
          ),
          existingAsiChoices: saveData.asiChoices
              .map(asiChoiceFromMap)
              .toList(),
        );
    ref
        .read(hitPointsNotifierProvider.notifier)
        .loadRolls(
          saveData.hitPointRolls.map((k, v) => MapEntry(int.parse(k), v)),
        );
  }

  Map<Ability, int> _backgroundBonuses() {
    final background = allBackgrounds.firstWhere(
      (b) => b.id == saveData.backgroundId,
    );
    final bgChoice = BackgroundAbilityChoice(
      mode: AllocationMode.values.byName(saveData.abilityAllocationMode),
      plusTwo: saveData.abilityPlusTwo != null
          ? Ability.values.byName(saveData.abilityPlusTwo!)
          : null,
      plusOne: saveData.abilityPlusOne != null
          ? Ability.values.byName(saveData.abilityPlusOne!)
          : null,
    );
    return bgChoice.toBonusMap(background.abilityScoreOptions);
  }

  Future<void> _confirmLevel() async {
    final classState = ref.read(classSelectionNotifierProvider);
    final hp = ref.read(hitPointsNotifierProvider);

    final updatedSaveData = CharacterSaveData(
      name: saveData.name,
      age: saveData.age,
      height: saveData.height,
      weight: saveData.weight,
      imagePath: saveData.imagePath,
      raceId: saveData.raceId,
      raceSelections: saveData.raceSelections,
      classId: saveData.classId,
      level: levelBeingConfirmed,
      classSelections: selectionsToSerializable(classState.selections),
      asiChoices: classState.asiChoices.map(asiChoiceToMap).toList(),
      backgroundId: saveData.backgroundId,
      backgroundSelections: saveData.backgroundSelections,
      abilityAllocationMode: saveData.abilityAllocationMode,
      abilityPlusTwo: saveData.abilityPlusTwo,
      abilityPlusOne: saveData.abilityPlusOne,
      abilityBaseScores: saveData.abilityBaseScores,
      hitPointRolls: hp.rolls.map((k, v) => MapEntry(k.toString(), v)),
    );

    final db = ref.read(appDatabaseProvider);
    await db.updateCharacterData(
      widget.savedCharacter.id,
      level: levelBeingConfirmed,
      dataJson: updatedSaveData.toJson(),
    );

    saveData = updatedSaveData;

    if (levelBeingConfirmed < widget.pendingLevel) {
      setState(() => levelBeingConfirmed += 1);
      _seedProviders();
    } else {
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final classState = ref.watch(classSelectionNotifierProvider);
    final classNotifier = ref.read(classSelectionNotifierProvider.notifier);
    final hp = ref.watch(hitPointsNotifierProvider);
    final hpNotifier = ref.read(hitPointsNotifierProvider.notifier);

    if (classState.selectedClass == null) {
      return const Dialog(
        child: SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final charClass = classState.selectedClass!;

    final allClassChoices = charClass.levelFeatures
        .expand((f) => f.choices)
        .toList();
    final selectedSubclassOptions = <ChoiceOption>[];
    for (final choice in allClassChoices) {
      final selectedIds = classState.selections[choice.id] ?? const {};
      for (final option in choice.options) {
        if (selectedIds.contains(option.id))
          selectedSubclassOptions.add(option);
      }
    }

    final levelTraits = <String>[
      ...charClass.featureAt(levelBeingConfirmed).fixedTraits,
      for (final option in selectedSubclassOptions)
        ...?option.levelFeatures[levelBeingConfirmed]?.fixedTraits,
    ];

    final newChoicesThisLevel = <Choice>[
      ...charClass.featureAt(levelBeingConfirmed).choices,
      for (final option in selectedSubclassOptions)
        ...?option.levelFeatures[levelBeingConfirmed]?.choices,
    ];

    final bgBonuses = _backgroundBonuses();
    final baseScores = saveData.abilityBaseScores.map(
      (k, v) => MapEntry(Ability.values.byName(k), v),
    );
    final totalBonuses = mergeAbilityBonusMaps([
      bgBonuses,
      classState.asiBonuses,
    ]);
    final baseCon = baseScores[Ability.constitution] ?? 10;
    final totalCon = baseCon + (totalBonuses[Ability.constitution] ?? 0);
    final conModifier = ((totalCon - 10) / 2).floor();

    final needsHpRoll =
        levelBeingConfirmed >= 2 && hp.rolls[levelBeingConfirmed] == null;
    final canConfirm = classState.isComplete && !needsHpRoll;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_circle_up,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Level Up — Level $levelBeingConfirmed',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (levelTraits.isNotEmpty) ...[
                      Text(
                        'New traits',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      ...levelTraits.map((t) => Text('• $t')),
                      const SizedBox(height: 16),
                    ],
                    if (newChoicesThisLevel.isNotEmpty)
                      ChoiceTree(
                        choices: newChoicesThisLevel,
                        selections: classState.selections,
                        onOptionToggle: (choice, id) => choice.isSingleSelect
                            ? classNotifier.selectSingle(choice, id)
                            : classNotifier.toggleMulti(choice, id),
                        indent: 0,
                      ),
                    if (charClass
                        .featureAt(levelBeingConfirmed)
                        .grantsAbilityScoreImprovement)
                      Builder(
                        builder: (context) {
                          final index = classState.asiChoices.length - 1;
                          if (index < 0) return const SizedBox.shrink();
                          return AsiEditor(
                            index: index,
                            asi: classState.asiChoices[index],
                            currentTotals: asiCurrentTotals(
                              baseScores: baseScores,
                              backgroundBonuses: bgBonuses,
                              asiChoices: classState.asiChoices,
                              excludingIndex: index,
                            ),
                            onModeChanged: classNotifier.setAsiMode,
                            onPlusTwoChanged: classNotifier.setAsiPlusTwo,
                            onFirstPlusOneChanged:
                                classNotifier.setAsiFirstPlusOne,
                            onSecondPlusOneChanged:
                                classNotifier.setAsiSecondPlusOne,
                          );
                        },
                      ),
                    if (levelBeingConfirmed >= 2) ...[
                      const SizedBox(height: 16),
                      Card(
                        child: ListTile(
                          title: Text(
                            'Roll Hit Points for level $levelBeingConfirmed',
                          ),
                          subtitle: hp.rolls[levelBeingConfirmed] != null
                              ? Text(
                                  'Rolled: ${hp.rolls[levelBeingConfirmed]} + CON mod ($conModifier) = '
                                  '${(hp.rolls[levelBeingConfirmed]! + conModifier) < 1 ? 1 : hp.rolls[levelBeingConfirmed]! + conModifier}',
                                )
                              : const Text('Not rolled yet'),
                          trailing: ElevatedButton(
                            onPressed: () => hpNotifier.rollForLevel(
                              levelBeingConfirmed,
                              charClass.hitDie,
                            ),
                            child: Text(
                              hp.rolls[levelBeingConfirmed] == null
                                  ? 'Roll'
                                  : 'Reroll',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canConfirm ? _confirmLevel : null,
                  child: Text(
                    levelBeingConfirmed < widget.pendingLevel
                        ? 'Confirm & Continue'
                        : 'Confirm',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
