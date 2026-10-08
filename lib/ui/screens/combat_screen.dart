import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/items_data.dart';
import '../../data/xp_table.dart';
import '../../data/class_resources_data.dart';
import '../../models/ability_scores.dart';
import '../../models/character.dart';
import '../../models/combat_stats.dart';
import '../../models/item.dart';
import '../../models/dice_roller.dart';
import '../../models/class_resource.dart';
import '../../models/cleric_features.dart';
import '../../models/barbarian_features.dart';
import '../../models/druid_features.dart';
import '../../models/fighter_features.dart';
import '../../data/spell_slots_data.dart';
import '../../data/spells_data.dart';
import '../../models/spell.dart';
import '../../models/spell_effect.dart';
import '../../data/spell_effects_data.dart';
import '../../data/spell_durations_data.dart';

import '../../state/database_provider.dart';
import '../../state/resource_uses_provider.dart';
import '../../state/inventory_provider.dart';
import '../../data/database.dart';
import '../../state/current_hp_provider.dart';
import '../../state/enemies_provider.dart';
import '../../state/party_provider.dart';
import '../../data/weapon_mastery_data.dart';
import '../../data/racial_cantrip_swap_data.dart';
import 'enemies_screen.dart';
import 'party_screen.dart';
import '../../data/skills_data.dart';
import '../../models/character_proficiencies.dart';

part 'combat/combat_core_sections.dart';
part 'combat/combat_helpers.dart';
part 'combat/spellcasting_section.dart';
part 'combat/spell_effects_engine.dart';
part 'combat/fighter_section.dart';
part 'combat/barbarian_section.dart';
part 'combat/weapons_section.dart';
part 'combat/cleric_section.dart';
part 'combat/druid_section.dart';
part 'combat/class_resources_section.dart';
part 'combat/feats_section.dart';
part 'combat/round_tracker_section.dart';

/// Values computed once per build and shared by every combat section.
class _CombatData {
  final int? characterId;
  final List<CharacterInventoryItem> inventoryRows;
  final List<GameItem> equippedItems;
  final CombatStats stats;
  final int profBonus;
  final ArmorClassResult ac;
  final Map<Ability, int> saves;
  final Iterable<GameItem> weapons;
  final List<ClassResource> resources;
  final List<ClassResource> availableResources;
  final AsyncValue<List<CharacterResourceUse>> resourceUsesAsync;
  final String? domain;

  const _CombatData({
    required this.characterId,
    required this.inventoryRows,
    required this.equippedItems,
    required this.stats,
    required this.profBonus,
    required this.ac,
    required this.saves,
    required this.weapons,
    required this.resources,
    required this.availableResources,
    required this.resourceUsesAsync,
    required this.domain,
  });
}

class CombatScreen extends ConsumerStatefulWidget {
  final Character character;

  const CombatScreen({super.key, required this.character});

  @override
  ConsumerState<CombatScreen> createState() => _CombatScreenState();
}

class _CombatScreenState extends ConsumerState<CombatScreen> {
  String? _lastRollResult;
  final TextEditingController _hpAdjustController = TextEditingController();
  final TextEditingController _diceCountController = TextEditingController(
    text: '1',
  );
  int _diceSides = 20;
  int? _selectedEnemyId;
  bool _hasAdvantageFromVex = false;
  bool _lastAttackWasCritical = false;
  int? _lastAttackRollForCorrection;
  bool _isRaging = false;
  bool _isRecklessAttack = false;
  int? _speedOverride;
  bool _retaliationAvailable = false;
  bool _lastAttackHit = true;
  bool _hasAdvantageFromStudiedAttacks = false;
  int? _lastSkillRollForCorrection;
  String? _lastSkillRolledName;
  int? _lifeGivingForceTargetId;
  int _tempHp = 0;
  bool _fanaticalFocusUsedThisRage = false;
  int? _lastSaveModifier;
  String? _lastSaveAbilityShort;
  int _relentlessRageUsesSinceRest = 0;
  String _tempHpSource = '';
  // Druid
  bool _wildShapeActive = false;
  String? _starryConstellation;
  bool _wrathOfTheSeaActive = false;
  String? _cosmicOmen;
  String _primalStrikeType = 'Fire';
  int? _landsAidDamage;
  int? _landsAidHeal;
  // Spellcasting
  String? _concentrationSpell;
  String? _concentrationSpellId;
  int? _concentrationSlotLevel;
  List<String>? _cantripsOverride;
  List<String>? _preparedOverride;
  // Round tracker (0 = not in combat) and timed effects, in rounds left.
  int _round = 0;
  int? _concentrationRoundsLeft;
  int? _rageRoundsLeft;
  int? _starryRoundsLeft;
  int? _wrathRoundsLeft;
  // War God's Blessing: a Shield of Faith/Spiritual Weapon without Concentration.
  String? _blessingSpellId;
  int? _blessingRoundsLeft;
  // Cleric: Invoke Duplicity, Corona of Light (rounds left), Divine Strike
  // (once per turn).
  int? _duplicityRoundsLeft;
  int? _coronaRoundsLeft;
  bool _divineStrikeUsed = false;
  // Fighter: Tactical Master mastery swaps (weapon id → property), Heroic
  // Inspiration (Champion's Heroic Warrior).
  final Map<String, String> _tacticalMasterOverride = {};
  bool _heroicInspiration = false;
  bool _relentlessUsed = false;
  bool _psionicStrikeUsed = false;
  // HP card: the damage being applied is Bludgeoning/Piercing/Slashing.
  bool _physicalDamage = true;
  // Feats
  bool _savageAttackerArmed = false;
  int _battleMedicDie = 8;

