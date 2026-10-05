part of '../combat_screen.dart';

extension _CoreSections on _CombatScreenState {
  /// AC, Initiative, max HP and Speed.
  List<Widget> _buildTopStats(BuildContext context, _CombatData d) {
    final characterId = d.characterId;
    final equippedItems = d.equippedItems;
    final stats = d.stats;
    final profBonus = d.profBonus;
    final ac = d.ac;
    return [
      Row(
        children: [
          Expanded(
            child: _StatBox(label: 'Armor Class', value: '${ac.value}'),
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
                final hasAdvantage = stats.hasFeralInstinct;
                final firstRoll = rollAttack(total);
                DiceRollResult result = firstRoll;
                String advantageNote = '';
                if (hasAdvantage) {
                  final secondRoll = rollAttack(total);
                  if (secondRoll.total > firstRoll.total) {
                    result = secondRoll;
                  }
                  advantageNote =
                      ' (Advantage - Feral Instinct: ${firstRoll.rolls.first}/${secondRoll.rolls.first})';
                }
                if (widget.character.characterClass.id == 'barbarian' &&
                    widget.character.level >= 15 &&
                    characterId != null) {
                  final rageResource = (classResources['barbarian'] ?? [])
                      .firstWhere((r) => r.id == 'rage');
                  final maxUses = rageResource.maxUses(widget.character.level);
                  ref.read(appDatabaseProvider).applyRest(
                    characterId,
                    RestType.long,
                    [rageResource],
                  );
                  advantageNote +=
                      ' — Persistent Rage: Rage uses restored to $maxUses';
                }
                _update(() {
                  _lastRollResult =
                      'Initiative: ${result.rolls.first} ${total >= 0 ? "+$total" : total} = ${result.total}$advantageNote';
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
          final fastMovementBonus =
              widget.character.characterClass.id == 'barbarian' &&
                  widget.character.level >= 5 &&
                  equippedItems.every(
                    (i) => i.category != ItemCategory.heavyArmor,
                  )
              ? 10
              : 0;
          final baseSpeed = widget.character.race.speed + fastMovementBonus;
          final currentSpeed = _speedOverride ?? baseSpeed;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Speed',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        '$currentSpeed ft${currentSpeed != baseSpeed ? " (base $baseSpeed ft)" : ""}${fastMovementBonus > 0 ? " — includes Fast Movement" : ""}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _update(
                          () =>
                              _speedOverride = (currentSpeed - 5).clamp(0, 999),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () =>
                            _update(() => _speedOverride = currentSpeed + 5),
                      ),
                      if (_speedOverride != null)
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Reset to base',
                          onPressed: () => _update(() => _speedOverride = null),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ];
  }

  /// Current HP tracking, damage/heal and potions.
  List<Widget> _buildHpCard(BuildContext context, _CombatData d) {
    final characterId = d.characterId;
    final inventoryRows = d.inventoryRows;
    return [
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
              final currentHp = (storedHp ?? maxHp).clamp(0, maxHp);
              final potionRow = inventoryRows
                  .where(
                    (r) => r.itemId == 'potion_of_healing' && r.quantity > 0,
                  )
                  .firstOrNull;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Current HP',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            '$currentHp / $maxHp',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: currentHp <= maxHp ~/ 2
                                      ? Colors.red
                                      : Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      if (_tempHp > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '+ $_tempHp Temporary HP (Vitality Surge)',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
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
                                labelText: 'Amount (+heal / -damage)',
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
                                    if (delta < 0 && _tempHp > 0) {
                                      final absorbed = (-delta).clamp(
                                        0,
                                        _tempHp,
                                      );
                                      _update(() => _tempHp -= absorbed);
                                      final remaining = delta + absorbed;
                                      if (remaining < 0) {
                                        final newHp = (currentHp + remaining)
                                            .clamp(0, maxHp);
                                        await ref
                                            .read(appDatabaseProvider)
                                            .setCurrentHp(characterId, newHp);
                                      }
                                    } else {
                                      final newHp = (currentHp + delta).clamp(
                                        0,
                                        maxHp,
                                      );
                                      await ref
                                          .read(appDatabaseProvider)
                                          .setCurrentHp(characterId, newHp);
                                    }
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
                                      final healResult = rollDamage('2d4', 2);
                                      final newHp =
                                          (currentHp + healResult.total).clamp(
                                            0,
                                            maxHp,
                                          );
                                      await ref
                                          .read(appDatabaseProvider)
                                          .setCurrentHp(characterId, newHp);
                                      await ref
                                          .read(appDatabaseProvider)
                                          .setInventoryQuantity(
                                            potionRow.id,
                                            potionRow.quantity - 1,
                                          );
                                      _update(() {
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
    ];
  }

  /// Free-form dice roller.
  List<Widget> _buildQuickDice(BuildContext context, _CombatData d) {
    return [
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
                          (s) => DropdownMenuItem(value: s, child: Text('$s')),
                        )
                        .toList(),
                    onChanged: (v) => _update(() => _diceSides = v ?? 20),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final count =
                          int.tryParse(_diceCountController.text) ?? 1;
                      final result = rollDamage('${count}d$_diceSides', 0);
                      _update(() {
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
    ];
  }

  /// Saving throw rolls.
  List<Widget> _buildSavingThrows(BuildContext context, _CombatData d) {
    final stats = d.stats;
    final saves = d.saves;
    return [
      const SizedBox(height: 24),
      Text('Saving Throws', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      ...Ability.values.map((a) {
        final abilityName = _abilityFullName(a);
        final isProficient = widget.character.characterClass.savingThrows
            .contains(abilityName);
        final bonus = saves[a]!;
        final bonusText = bonus >= 0 ? '+$bonus' : '$bonus';
        return Card(
          child: ListTile(
            leading: Icon(
              isProficient ? Icons.check_circle : Icons.circle_outlined,
              color: isProficient
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
            title: Text('${_abilityShort(a)} Save'),

            trailing: OutlinedButton(
              onPressed: () {
                final hasAdvantage =
                    stats.hasDangerSense && a == Ability.dexterity;
                final firstRoll = rollAttack(bonus);
                DiceRollResult result = firstRoll;
                String advantageNote = '';
                if (hasAdvantage) {
                  final secondRoll = rollAttack(bonus);
                  if (secondRoll.total > firstRoll.total) {
                    result = secondRoll;
                  }
                  advantageNote =
                      ' (Advantage - Danger Sense: ${firstRoll.rolls.first}/${secondRoll.rolls.first})';
                }
                _update(() {
                  _lastRollResult =
                      '${_abilityShort(a)} Save: ${result.rolls.first} $bonusText = ${result.total}$advantageNote';
                  _lastSaveModifier = bonus;
                  _lastSaveAbilityShort = _abilityShort(a);
                });
              },
              child: Text('Roll ($bonusText)'),
            ),
          ),
        );
      }),
    ];
  }

  /// Skill check rolls.
  List<Widget> _buildSkillChecks(BuildContext context, _CombatData d) {
    final profBonus = d.profBonus;
    return [
      const SizedBox(height: 24),
      Text('Skill Checks', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Builder(
        builder: (context) {
          final proficient = proficientSkills(widget.character);
          final sortedSkills = allSkillNames.toList()..sort();
          return Column(
            children: sortedSkills.map((skill) {
              final ability = skillAbilityMap[skill]!;
              final abilityMod = widget.character.abilityScores.modifierFor(
                ability,
                bonuses: widget.character.totalAbilityBonuses,
              );
              final isProficient = proficient.contains(skill);
              final bonus = abilityMod + (isProficient ? profBonus : 0);
              final bonusText = bonus >= 0 ? '+$bonus' : '$bonus';
              return Card(
                child: ListTile(
                  leading: Icon(
                    isProficient ? Icons.check_circle : Icons.circle_outlined,
                    color: isProficient
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                  title: Text(skill),
                  trailing: OutlinedButton(
                    onPressed: () {
                      final result = rollAttack(bonus);
                      _update(() {
                        _lastRollResult =
                            '$skill: ${result.rolls.first} $bonusText = ${result.total}';
                        _lastSkillRollForCorrection = result.total;
                        _lastSkillRolledName = skill;
                      });
                    },
                    child: Text('Roll ($bonusText)'),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    ];
  }

  /// Enemy target dropdown.
  List<Widget> _buildTargetSelector(BuildContext context, _CombatData d) {
    final characterId = d.characterId;
    return [
      const SizedBox(height: 24),
      Builder(
        builder: (context) {
          if (characterId == null) return const SizedBox.shrink();
          final enemiesAsync = ref.watch(combatEnemiesProvider(characterId));
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
                        onChanged: (v) => _update(() {
                          _selectedEnemyId = v;
                          _hasAdvantageFromVex = false;
                        }),
                      ),
                      if (_hasAdvantageFromVex)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Chip(label: Text('Advantage active (Vex)')),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    ];
  }
}
