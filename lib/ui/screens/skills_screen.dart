import 'package:flutter/material.dart';
import '../../data/skills_data.dart';
import '../../data/xp_table.dart';
import '../../models/ability_scores.dart';
import '../../models/character.dart';
import '../../models/character_proficiencies.dart';
import '../../models/character_proficiency_lists.dart';

class SkillsScreen extends StatelessWidget {
  final Character character;

  const SkillsScreen({super.key, required this.character});

  String _abilityShort(Ability a) {
    switch (a) {
      case Ability.strength:
        return 'STR';
      case Ability.dexterity:
        return 'DEX';
      case Ability.constitution:
        return 'CON';
      case Ability.intelligence:
        return 'INT';
      case Ability.wisdom:
        return 'WIS';
      case Ability.charisma:
        return 'CHA';
    }
  }

  @override
  Widget build(BuildContext context) {
    final proficient = proficientSkills(character);
    final totalBonuses = character.totalAbilityBonuses;
    final profBonus = proficiencyBonusForLevel(character.level);

    final sortedSkills = allSkillNames.toList()..sort();
    final weaponProfs = effectiveWeaponProficiencies(character);
    final armorProfs = effectiveArmorProficiencies(character);

    return Scaffold(
      appBar: AppBar(title: const Text('Skills')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ExpansionTile(
              title: Text(
                'Weapon & Armor Proficiencies',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              leading: const Icon(Icons.shield_outlined),
              expandedAlignment: Alignment.centerLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weapons',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: weaponProfs
                            .map((w) => Chip(label: Text(w)))
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Armor',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: armorProfs.isEmpty
                            ? [const Chip(label: Text('None'))]
                            : armorProfs
                                  .map((a) => Chip(label: Text(a)))
                                  .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ExpansionTile(
              title: Text(
                'Skills',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              leading: const Icon(Icons.checklist),
              expandedAlignment: Alignment.centerLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: sortedSkills.map((skill) {
                final ability = skillAbilityMap[skill]!;
                final abilityMod = character.abilityScores.modifierFor(
                  ability,
                  bonuses: totalBonuses,
                );
                final isProficient = proficient.contains(skill);
                final total = abilityMod + (isProficient ? profBonus : 0);
                final totalText = total >= 0 ? '+$total' : '$total';

                return ListTile(
                  leading: Icon(
                    isProficient ? Icons.check_circle : Icons.circle_outlined,
                    color: isProficient
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                  title: Text(skill),
                  subtitle: Text(_abilityShort(ability)),
                  trailing: Text(
                    totalText,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