  /// setState is protected, so the section extensions in combat/ go through this.
  void _update(VoidCallback fn) => setState(fn);

  @override
  void dispose() {
    _hpAdjustController.dispose();
    _diceCountController.dispose();
    super.dispose();
  }

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

  String _abilityFullName(Ability a) {
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

  @override
  Widget build(BuildContext context) {
    final characterId = widget.character.id;
    final inventoryAsync = characterId != null
        ? ref.watch(characterInventoryProvider(characterId))
        : const AsyncValue.data(<CharacterInventoryItem>[]);

    return inventoryAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (inventoryRows) {
        final equippedItems = inventoryRows
            .where((r) => r.equipped)
            .map((r) => allItems.where((i) => i.id == r.itemId).firstOrNull)
            .whereType<GameItem>()
            .toList();

        final stats = CombatStats(
          character: widget.character,
          equippedItems: equippedItems,
        );
        final profBonus = proficiencyBonusForLevel(widget.character.level);
        final ac = stats.armorClass;
        final saves = stats.savingThrowBonuses(profBonus);
        final weapons = equippedItems.where(
          (i) =>
              i.category == ItemCategory.simpleMeleeWeapon ||
              i.category == ItemCategory.simpleRangedWeapon ||
              i.category == ItemCategory.martialMeleeWeapon ||
              i.category == ItemCategory.martialRangedWeapon,
        );

        final resources = <ClassResource>[
          ...(classResources[widget.character.characterClass.id] ??
              const <ClassResource>[]),
          ...subclassResourcesFor(widget.character),
          for (final feat in widget.character.featIds)
            ...(featResources[feat] ?? const <ClassResource>[]),
        ];
        final availableResources = resources
            .where((r) => r.availableFromLevel <= widget.character.level)
            .toList();
        final resourceUsesAsync = characterId != null
            ? ref.watch(characterResourceUsesProvider(characterId))
            : const AsyncValue.data(<CharacterResourceUse>[]);

        // Keep the party loaded: healing dialogs read it synchronously.
        if (characterId != null) ref.watch(partyMembersProvider(characterId));

        final domain =
            widget.character.classSelections['cleric_subclass']?.firstOrNull;

        final d = _CombatData(
          characterId: characterId,
          inventoryRows: inventoryRows,
          equippedItems: equippedItems,
          stats: stats,
          profBonus: profBonus,
          ac: ac,
          saves: saves,
          weapons: weapons,
          resources: resources,
          availableResources: availableResources,
          resourceUsesAsync: resourceUsesAsync,
          domain: domain,
        );

        // Tabs: (label, widgets). Spells only for classes with spellcasting.
        final tabs = <(String, List<Widget>)>[
          (
            'Overview',
            [
              ..._buildTopStats(context, d),
              ..._buildRoundTracker(context, d),
              ..._buildHpCard(context, d),
              ..._buildQuickDice(context, d),
            ],
          ),
          (
            'Checks',
            [
              ..._buildSavingThrows(context, d),
              ..._buildSkillChecks(context, d),
              ..._buildFighterSection(context, d),
            ],
          ),
          (
            'Attacks',
            [
              ..._buildWeaponsSection(context, d),
              ..._buildUnarmedStrikeSection(context, d),
              ..._buildFeatsSection(context, d),
            ],
          ),
          if (hasSpellcastingSupport(widget.character.characterClass.id))
            ('Spells', _buildSpellcastingSection(context, d)),
          (
            'Class',
            [
              ..._buildBarbarianSection(context, d),
              ..._buildClericSection(context, d),
              ..._buildDruidSection(context, d),
              ..._buildClassResourcesSection(context, d),
            ],
          ),
        ];

        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Combat'),
              actions: [
                if (characterId != null)
                  IconButton(
                    icon: const Icon(Icons.groups),
                    tooltip: 'Enemies',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EnemiesScreen(characterId: characterId),
                      ),
                    ),
                  ),
                if (characterId != null)
                  IconButton(
                    icon: const Icon(Icons.diversity_3),
                    tooltip: 'Party',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PartyScreen(characterId: characterId),
                      ),
                    ),
                  ),
              ],
            ),
            body: Column(
              children: [
                if (_lastRollResult != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      _lastRollResult!,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                // The target stays visible whatever tab is open.
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(children: _buildTargetSelector(context, d)),
                ),
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [for (final t in tabs) Tab(text: t.$1)],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      for (final t in tabs)
                        ListView(
                          padding: const EdgeInsets.all(16),
                          children: t.$2,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _StatBoxButton extends StatelessWidget {
  final String label;
  final String valueText;
  final VoidCallback onTap;

  const _StatBoxButton({
    required this.label,
    required this.valueText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                valueText,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const Icon(Icons.casino, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
