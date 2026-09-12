import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../data/xp_table.dart';
import '../../models/ability_score_improvement.dart';
import '../../models/ability_scores.dart';
import '../../models/character.dart';
import '../../models/choice.dart';
import '../../models/character_proficiencies.dart';
import '../screens/skills_screen.dart';
import '../../models/character_spells.dart';
import '../screens/spell_list_screen.dart';
import '../screens/class_features_screen.dart';
import '../screens/inventory_screen.dart';
import '../../models/currency.dart';
import 'gold_section.dart';
import '../../data/racial_cantrip_swap_data.dart';
import '../../state/racial_cantrip_provider.dart';

String abilityLabel(Ability a) {
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

List<String> selectedLabels(
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

String describeAsi(AsiChoice asi) {
  if (asi.mode == AsiAllocationMode.twoInOne) {
    return asi.plusTwo != null ? '+2 ${abilityLabel(asi.plusTwo!)}' : 'Not set';
  }
  final first = asi.firstPlusOne != null
      ? abilityLabel(asi.firstPlusOne!)
      : '?';
  final second = asi.secondPlusOne != null
      ? abilityLabel(asi.secondPlusOne!)
      : '?';
  return '+1 $first, +1 $second';
}

class CharacterSheetBody extends ConsumerWidget {
  final Character character;
  final List<Choice> raceActiveChoices;
  final List<Choice> classActiveChoices;
  final List<Choice> backgroundActiveChoices;

  const CharacterSheetBody({
    super.key,
    required this.character,
    required this.raceActiveChoices,
    required this.classActiveChoices,
    required this.backgroundActiveChoices,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundImage: character.basics.imagePath != null
                    ? FileImage(File(character.basics.imagePath!))
                    : null,
                child: character.basics.imagePath == null
                    ? const Icon(Icons.person, size: 48)
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                character.basics.name.isEmpty
                    ? '(Unnamed)'
                    : character.basics.name,
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
        if (character.id != null) GoldSection(characterId: character.id!),
        _SectionCard(
          title: 'Basics',
          children: [
            if (character.basics.age != null)
              Text('Age: ${character.basics.age}'),
            if (character.basics.height != null &&
                character.basics.height!.isNotEmpty)
              Text('Height: ${character.basics.height}'),
            if (character.basics.weight != null &&
                character.basics.weight!.isNotEmpty)
              Text('Weight: ${character.basics.weight}'),
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
              child: Text('${abilityLabel(a)}: $total ($modifierText)'),
            );
          }).toList(),
        ),
        _SectionCard(
          title: 'Skills',
          children: [
            Builder(
              builder: (context) {
                final proficient = proficientSkills(character);
                return Text(
                  proficient.isEmpty
                      ? 'No skill proficiencies yet.'
                      : proficient.join(', '),
                );
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SkillsScreen(character: character),
                ),
              ),
              icon: const Icon(Icons.checklist),
              label: const Text('View all skills'),
            ),
          ],
        ),
        if (character.characterClass.isSpellcaster)
          _SectionCard(
            title: 'Spells',
            children: [
              Builder(
                builder: (context) {
                  final spellbook = characterSpellbook(character);
                  final count =
                      spellbook.cantrips.length + spellbook.spells.length;
                  return Text(
                    count == 0
                        ? 'No spells recorded.'
                        : '$count spell selection group(s)',
                  );
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SpellListScreen(character: character),
                  ),
                ),
                icon: const Icon(Icons.auto_stories),
                label: const Text('View spell list'),
              ),
            ],
          ),
        _SectionCard(
          title: 'Inventory',
          children: [
            const Text('Manage weapons, armor, and gear.'),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: character.id == null
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => InventoryScreen(
                          characterId: character.id!,
                          maxHp: character.totalHitPoints,
                        ),
                      ),
                    ),
              icon: const Icon(Icons.backpack),
              label: Text(
                character.id == null
                    ? 'Save character to manage inventory'
                    : 'View inventory',
              ),
            ),
          ],
        ),
        _SectionCard(
          title: 'Species: ${character.race.name}',
          children: [
            ...character.race.fixedTraits.map((t) => Text('• $t')),
            ...selectedLabels(
              raceActiveChoices,
              character.raceSelections,
            ).map((s) => Text('• $s')),
            if (character.id != null)
              Builder(
                builder: (context) {
                  final swapInfo = swapInfoFor(
                    character.race.id,
                    character.raceSelections,
                  );
                  if (swapInfo == null) return const SizedBox.shrink();
                  final overrideAsync = ref.watch(
                    racialCantripOverrideProvider(character.id!),
                  );
                  return overrideAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (e, st) => const SizedBox.shrink(),
                    data: (override) {
                      final activeLabel = override != null
                          ? (swapInfo.availableCantrips[override] ??
                                swapInfo.defaultCantripLabel)
                          : swapInfo.defaultCantripLabel;
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '• Current racial cantrip: $activeLabel (swappable on Long Rest, see Combat)',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontStyle: FontStyle.italic),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
        _SectionCard(
          title:
              'Class: ${character.characterClass.name} (Level ${character.level})',
          children: [
            ...selectedLabels([
              skillChoice,
            ], character.classSelections).map((s) => Text('• $s')),
            ...selectedLabels(
              classActiveChoices,
              character.classSelections,
            ).map((s) => Text('• $s')),
            for (var i = 0; i < character.asiChoices.length; i++)
              Text(
                '• Ability Score Improvement #${i + 1}: ${describeAsi(character.asiChoices[i])}',
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ClassFeaturesScreen(
                    characterClass: character.characterClass,
                    level: character.level,
                    classSelections: character.classSelections,
                    asiChoices: character.asiChoices,
                  ),
                ),
              ),
              icon: const Icon(Icons.list_alt),
              label: const Text('View full class features'),
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
            ...selectedLabels(
              backgroundActiveChoices,
              character.backgroundSelections,
            ).map((s) => Text('• $s')),
          ],
        ),
      ],
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
