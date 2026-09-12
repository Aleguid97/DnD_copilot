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
import '../../state/database_provider.dart';
import '../../state/resource_uses_provider.dart';
import '../../state/inventory_provider.dart';
import '../../data/database.dart';
import '../../state/current_hp_provider.dart';
import '../../state/enemies_provider.dart';
import '../../state/party_provider.dart';
import '../../data/weapon_mastery_data.dart';
import '../../data/racial_cantrip_swap_data.dart';
import '../../state/racial_cantrip_provider.dart';
import 'enemies_screen.dart';
import 'party_screen.dart';

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
  final TextEditingController _preserveLifeController = TextEditingController();
  int _diceSides = 20;
  int? _selectedEnemyId;
  bool _hasAdvantageFromVex = false;
  bool _lastAttackWasCritical = false;
  int? _lastAttackRollForCorrection;
  int? _healTargetPartyMemberId;
  int? _preserveLifeTargetId;
  bool _isRaging = false;
  bool _isRecklessAttack = false;

  @override
  void dispose() {
    _hpAdjustController.dispose();
    _diceCountController.dispose();
    _preserveLifeController.dispose();
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

        final resources =
            classResources[widget.character.characterClass.id] ?? [];
        final availableResources = resources
            .where((r) => r.availableFromLevel <= widget.character.level)
            .toList();
        final resourceUsesAsync = characterId != null
            ? ref.watch(characterResourceUsesProvider(characterId))
            : const AsyncValue.data(<CharacterResourceUse>[]);

        final domain =
            widget.character.classSelections['cleric_subclass']?.firstOrNull;

        return Scaffold(
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
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatBox(
                            label: 'Armor Class',
                            value: '${ac.value}',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatBoxButton(
                            label: 'Initiative',
                            valueText: () {
                              final total = stats.totalInitiative(profBonus);
                              return total >= 0 ? '+$total' : '$total';
                            }(),
                            onTap: () {
                              final total = stats.totalInitiative(profBonus);
                              final result = rollAttack(total);
                              setState(() {
                                _lastRollResult =
                                    'Initiative: ${result.rolls.first} ${total >= 0 ? "+$total" : total} = ${result.total}';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatBox(
                            label: 'Hit Points',
                            value: '${widget.character.totalHitPoints}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AC breakdown: ${ac.explanation}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    const SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        final maxHp = widget.character.totalHitPoints;
                        final hpAsync = characterId != null
                            ? ref.watch(currentHpProvider(characterId))
                            : const AsyncValue.data(null);
                        return hpAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (e, st) => const SizedBox.shrink(),
                          data: (storedHp) {
                            final currentHp = (storedHp ?? maxHp).clamp(
                              0,
                              maxHp,
                            );
                            final potionRow = inventoryRows
                                .where(
                                  (r) =>
                                      r.itemId == 'potion_of_healing' &&
                                      r.quantity > 0,
                                )
                                .firstOrNull;
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Current HP',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleSmall,
                                        ),
                                        Text(
                                          '$currentHp / $maxHp',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: currentHp <= maxHp ~/ 2
                                                    ? Colors.red
                                                    : Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _hpAdjustController,
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  signed: true,
                                                ),
                                            decoration: const InputDecoration(
                                              labelText:
                                                  'Amount (+heal / -damage)',
                                              border: OutlineInputBorder(),
                                              isDense: true,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: characterId == null
                                              ? null
                                              : () async {
                                                  final delta = int.tryParse(
                                                    _hpAdjustController.text,
                                                  );
                                                  if (delta == null) return;
                                                  final newHp =
                                                      (currentHp + delta).clamp(
                                                        0,
                                                        maxHp,
                                                      );
                                                  await ref
                                                      .read(appDatabaseProvider)
                                                      .setCurrentHp(
                                                        characterId,
                                                        newHp,
                                                      );
                                                  _hpAdjustController.clear();
                                                },
                                          child: const Text('Apply'),
                                        ),
                                      ],
                                    ),
                                    if (potionRow != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            onPressed: characterId == null
                                                ? null
                                                : () async {
                                                    final healResult =
                                                        rollDamage('2d4', 2);
                                                    final newHp =
                                                        (currentHp +
                                                                healResult
                                                                    .total)
                                                            .clamp(0, maxHp);
                                                    await ref
                                                        .read(
                                                          appDatabaseProvider,
                                                        )
                                                        .setCurrentHp(
                                                          characterId,
                                                          newHp,
                                                        );
                                                    await ref
                                                        .read(
                                                          appDatabaseProvider,
                                                        )
                                                        .setInventoryQuantity(
                                                          potionRow.id,
                                                          potionRow.quantity -
                                                              1,
                                                        );
                                                    setState(() {
                                                      _lastRollResult =
                                                          'Potion of Healing: rolled ${healResult.rolls.join('+')} +2 = healed ${healResult.total} HP';
                                                    });
                                                  },
                                            icon: const Icon(Icons.local_drink),
                                            label: Text(
                                              'Drink Potion of Healing (${potionRow.quantity} left)',
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Dice Roll',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: TextField(
                                    controller: _diceCountController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const Text(' d '),
                                DropdownButton<int>(
                                  value: _diceSides,
                                  items: [4, 6, 8, 10, 12, 20, 100]
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          child: Text('$s'),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _diceSides = v ?? 20),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    final count =
                                        int.tryParse(
                                          _diceCountController.text,
                                        ) ??
                                        1;
                                    final result = rollDamage(
                                      '${count}d$_diceSides',
                                      0,
                                    );
                                    setState(() {
                                      _lastRollResult =
                                          'Rolled ${count}d$_diceSides: ${result.rolls.join(', ')} = ${result.total}';
                                    });
                                  },
                                  child: const Text('Roll'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text(
                      'Saving Throws',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...Ability.values.map((a) {
                      final abilityName = _abilityFullName(a);
                      final isProficient = widget
                          .character
                          .characterClass
                          .savingThrows
                          .contains(abilityName);
                      final bonus = saves[a]!;
                      final bonusText = bonus >= 0 ? '+$bonus' : '$bonus';
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            isProficient
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isProficient
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          ),
                          title: Text('${_abilityShort(a)} Save'),
                          trailing: OutlinedButton(
                            onPressed: () {
                              final result = rollAttack(bonus);
                              setState(() {
                                _lastRollResult =
                                    '${_abilityShort(a)} Save: ${result.rolls.first} $bonusText = ${result.total}';
                              });
                            },
                            child: Text('Roll ($bonusText)'),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 24),
                    Builder(
                      builder: (context) {
                        if (characterId == null) return const SizedBox.shrink();
                        final enemiesAsync = ref.watch(
                          combatEnemiesProvider(characterId),
                        );
                        return enemiesAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (e, st) => const SizedBox.shrink(),
                          data: (enemies) {
                            if (enemies.isEmpty) return const SizedBox.shrink();
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    const Icon(Icons.my_location, size: 18),
                                    const SizedBox(width: 8),
                                    const Text('Target: '),
                                    DropdownButton<int?>(
                                      value: _selectedEnemyId,
                                      hint: const Text('None'),
                                      items: [
                                        const DropdownMenuItem(
                                          value: null,
                                          child: Text('None'),
                                        ),
                                        ...enemies.map(
                                          (e) => DropdownMenuItem(
                                            value: e.id,
                                            child: Text(
                                              '${e.name} (AC ${e.armorClass}, ${e.currentHp} HP)',
                                            ),
                                          ),
                                        ),
                                      ],
                                      onChanged: (v) => setState(() {
                                        _selectedEnemyId = v;
                                        _hasAdvantageFromVex = false;
                                      }),
                                    ),
                                    if (_hasAdvantageFromVex)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: Chip(
                                          label: Text('Advantage active (Vex)'),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    if (widget.character.characterClass.id == 'barbarian' &&
                        characterId != null) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Barbarian Features',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      resourceUsesAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (e, st) => const SizedBox.shrink(),
                        data: (usesRows) {
                          final rageResources =
                              classResources['barbarian'] ?? [];
                          final rageResource = rageResources.firstWhere(
                            (r) => r.id == 'rage',
                          );
                          final maxUses = rageResource.maxUses(
                            widget.character.level,
                          );
                          final row = usesRows
                              .where((r) => r.resourceId == 'rage')
                              .firstOrNull;
                          final spent = row?.usesSpent ?? 0;
                          final remaining = (maxUses - spent).clamp(0, maxUses);
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Rage',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall,
                                      ),
                                      Text('$remaining / $maxUses uses'),
                                    ],
                                  ),
                                  Text(
                                    _isRaging
                                        ? 'Active: Resistance to B/P/S damage, +${rageDamageBonus(widget.character.level)} Strength damage, Advantage on Str checks/saves'
                                        : 'Not currently raging.',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _isRaging
                                          ? () => setState(
                                              () => _isRaging = false,
                                            )
                                          : (remaining > 0
                                                ? () async {
                                                    await ref
                                                        .read(
                                                          appDatabaseProvider,
                                                        )
                                                        .useResource(
                                                          characterId,
                                                          'rage',
                                                          maxUses,
                                                        );
                                                    setState(
                                                      () => _isRaging = true,
                                                    );
                                                  }
                                                : null),
                                      child: Text(
                                        _isRaging
                                            ? 'End Rage'
                                            : 'Activate Rage',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      if (widget.character.level >= 2) ...[
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reckless Attack',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  'Advantage on your Strength attacks, but attacks against you also have Advantage, until your next turn.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () => setState(
                                      () => _isRecklessAttack =
                                          !_isRecklessAttack,
                                    ),
                                    child: Text(
                                      _isRecklessAttack
                                          ? 'Reckless Attack: ON (tap to end)'
                                          : 'Activate Reckless Attack',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (widget.character.level >= 9) ...[
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Brutal Strike',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  'Forgo Reckless Attack\'s Advantage on one attack; on hit, extra ${widget.character.level >= 17 ? "2d10" : "1d10"} damage plus Forceful Blow (push 15 ft) or Hamstring Blow (-15 ft Speed).',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          final dice =
                                              widget.character.level >= 17
                                              ? '2d10'
                                              : '1d10';
                                          final result = rollDamage(dice, 0);
                                          setState(() {
                                            _lastRollResult =
                                                'Brutal Strike ($dice): ${result.rolls.join('+')} = ${result.total} extra damage';
                                          });
                                        },
                                        child: const Text('Roll extra damage'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: _selectedEnemyId == null
                                            ? null
                                            : () async {
                                                final enemies =
                                                    ref
                                                        .read(
                                                          combatEnemiesProvider(
                                                            characterId,
                                                          ),
                                                        )
                                                        .value ??
                                                    [];
                                                final target = enemies
                                                    .where(
                                                      (e) =>
                                                          e.id ==
                                                          _selectedEnemyId,
                                                    )
                                                    .firstOrNull;
                                                if (target == null) return;
                                                final current =
                                                    (jsonDecode(
                                                              target
                                                                  .conditionsJson,
                                                            )
                                                            as List)
                                                        .cast<String>();
                                                if (!current.contains(
                                                  'Pushed 15 ft (Forceful Blow)',
                                                )) {
                                                  current.add(
                                                    'Pushed 15 ft (Forceful Blow)',
                                                  );
                                                }
                                                await ref
                                                    .read(appDatabaseProvider)
                                                    .updateEnemyConditions(
                                                      target.id,
                                                      current,
                                                    );
                                                setState(
                                                  () => _lastRollResult =
                                                      '${target.name}: Forceful Blow applied.',
                                                );
                                              },
                                        child: const Text('Forceful Blow'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                      Text(
                        'Equipped Weapons',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (weapons.isEmpty)
                        const Text(
                          'No weapons currently equipped. Mark a weapon as equipped in Inventory.',
                        )
                      else
                        ...weapons.map((w) {
                          final info = stats.weaponAttackInfo(w, profBonus);
                          final attackText = info.attackBonus >= 0
                              ? '+${info.attackBonus}'
                              : '${info.attackBonus}';
                          final usesGwf = stats.weaponUsesGreatWeaponFighting(
                            w,
                          );
                          final masteryProp = weaponMasteryProperty[w.id];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    w.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  Text(
                                    [
                                      w.damage ?? '',
                                      ...w.properties,
                                    ].where((s) => s.isNotEmpty).join(' • '),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  if (usesGwf)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Great Weapon Fighting active: 1s and 2s auto-reroll',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontStyle: FontStyle.italic,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                      ),
                                    ),

                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () async {
                                            final hasAdvantage =
                                                _hasAdvantageFromVex ||
                                                (widget
                                                            .character
                                                            .characterClass
                                                            .id ==
                                                        'barbarian' &&
                                                    _isRecklessAttack);
                                            final firstRoll = rollAttack(
                                              info.attackBonus,
                                            );
                                            DiceRollResult result = firstRoll;
                                            String advantageNote = '';
                                            if (hasAdvantage) {
                                              final secondRoll = rollAttack(
                                                info.attackBonus,
                                              );
                                              if (secondRoll.total >
                                                  firstRoll.total)
                                                result = secondRoll;
                                              advantageNote =
                                                  ' (Advantage: ${firstRoll.rolls.first}/${secondRoll.rolls.first})';
                                            }

                                            String ammoNote = '';
                                            if (w.ammunitionItemId != null &&
                                                characterId != null) {
                                              final ammoRow = inventoryRows
                                                  .where(
                                                    (r) =>
                                                        r.itemId ==
                                                        w.ammunitionItemId,
                                                  )
                                                  .firstOrNull;
                                              if (ammoRow != null &&
                                                  ammoRow.quantity > 0) {
                                                await ref
                                                    .read(appDatabaseProvider)
                                                    .setInventoryQuantity(
                                                      ammoRow.id,
                                                      ammoRow.quantity - 1,
                                                    );
                                                ammoNote =
                                                    ' (1 ${w.ammunitionItemId} used, ${ammoRow.quantity - 1} left)';
                                              } else {
                                                ammoNote = ' (OUT OF AMMO!)';
                                              }
                                            }

                                            String masteryNote = '';
                                            String hitNote = '';
                                            final isNat20 =
                                                result.rolls.first == 20;
                                            if (characterId != null &&
                                                _selectedEnemyId != null) {
                                              final enemies =
                                                  ref
                                                      .read(
                                                        combatEnemiesProvider(
                                                          characterId,
                                                        ),
                                                      )
                                                      .value ??
                                                  [];
                                              final target = enemies
                                                  .where(
                                                    (e) =>
                                                        e.id ==
                                                        _selectedEnemyId,
                                                  )
                                                  .firstOrNull;
                                              if (target != null) {
                                                final didHit =
                                                    isNat20 ||
                                                    result.total >=
                                                        target.armorClass;
                                                hitNote = didHit
                                                    ? (isNat20
                                                          ? ' — CRITICAL HIT!'
                                                          : ' — HIT!')
                                                    : ' — MISS';
                                                setState(
                                                  () => _lastAttackWasCritical =
                                                      isNat20 && didHit,
                                                );
                                                if (didHit &&
                                                    masteryProp == 'Vex') {
                                                  setState(
                                                    () => _hasAdvantageFromVex =
                                                        true,
                                                  );
                                                  masteryNote =
                                                      ' — Vex: Advantage granted on your next attack vs this target';
                                                } else if (hasAdvantage) {
                                                  setState(
                                                    () => _hasAdvantageFromVex =
                                                        false,
                                                  );
                                                }
                                              }
                                            } else {
                                              setState(
                                                () => _lastAttackWasCritical =
                                                    isNat20,
                                              );
                                              if (isNat20) {
                                                hitNote =
                                                    ' — CRITICAL HIT (natural 20)!';
                                              }
                                              if (masteryProp == 'Vex') {
                                                setState(
                                                  () => _hasAdvantageFromVex =
                                                      true,
                                                );
                                                masteryNote =
                                                    ' — Vex: Advantage granted on your next attack vs this target';
                                              } else if (hasAdvantage) {
                                                setState(
                                                  () => _hasAdvantageFromVex =
                                                      false,
                                                );
                                              }
                                            }

                                            setState(() {
                                              _lastRollResult =
                                                  '${w.name} — Attack roll: ${result.rolls.first} $attackText = ${result.total}$hitNote$advantageNote$ammoNote$masteryNote';
                                              _lastAttackRollForCorrection =
                                                  result.total;
                                            });
                                          },
                                          child: Text(
                                            'Roll to Hit ($attackText)',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () async {
                                            final isCrit =
                                                _lastAttackWasCritical;
                                            final baseResult = usesGwf
                                                ? rollDamageWithReroll(
                                                    info.damageDice,
                                                    0,
                                                    isCritical: isCrit,
                                                  )
                                                : rollDamage(
                                                    info.damageDice,
                                                    0,
                                                    isCritical: isCrit,
                                                  );

                                            final parts = <String>[
                                              '${baseResult.rolls.join('+')} (dice)',
                                            ];
                                            var grandTotal = baseResult.total;

                                            if (info.damageModifier != 0) {
                                              parts.add(
                                                '${info.damageModifier >= 0 ? "+" : ""}${info.damageModifier} (mod)',
                                              );
                                              grandTotal += info.damageModifier;
                                            }

                                            if (widget
                                                    .character
                                                    .characterClass
                                                    .id ==
                                                'cleric') {
                                              final blessedChoice = widget
                                                  .character
                                                  .classSelections['cleric_blessed_strikes']
                                                  ?.firstOrNull;
                                              if (blessedChoice ==
                                                  'divine_strike') {
                                                final extraDice =
                                                    widget.character.level >= 14
                                                    ? '2d8'
                                                    : '1d8';
                                                final extra = rollDamage(
                                                  extraDice,
                                                  0,
                                                  isCritical: isCrit,
                                                );
                                                parts.add(
                                                  '+${extra.total} (Divine Strike)',
                                                );
                                                grandTotal += extra.total;
                                              }
                                            }

                                            if (widget
                                                        .character
                                                        .characterClass
                                                        .id ==
                                                    'barbarian' &&
                                                _isRaging) {
                                              final bonus = rageDamageBonus(
                                                widget.character.level,
                                              );
                                              parts.add('+$bonus (Rage)');
                                              grandTotal += bonus;
                                            }

                                            String targetNote = '';
                                            if (characterId != null &&
                                                _selectedEnemyId != null) {
                                              final enemies =
                                                  ref
                                                      .read(
                                                        combatEnemiesProvider(
                                                          characterId,
                                                        ),
                                                      )
                                                      .value ??
                                                  [];
                                              final target = enemies
                                                  .where(
                                                    (e) =>
                                                        e.id ==
                                                        _selectedEnemyId,
                                                  )
                                                  .firstOrNull;
                                              if (target != null) {
                                                final newHp =
                                                    (target.currentHp -
                                                            grandTotal)
                                                        .clamp(0, target.maxHp);
                                                if (newHp <= 0) {
                                                  await ref
                                                      .read(appDatabaseProvider)
                                                      .removeEnemy(target.id);
                                                  targetNote =
                                                      ' — ${target.name} defeated!';
                                                  setState(
                                                    () =>
                                                        _selectedEnemyId = null,
                                                  );
                                                } else {
                                                  await ref
                                                      .read(appDatabaseProvider)
                                                      .updateEnemyHp(
                                                        target.id,
                                                        newHp,
                                                      );
                                                  targetNote =
                                                      ' — ${target.name}: $newHp/${target.maxHp} HP left';
                                                }
                                              }
                                            }

                                            setState(() {
                                              _lastRollResult =
                                                  '${w.name} — Damage: ${parts.join(' ')} = $grandTotal ${info.damageType}$targetNote';
                                              _lastAttackWasCritical = false;
                                            });
                                          },

                                          child: Text(
                                            'Roll Damage (${info.damageDice})',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Builder(
                                    builder: (context) {
                                      if (masteryProp == null ||
                                          masteryProp == 'Vex') {
                                        return const SizedBox.shrink();
                                      }

                                      Future<CombatEnemy?>
                                      currentTarget() async {
                                        if (characterId == null ||
                                            _selectedEnemyId == null)
                                          return null;
                                        final enemies =
                                            ref
                                                .read(
                                                  combatEnemiesProvider(
                                                    characterId,
                                                  ),
                                                )
                                                .value ??
                                            [];
                                        return enemies
                                            .where(
                                              (e) => e.id == _selectedEnemyId,
                                            )
                                            .firstOrNull;
                                      }

                                      Future<void> applyCondition(
                                        String label,
                                      ) async {
                                        final target = await currentTarget();
                                        if (target == null) {
                                          setState(
                                            () => _lastRollResult =
                                                '$masteryProp: no target selected.',
                                          );
                                          return;
                                        }
                                        final current = target.conditionsJson;
                                        final list =
                                            (jsonDecode(current) as List)
                                                .cast<String>();
                                        if (!list.contains(label))
                                          list.add(label);
                                        await ref
                                            .read(appDatabaseProvider)
                                            .updateEnemyConditions(
                                              target.id,
                                              list,
                                            );
                                        setState(
                                          () => _lastRollResult =
                                              '${target.name}: $label applied.',
                                        );
                                      }

                                      switch (masteryProp) {
                                        case 'Graze':
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: OutlinedButton.icon(
                                                onPressed: () async {
                                                  String targetNote = '';
                                                  final target =
                                                      await currentTarget();
                                                  if (target != null) {
                                                    final newHp =
                                                        (target.currentHp -
                                                                info.damageModifier)
                                                            .clamp(
                                                              0,
                                                              target.maxHp,
                                                            );
                                                    if (newHp <= 0) {
                                                      await ref
                                                          .read(
                                                            appDatabaseProvider,
                                                          )
                                                          .removeEnemy(
                                                            target.id,
                                                          );
                                                      targetNote =
                                                          ' — ${target.name} defeated!';
                                                      setState(
                                                        () => _selectedEnemyId =
                                                            null,
                                                      );
                                                    } else {
                                                      await ref
                                                          .read(
                                                            appDatabaseProvider,
                                                          )
                                                          .updateEnemyHp(
                                                            target.id,
                                                            newHp,
                                                          );
                                                      targetNote =
                                                          ' — ${target.name}: $newHp/${target.maxHp} HP left';
                                                    }
                                                  }
                                                  setState(() {
                                                    _lastRollResult =
                                                        '${w.name} — Graze (missed hit): ${info.damageModifier} ${info.damageType} damage anyway$targetNote';
                                                  });
                                                },
                                                icon: const Icon(Icons.bolt),
                                                label: Text(
                                                  'Missed? Apply Graze damage (${info.damageModifier})',
                                                ),
                                              ),
                                            ),
                                          );

                                        case 'Push':
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: OutlinedButton.icon(
                                                onPressed: () => applyCondition(
                                                  'Pushed 10 ft (Large or smaller)',
                                                ),
                                                icon: const Icon(
                                                  Icons.arrow_forward,
                                                ),
                                                label: const Text(
                                                  'Push target 10 ft (on hit)',
                                                ),
                                              ),
                                            ),
                                          );

                                        case 'Sap':
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: OutlinedButton.icon(
                                                onPressed: () => applyCondition(
                                                  'Disadvantage on next attack',
                                                ),
                                                icon: const Icon(
                                                  Icons.trending_down,
                                                ),
                                                label: const Text(
                                                  'Sap: target has Disadvantage (on hit)',
                                                ),
                                              ),
                                            ),
                                          );

                                        case 'Slow':
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: OutlinedButton.icon(
                                                onPressed: () async {
                                                  final target =
                                                      await currentTarget();
                                                  if (target == null) {
                                                    setState(
                                                      () => _lastRollResult =
                                                          'Slow: no target selected.',
                                                    );
                                                    return;
                                                  }
                                                  final reducedSpeed =
                                                      (target.speed - 10).clamp(
                                                        0,
                                                        999,
                                                      );
                                                  await ref
                                                      .read(appDatabaseProvider)
                                                      .updateEnemySpeed(
                                                        target.id,
                                                        reducedSpeed,
                                                      );
                                                  await applyCondition(
                                                    'Slowed (-10 ft Speed)',
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.slow_motion_video,
                                                ),
                                                label: const Text(
                                                  'Slow: reduce Speed by 10 ft (on hit)',
                                                ),
                                              ),
                                            ),
                                          );

                                        case 'Topple':
                                          final dc =
                                              8 +
                                              info.damageModifier +
                                              profBonus;
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Topple: target makes a Constitution save (DC $dc) or falls Prone.',
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.bodySmall,
                                                ),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: OutlinedButton.icon(
                                                    onPressed: () =>
                                                        applyCondition('Prone'),
                                                    icon: const Icon(
                                                      Icons.arrow_downward,
                                                    ),
                                                    label: const Text(
                                                      'Target failed save → apply Prone',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );

                                        case 'Cleave':
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: OutlinedButton.icon(
                                                onPressed: () async {
                                                  if (characterId == null)
                                                    return;
                                                  final enemies =
                                                      ref
                                                          .read(
                                                            combatEnemiesProvider(
                                                              characterId,
                                                            ),
                                                          )
                                                          .value ??
                                                      [];
                                                  final others = enemies
                                                      .where(
                                                        (e) =>
                                                            e.id !=
                                                            _selectedEnemyId,
                                                      )
                                                      .toList();
                                                  if (others.isEmpty) {
                                                    setState(
                                                      () => _lastRollResult =
                                                          'Cleave: no second target available.',
                                                    );
                                                    return;
                                                  }
                                                  final secondTarget = await showDialog<CombatEnemy>(
                                                    context: context,
                                                    builder: (ctx) => SimpleDialog(
                                                      title: const Text(
                                                        'Choose second target (Cleave)',
                                                      ),
                                                      children: others
                                                          .map(
                                                            (
                                                              e,
                                                            ) => SimpleDialogOption(
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                    ctx,
                                                                  ).pop(e),
                                                              child: Text(
                                                                '${e.name} (${e.currentHp}/${e.maxHp} HP)',
                                                              ),
                                                            ),
                                                          )
                                                          .toList(),
                                                    ),
                                                  );
                                                  if (secondTarget == null)
                                                    return;
                                                  final cleaveModifier =
                                                      info.damageModifier < 0
                                                      ? info.damageModifier
                                                      : 0;
                                                  final result = rollDamage(
                                                    info.damageDice,
                                                    cleaveModifier,
                                                  );
                                                  final newHp =
                                                      (secondTarget.currentHp -
                                                              result.total)
                                                          .clamp(
                                                            0,
                                                            secondTarget.maxHp,
                                                          );
                                                  if (newHp <= 0) {
                                                    await ref
                                                        .read(
                                                          appDatabaseProvider,
                                                        )
                                                        .removeEnemy(
                                                          secondTarget.id,
                                                        );
                                                    setState(
                                                      () => _lastRollResult =
                                                          'Cleave — ${secondTarget.name}: ${result.total} damage, defeated!',
                                                    );
                                                  } else {
                                                    await ref
                                                        .read(
                                                          appDatabaseProvider,
                                                        )
                                                        .updateEnemyHp(
                                                          secondTarget.id,
                                                          newHp,
                                                        );
                                                    setState(
                                                      () => _lastRollResult =
                                                          'Cleave — ${secondTarget.name}: ${result.total} damage, $newHp/${secondTarget.maxHp} HP left',
                                                    );
                                                  }
                                                },
                                                icon: const Icon(
                                                  Icons.call_split,
                                                ),
                                                label: const Text(
                                                  'Cleave: attack second target (on hit)',
                                                ),
                                              ),
                                            ),
                                          );

                                        case 'Nick':
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Text(
                                              'Nick: your off-hand attack can be made as part of the Attack action instead of a Bonus Action.',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                            ),
                                          );

                                        default:
                                          return const SizedBox.shrink();
                                      }
                                    },
                                  ),
                                  if (w.ammunitionItemId != null) ...[
                                    const SizedBox(height: 8),
                                    Builder(
                                      builder: (context) {
                                        final ammoRow = inventoryRows
                                            .where(
                                              (r) =>
                                                  r.itemId ==
                                                  w.ammunitionItemId,
                                            )
                                            .firstOrNull;
                                        final ammoItem = allItems
                                            .where(
                                              (i) => i.id == w.ammunitionItemId,
                                            )
                                            .firstOrNull;
                                        final remaining =
                                            ammoRow?.quantity ?? 0;
                                        return Row(
                                          children: [
                                            Icon(
                                              Icons.inventory_2_outlined,
                                              size: 16,
                                              color: remaining > 0
                                                  ? Colors.grey
                                                  : Colors.red,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${ammoItem?.name ?? w.ammunitionItemId}: $remaining left',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: remaining > 0
                                                        ? null
                                                        : Colors.red,
                                                  ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),

                      const SizedBox(height: 24),
                      Text(
                        'Unarmed Strike',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Builder(
                        builder: (context) {
                          final info = stats.unarmedStrikeInfo(profBonus);
                          final attackText = info.attackBonus >= 0
                              ? '+${info.attackBonus}'
                              : '${info.attackBonus}';
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        final result = rollAttack(
                                          info.attackBonus,
                                        );
                                        final isNat20 =
                                            result.rolls.first == 20;
                                        setState(() {
                                          _lastAttackWasCritical = isNat20;
                                          _lastAttackRollForCorrection =
                                              result.total;
                                          _lastRollResult =
                                              'Unarmed Strike — Attack roll: ${result.rolls.first} $attackText = ${result.total}${isNat20 ? " — CRITICAL HIT!" : ""}';
                                        });
                                      },
                                      child: Text('Roll to Hit ($attackText)'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        final isCrit = _lastAttackWasCritical;
                                        final result = rollDamage(
                                          info.damageDice,
                                          info.damageModifier,
                                          isCritical: isCrit,
                                        );
                                        setState(() {
                                          _lastRollResult =
                                              'Unarmed Strike — Damage: ${result.total} ${info.damageType}';
                                          _lastAttackWasCritical = false;
                                        });
                                      },
                                      child: const Text('Roll Damage'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      Builder(
                        builder: (context) {
                          final offHandInfo = stats.offHandAttackInfo(
                            profBonus,
                          );
                          final offHandWeapon = stats.offHandWeapon;
                          if (offHandInfo == null || offHandWeapon == null)
                            return const SizedBox.shrink();
                          final attackText = offHandInfo.attackBonus >= 0
                              ? '+${offHandInfo.attackBonus}'
                              : '${offHandInfo.attackBonus}';
                          return Column(
                            children: [
                              const SizedBox(height: 24),
                              Text(
                                'Off-Hand Attack (Bonus Action)',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Using ${offHandWeapon.name}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            final result = rollAttack(
                                              offHandInfo.attackBonus,
                                            );
                                            setState(() {
                                              _lastRollResult =
                                                  'Off-Hand (${offHandWeapon.name}) — Attack roll: ${result.rolls.first} $attackText = ${result.total}';
                                            });
                                          },
                                          child: Text(
                                            'Roll to Hit ($attackText)',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            final result = rollDamage(
                                              offHandInfo.damageDice,
                                              offHandInfo.damageModifier,
                                            );
                                            setState(() {
                                              _lastRollResult =
                                                  'Off-Hand (${offHandWeapon.name}) — Damage: ${result.total} ${offHandInfo.damageType}';
                                            });
                                          },
                                          child: Text(
                                            'Roll Damage (${offHandInfo.damageDice})',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      if (widget.character.characterClass.id == 'cleric' &&
                          characterId != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Cleric Features',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Builder(
                          builder: (context) {
                            final partyAsync = ref.watch(
                              partyMembersProvider(characterId),
                            );
                            return partyAsync.when(
                              loading: () => const SizedBox.shrink(),
                              error: (e, st) => const SizedBox.shrink(),
                              data: (members) {
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.favorite, size: 18),
                                        const SizedBox(width: 8),
                                        const Text('Heal target: '),
                                        DropdownButton<int?>(
                                          value: _healTargetPartyMemberId,
                                          items: [
                                            const DropdownMenuItem(
                                              value: null,
                                              child: Text('Myself'),
                                            ),
                                            ...members.map(
                                              (m) => DropdownMenuItem(
                                                value: m.id,
                                                child: Text(
                                                  '${m.name} (${m.currentHp}/${m.maxHp} HP)',
                                                ),
                                              ),
                                            ),
                                          ],
                                          onChanged: (v) => setState(
                                            () => _healTargetPartyMemberId = v,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Divine Spark',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  'Heal a target, or force a Constitution save (fail: full damage, success: half).',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          final isLife = domain == 'life';
                                          final hasSupreme =
                                              isLife &&
                                              widget.character.level >= 17;
                                          final result = rollDivineSpark(
                                            widget.character,
                                          );
                                          final healTotal = hasSupreme
                                              ? maxHealingRoll(
                                                      '${divineSparkDiceCount(widget.character.level)}d8',
                                                    ) +
                                                    result.modifier
                                              : result.total;

                                          if (_healTargetPartyMemberId ==
                                              null) {
                                            final maxHp =
                                                widget.character.totalHitPoints;
                                            final currentStored = await ref
                                                .read(
                                                  currentHpProvider(
                                                    characterId,
                                                  ).future,
                                                );
                                            final currentHp =
                                                currentStored ?? maxHp;

                                            if (currentHp >= maxHp) {
                                              setState(() {
                                                _lastRollResult =
                                                    'Divine Spark: your HP already at maximum ($currentHp/$maxHp) — no healing applied.';
                                              });
                                              return;
                                            }

                                            var newHp = (currentHp + healTotal)
                                                .clamp(0, maxHp);
                                            String selfHealNote = '';
                                            if (isLife &&
                                                widget.character.level >= 6) {
                                              newHp =
                                                  (newHp +
                                                          blessedHealerSelfHeal())
                                                      .clamp(0, maxHp);
                                              selfHealNote =
                                                  ' (+ ${blessedHealerSelfHeal()} self-heal, Blessed Healer)';
                                            }
                                            await ref
                                                .read(appDatabaseProvider)
                                                .setCurrentHp(
                                                  characterId,
                                                  newHp,
                                                );
                                            setState(() {
                                              _lastRollResult =
                                                  'Divine Spark (self-heal): ${hasSupreme ? "MAX " : ""}${result.rolls.join('+')} + ${result.modifier} = $healTotal HP$selfHealNote → now $newHp/$maxHp HP';
                                            });
                                          } else {
                                            final members =
                                                ref
                                                    .read(
                                                      partyMembersProvider(
                                                        characterId,
                                                      ),
                                                    )
                                                    .value ??
                                                [];
                                            final target = members
                                                .where(
                                                  (m) =>
                                                      m.id ==
                                                      _healTargetPartyMemberId,
                                                )
                                                .firstOrNull;
                                            if (target == null) return;

                                            if (target.currentHp >=
                                                target.maxHp) {
                                              setState(() {
                                                _lastRollResult =
                                                    'Divine Spark: ${target.name} already at maximum HP (${target.currentHp}/${target.maxHp}) — no healing applied.';
                                              });
                                              return;
                                            }

                                            var newHp =
                                                (target.currentHp + healTotal)
                                                    .clamp(0, target.maxHp);
                                            String selfHealNote = '';
                                            if (isLife &&
                                                widget.character.level >= 6) {
                                              final maxHp = widget
                                                  .character
                                                  .totalHitPoints;
                                              final currentStored = await ref
                                                  .read(
                                                    currentHpProvider(
                                                      characterId,
                                                    ).future,
                                                  );
                                              final currentSelfHp =
                                                  currentStored ?? maxHp;
                                              final selfHeal =
                                                  blessedHealerSelfHeal();
                                              final newSelfHp =
                                                  (currentSelfHp + selfHeal)
                                                      .clamp(0, maxHp);
                                              await ref
                                                  .read(appDatabaseProvider)
                                                  .setCurrentHp(
                                                    characterId,
                                                    newSelfHp,
                                                  );
                                              selfHealNote =
                                                  ' (+ $selfHeal self-heal, Blessed Healer)';
                                            }
                                            await ref
                                                .read(appDatabaseProvider)
                                                .updatePartyMemberHp(
                                                  target.id,
                                                  newHp,
                                                );
                                            setState(() {
                                              _lastRollResult =
                                                  'Divine Spark (${target.name}): ${hasSupreme ? "MAX " : ""}${result.rolls.join('+')} + ${result.modifier} = $healTotal HP$selfHealNote → now $newHp/${target.maxHp} HP';
                                            });
                                          }
                                        },
                                        child: const Text('Heal'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          final result = rollDivineSpark(
                                            widget.character,
                                          );
                                          String targetNote = '';
                                          if (_selectedEnemyId != null) {
                                            final enemies =
                                                ref
                                                    .read(
                                                      combatEnemiesProvider(
                                                        characterId,
                                                      ),
                                                    )
                                                    .value ??
                                                [];
                                            final target = enemies
                                                .where(
                                                  (e) =>
                                                      e.id == _selectedEnemyId,
                                                )
                                                .firstOrNull;
                                            if (target != null) {
                                              final newHp =
                                                  (target.currentHp -
                                                          result.total)
                                                      .clamp(0, target.maxHp);
                                              if (newHp <= 0) {
                                                await ref
                                                    .read(appDatabaseProvider)
                                                    .removeEnemy(target.id);
                                                targetNote =
                                                    ' — ${target.name} defeated!';
                                              } else {
                                                await ref
                                                    .read(appDatabaseProvider)
                                                    .updateEnemyHp(
                                                      target.id,
                                                      newHp,
                                                    );
                                                targetNote =
                                                    ' — ${target.name}: $newHp/${target.maxHp} HP left';
                                              }
                                            }
                                          }
                                          setState(() {
                                            _lastRollResult =
                                                'Divine Spark (damage, target fails save): ${result.total}$targetNote';
                                          });
                                        },
                                        child: const Text('Damage (fail)'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Turn Undead',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  'Undead within 30 ft make a Wisdom save or are Frightened + Incapacitated for 1 minute.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: _selectedEnemyId == null
                                            ? null
                                            : () async {
                                                final enemies =
                                                    ref
                                                        .read(
                                                          combatEnemiesProvider(
                                                            characterId,
                                                          ),
                                                        )
                                                        .value ??
                                                    [];
                                                final target = enemies
                                                    .where(
                                                      (e) =>
                                                          e.id ==
                                                          _selectedEnemyId,
                                                    )
                                                    .firstOrNull;
                                                if (target == null) return;
                                                final current =
                                                    (jsonDecode(
                                                              target
                                                                  .conditionsJson,
                                                            )
                                                            as List)
                                                        .cast<String>();
                                                if (!current.contains(
                                                  'Frightened + Incapacitated (Turn Undead)',
                                                )) {
                                                  current.add(
                                                    'Frightened + Incapacitated (Turn Undead)',
                                                  );
                                                }
                                                await ref
                                                    .read(appDatabaseProvider)
                                                    .updateEnemyConditions(
                                                      target.id,
                                                      current,
                                                    );
                                                setState(
                                                  () => _lastRollResult =
                                                      '${target.name}: failed save, Turned.',
                                                );
                                              },
                                        child: const Text('Target failed save'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (widget.character.level >= 5)
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () async {
                                            final result = rollSearUndead(
                                              widget.character,
                                            );
                                            String targetNote = '';
                                            if (_selectedEnemyId != null) {
                                              final enemies =
                                                  ref
                                                      .read(
                                                        combatEnemiesProvider(
                                                          characterId,
                                                        ),
                                                      )
                                                      .value ??
                                                  [];
                                              final target = enemies
                                                  .where(
                                                    (e) =>
                                                        e.id ==
                                                        _selectedEnemyId,
                                                  )
                                                  .firstOrNull;
                                              if (target != null) {
                                                final newHp =
                                                    (target.currentHp -
                                                            result.total)
                                                        .clamp(0, target.maxHp);
                                                if (newHp <= 0) {
                                                  await ref
                                                      .read(appDatabaseProvider)
                                                      .removeEnemy(target.id);
                                                  targetNote =
                                                      ' — ${target.name} defeated!';
                                                } else {
                                                  await ref
                                                      .read(appDatabaseProvider)
                                                      .updateEnemyHp(
                                                        target.id,
                                                        newHp,
                                                      );
                                                  targetNote =
                                                      ' — ${target.name}: $newHp/${target.maxHp} HP left';
                                                }
                                              }
                                            }
                                            setState(() {
                                              _lastRollResult =
                                                  'Sear Undead: ${result.total} Radiant$targetNote';
                                            });
                                          },
                                          child: const Text('Sear Undead'),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (domain == 'war') ...[
                          const SizedBox(height: 8),
                          resourceUsesAsync.when(
                            loading: () => const SizedBox.shrink(),
                            error: (e, st) => const SizedBox.shrink(),
                            data: (usesRows) {
                              final wisMod = wisdomModifier(
                                widget.character,
                              ).clamp(1, 20);
                              final row = usesRows
                                  .where((r) => r.resourceId == 'war_priest')
                                  .firstOrNull;
                              final spent = row?.usesSpent ?? 0;
                              final remaining = (wisMod - spent).clamp(
                                0,
                                wisMod,
                              );
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'War Priest',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall,
                                      ),
                                      Text(
                                        'Bonus Action weapon/Unarmed Strike attack. Uses: $remaining / $wisMod (recharge on Short or Long Rest)',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: remaining > 0
                                              ? () => ref
                                                    .read(appDatabaseProvider)
                                                    .useResource(
                                                      characterId,
                                                      'war_priest',
                                                      wisMod,
                                                    )
                                              : null,
                                          child: const Text(
                                            'Use bonus action attack',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Guided Strike',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  Text(
                                    _lastAttackRollForCorrection != null
                                        ? 'Last attack roll: $_lastAttackRollForCorrection'
                                        : 'No recent attack roll to correct.',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed:
                                          _lastAttackRollForCorrection == null
                                          ? null
                                          : () {
                                              final corrected = applyGuidedStrike(
                                                _lastAttackRollForCorrection!,
                                              );
                                              setState(() {
                                                _lastRollResult =
                                                    'Guided Strike: $_lastAttackRollForCorrection + 10 = $corrected';
                                              });
                                            },
                                      child: const Text(
                                        'Apply +10 to missed roll',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (domain == 'life') ...[
                          const SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Preserve Life',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  Text(
                                    'Total pool: ${preserveLifePool(widget.character.level)} HP, split among Bloodied allies within 30 ft (max half their HP max each).',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Builder(
                                    builder: (context) {
                                      final partyAsync = ref.watch(
                                        partyMembersProvider(characterId),
                                      );
                                      return partyAsync.when(
                                        loading: () => const SizedBox.shrink(),
                                        error: (e, st) =>
                                            const SizedBox.shrink(),
                                        data: (members) {
                                          if (members.isEmpty) {
                                            return const Text(
                                              'No party members added yet. Add allies from the Party screen first.',
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                              ),
                                            );
                                          }
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Text('Target: '),
                                                  DropdownButton<int?>(
                                                    value:
                                                        _preserveLifeTargetId,
                                                    hint: const Text(
                                                      'Choose ally',
                                                    ),
                                                    items: members
                                                        .map(
                                                          (
                                                            m,
                                                          ) => DropdownMenuItem(
                                                            value: m.id,
                                                            child: Text(
                                                              '${m.name} (${m.currentHp}/${m.maxHp} HP)',
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                    onChanged: (v) => setState(
                                                      () =>
                                                          _preserveLifeTargetId =
                                                              v,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: TextField(
                                                      controller:
                                                          _preserveLifeController,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration: const InputDecoration(
                                                        labelText:
                                                            'HP to give this ally',
                                                        isDense: true,
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      final amount = int.tryParse(
                                                        _preserveLifeController
                                                            .text,
                                                      );
                                                      if (amount == null ||
                                                          _preserveLifeTargetId ==
                                                              null)
                                                        return;
                                                      final target = members
                                                          .where(
                                                            (m) =>
                                                                m.id ==
                                                                _preserveLifeTargetId,
                                                          )
                                                          .firstOrNull;
                                                      if (target == null)
                                                        return;
                                                      final cap =
                                                          target.maxHp ~/ 2;
                                                      final actualHeal =
                                                          amount > cap
                                                          ? cap
                                                          : amount;
                                                      final newHp =
                                                          (target.currentHp +
                                                                  actualHeal)
                                                              .clamp(
                                                                0,
                                                                target.maxHp,
                                                              );
                                                      await ref
                                                          .read(
                                                            appDatabaseProvider,
                                                          )
                                                          .updatePartyMemberHp(
                                                            target.id,
                                                            newHp,
                                                          );
                                                      setState(() {
                                                        _lastRollResult =
                                                            'Preserve Life: ${target.name} healed $actualHeal HP (capped at half max) → $newHp/${target.maxHp}';
                                                        _preserveLifeController
                                                            .clear();
                                                      });
                                                    },
                                                    child: const Text('Apply'),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (domain == 'light') ...[
                          const SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Radiance of the Dawn',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  Text(
                                    '2d10 + Cleric level Radiant, 30 ft emanation, Con save for half (apply per enemy manually).',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        final result = rollRadianceOfTheDawn(
                                          widget.character,
                                        );
                                        setState(() {
                                          _lastRollResult =
                                              'Radiance of the Dawn: ${result.rolls.join('+')} + ${widget.character.level} = ${result.total} (half on successful save)';
                                        });
                                      },
                                      child: const Text('Roll damage'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Warding Flare',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  Text(
                                    'Reaction: impose Disadvantage on an incoming attack. Uses available: ${wardingFlareUses(widget.character)} (min 1, recharge on Long Rest).',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (domain == 'trickery') ...[
                          const SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Blessing of the Trickster',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  Text(
                                    'Grant Advantage on Dexterity (Stealth) checks to yourself or a willing creature within 30 ft, until you finish a Long Rest or use this again.',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Invoke Duplicity',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  Text(
                                    'Channel Divinity: create an illusory duplicate of yourself for 1 minute (Cast Spells / Distract / Move benefits). Track manually at the table.',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],

                      if (availableResources.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Class Resources',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (characterId != null)
                              PopupMenuButton<RestType>(
                                child: const Chip(label: Text('Rest')),
                                onSelected: (restType) async {
                                  await ref
                                      .read(appDatabaseProvider)
                                      .applyRest(
                                        characterId,
                                        restType,
                                        availableResources,
                                      );
                                  if (restType == RestType.long) {
                                    final swapInfo = swapInfoFor(
                                      widget.character.race.id,
                                      widget.character.raceSelections,
                                    );
                                    if (swapInfo != null && context.mounted) {
                                      final chosen = await showDialog<String>(
                                        context: context,
                                        builder: (ctx) => SimpleDialog(
                                          title: const Text(
                                            'Swap racial cantrip? (Long Rest)',
                                          ),
                                          children: swapInfo
                                              .availableCantrips
                                              .entries
                                              .map(
                                                (e) => SimpleDialogOption(
                                                  onPressed: () => Navigator.of(
                                                    ctx,
                                                  ).pop(e.key),
                                                  child: Text(e.value),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      );
                                      if (chosen != null) {
                                        await ref
                                            .read(appDatabaseProvider)
                                            .setRacialCantripOverride(
                                              characterId,
                                              chosen,
                                            );
                                      }
                                    }
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: RestType.short,
                                    child: Text('Short Rest'),
                                  ),
                                  PopupMenuItem(
                                    value: RestType.long,
                                    child: Text('Long Rest'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        resourceUsesAsync.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (e, st) => Text('Error: $e'),
                          data: (usesRows) {
                            return Column(
                              children: availableResources
                                  .where(
                                    (r) =>
                                        r.id != 'war_priest' && r.id != 'rage',
                                  )
                                  .map((resource) {
                                    final maxUses = resource.maxUses(
                                      widget.character.level,
                                    );
                                    final row = usesRows
                                        .where(
                                          (r) => r.resourceId == resource.id,
                                        )
                                        .firstOrNull;
                                    final spent = row?.usesSpent ?? 0;
                                    final remaining = (maxUses - spent).clamp(
                                      0,
                                      maxUses,
                                    );
                                    return Card(
                                      child: ListTile(
                                        title: Text(resource.name),
                                        subtitle: Text(
                                          '$remaining / $maxUses remaining',
                                        ),
                                        trailing: ElevatedButton(
                                          onPressed:
                                              remaining > 0 &&
                                                  characterId != null
                                              ? () => ref
                                                    .read(appDatabaseProvider)
                                                    .useResource(
                                                      characterId,
                                                      resource.id,
                                                      maxUses,
                                                    )
                                              : null,
                                          child: const Text('Use'),
                                        ),
                                      ),
                                    );
                                  })
                                  .toList(),
                            );
                          },
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
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
