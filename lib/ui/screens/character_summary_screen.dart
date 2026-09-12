import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'dart:io';
import '../../data/xp_table.dart';
import '../../data/database.dart';
import '../../models/ability_score_improvement.dart';
import '../../models/ability_scores.dart';
import '../../models/character.dart';
import '../../models/character_save_data.dart';
import '../../models/choice.dart';
import '../../state/ability_scores_provider.dart';
import '../../state/background_selection_provider.dart';
import '../../state/character_basics_provider.dart';
import '../../state/class_selection_provider.dart';
import '../../state/database_provider.dart';
import '../../state/hit_points_provider.dart';
import '../../state/race_selection_provider.dart';
import '../../data/packs_data.dart';

class CharacterSummaryScreen extends ConsumerWidget {
  const CharacterSummaryScreen({super.key});

  String _abilityLabel(Ability a) {
    switch (a) {
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

  List<String> _selectedLabels(
    List<Choice> choices,
    Map<String, Set<String>> selections,
  ) {
    final result = <String>[];
    for (final choice in choices) {
      final selectedIds = selections[choice.id] ?? {};
      final labels = choice.options
          .where((o) => selectedIds.contains(o.id))
          .map((o) => o.label);
      if (labels.isNotEmpty) {
        result.add('${choice.title}: ${labels.join(', ')}');
      }
    }
    return result;
  }

  String _describeAsi(AsiChoice asi) {
    if (asi.mode == AsiAllocationMode.twoInOne) {
      return asi.plusTwo != null
          ? '+2 ${_abilityLabel(asi.plusTwo!)}'
          : 'Not set';
    }
    final first = asi.firstPlusOne != null
        ? _abilityLabel(asi.firstPlusOne!)
        : '?';
    final second = asi.secondPlusOne != null
        ? _abilityLabel(asi.secondPlusOne!)
        : '?';
    return '+1 $first, +1 $second';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final basics = ref.watch(characterBasicsNotifierProvider);
    final raceState = ref.watch(raceSelectionNotifierProvider);
    final classState = ref.watch(classSelectionNotifierProvider);
    final bgState = ref.watch(backgroundSelectionNotifierProvider);
    final scores = ref.watch(abilityScoresNotifierProvider);
    final hp = ref.watch(hitPointsNotifierProvider);

    if (raceState.selectedRace == null ||
        classState.selectedClass == null ||
        bgState.selectedBackground == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Character Sheet')),
        body: const Center(
          child: Text(
            'Something is missing — please complete all previous steps.',
          ),
        ),
      );
    }

    Future<void> save() async {
      final db = ref.read(appDatabaseProvider);

      final saveData = CharacterSaveData(
        name: basics.name,
        age: basics.age,
        height: basics.height,
        weight: basics.weight,
        imagePath: basics.imagePath,
        raceId: raceState.selectedRace!.id,
        raceSelections: selectionsToSerializable(raceState.selections),
        classId: classState.selectedClass!.id,
        level: classState.targetLevel,
        classSelections: selectionsToSerializable(classState.selections),
        asiChoices: classState.asiChoices.map(asiChoiceToMap).toList(),
        backgroundId: bgState.selectedBackground!.id,
        backgroundSelections: selectionsToSerializable(bgState.selections),
        abilityAllocationMode: bgState.abilityChoice.mode.name,
        abilityPlusTwo: bgState.abilityChoice.plusTwo?.name,
        abilityPlusOne: bgState.abilityChoice.plusOne?.name,
        abilityBaseScores: scores.baseScores.map((k, v) => MapEntry(k.name, v)),
        hitPointRolls: hp.rolls.map((k, v) => MapEntry(k.toString(), v)),
      );

      final newId = await db.insertCharacter(
        SavedCharactersCompanion.insert(
          name: basics.name,
          raceId: raceState.selectedRace!.id,
          classId: classState.selectedClass!.id,
          level: classState.targetLevel,
          backgroundId: bgState.selectedBackground!.id,
          dataJson: saveData.toJson(),
          imagePath: Value(basics.imagePath),
        ),
      );

      final equipOptionId = classState.startingEquipmentOptionId;
      if (equipOptionId != null) {
        final option = classState.selectedClass!.startingEquipmentOptions
            .firstWhere((o) => o.id == equipOptionId);
        for (final grant in option.items) {
          final packItems = packContents[grant.itemId];
          if (packItems != null) {
            // This grant refers to a Pack — expand it into its individual contents.
            for (final packGrant in packItems) {
              await db.addInventoryItem(
                newId,
                packGrant.itemId,
                quantity: packGrant.quantity * grant.quantity,
              );
            }
          } else {
            await db.addInventoryItem(
              newId,
              grant.itemId,
              quantity: grant.quantity,
            );
          }
        }
        await db.setGold(newId, option.goldPieces * 100);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Character saved!')));
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }

    final character = Character(
      basics: basics,
      race: raceState.selectedRace!,
      raceSelections: raceState.selections,
      characterClass: classState.selectedClass!,
      level: classState.targetLevel,
      classSelections: classState.selections,
      asiChoices: classState.asiChoices,
      background: bgState.selectedBackground!,
      backgroundAbilityChoice: bgState.abilityChoice,
      backgroundSelections: bgState.selections,
      abilityScores: scores,
      hitPoints: hp,
    );

    final totalBonuses = character.totalAbilityBonuses;
    final proficiencyBonus = proficiencyBonusForLevel(character.level);

    final skillChoice = Choice(
      id: '${character.characterClass.id}_skills',
      title: 'Skills',
      minSelections: character.characterClass.skillChoiceCount,
      maxSelections: character.characterClass.skillChoiceCount,
      options: character.characterClass.skillOptions
          .map((s) => ChoiceOption(id: s, label: s))
          .toList(),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Character Sheet')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: basics.imagePath != null
                      ? FileImage(File(basics.imagePath!))
                      : null,
                  child: basics.imagePath == null
                      ? const Icon(Icons.person, size: 48)
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  basics.name.isEmpty ? '(Unnamed)' : basics.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  '${character.race.name} ${character.characterClass.name} — Level ${character.level}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionCard(
            title: 'Basics',
            children: [
              if (basics.age != null) Text('Age: ${basics.age}'),
              if (basics.height != null && basics.height!.isNotEmpty)
                Text('Height: ${basics.height}'),
              if (basics.weight != null && basics.weight!.isNotEmpty)
                Text('Weight: ${basics.weight}'),
            ],
          ),
          _SectionCard(
            title: 'Combat Stats',
            children: [
              Text('Hit Points: ${character.totalHitPoints}'),
              Text('Proficiency Bonus: +$proficiencyBonus'),
              Text('Speed: ${character.race.speed} ft'),
            ],
          ),
          _SectionCard(
            title: 'Ability Scores',
            children: Ability.values.map((a) {
              final base = character.abilityScores.baseScores[a]!;
              final bonus = totalBonuses[a] ?? 0;
              final total = base + bonus;
              final modifier = character.abilityScores.modifierFor(
                a,
                bonuses: totalBonuses,
              );
              final modifierText = modifier >= 0 ? '+$modifier' : '$modifier';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('${_abilityLabel(a)}: $total ($modifierText)'),
              );
            }).toList(),
          ),
          _SectionCard(
            title: 'Species: ${character.race.name}',
            children: [
              ...character.race.fixedTraits.map((t) => Text('• $t')),
              ..._selectedLabels(
                raceState.activeChoices,
                character.raceSelections,
              ).map((s) => Text('• $s')),
            ],
          ),
          _SectionCard(
            title:
                'Class: ${character.characterClass.name} (Level ${character.level})',
            children: [
              ..._selectedLabels([
                skillChoice,
              ], character.classSelections).map((s) => Text('• $s')),
              ..._selectedLabels(
                classState.activeChoices,
                character.classSelections,
              ).map((s) => Text('• $s')),
              for (var i = 0; i < character.asiChoices.length; i++)
                Text(
                  '• Ability Score Improvement #${i + 1}: ${_describeAsi(character.asiChoices[i])}',
                ),
            ],
          ),
          _SectionCard(
            title: 'Background: ${character.background.name}',
            children: [
              Text('Origin Feat: ${character.background.originFeatName}'),
              Text(character.background.originFeatDescription),
              Text(
                'Skills: ${character.background.skillProficiencies.join(', ')}',
              ),
              Text('Tool: ${character.background.toolProficiency}'),
              ..._selectedLabels(
                bgState.activeChoices,
                character.backgroundSelections,
              ).map((s) => Text('• $s')),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: save,
            icon: const Icon(Icons.save),
            label: const Text('Save Character'),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            ...children,
          ],
        ),
      ),
    );
  }
}
