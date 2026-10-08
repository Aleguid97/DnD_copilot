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
                final athlete = hasRemarkableAthlete(widget.character);
                final hasAdvantage = stats.hasFeralInstinct || athlete;
                final firstRoll = rollAttack(total);
                DiceRollResult result = firstRoll;
                String advantageNote = '';
                if (hasAdvantage) {
                  final secondRoll = rollAttack(total);
                  if (secondRoll.total > firstRoll.total) {
                    result = secondRoll;
                  }
                  advantageNote =
                      ' (Advantage - ${athlete ? 'Remarkable Athlete' : 'Feral Instinct'}: ${firstRoll.rolls.first}/${secondRoll.rolls.first})';
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
                if (widget.character.characterClass.id == 'druid' &&
                    widget.character.level >= 20 &&
                    characterId != null) {
                  _evergreenWildShape(characterId, d.resourceUsesAsync);
                  advantageNote +=
                      ' — Evergreen Wild Shape: regain a use if you had none';
                }
                _update(() {
                  if (_round == 0) _round = 1;
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
                            '+ $_tempHp Temporary HP${_tempHpSource.isEmpty ? '' : ' ($_tempHpSource)'}',
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
                                    var delta = int.tryParse(
                                      _hpAdjustController.text,
                                    );
                                    if (delta == null) return;
                                    // Resistance halves the damage (round
                                    // down) before Temporary HP absorb it.
                                    final resisted =
                                        delta < 0 &&
                                        _physicalDamage &&
                                        _physicalResistance.isNotEmpty;
                                    if (resisted) delta = -((-delta) ~/ 2);
                                    if (resisted) {
                                      _showRoll(
                                        'Resistance (${_physicalResistance.join(', ')}): damage halved to ${-delta}.',
                                      );
                                    }
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
                      if (_physicalResistance.isNotEmpty)
                        CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: _physicalDamage,
                          onChanged: (v) =>
                              _update(() => _physicalDamage = v ?? false),
                          title: Text(
                            'Bludgeoning/Piercing/Slashing damage (halved: '
                            '${_physicalResistance.join(', ')})',
                          ),
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
      const SizedBox(height: 16),
      _collapsibleGroup(context, 'Saving Throws', [
        ...Ability.values.map((a) {
          final abilityName = _abilityFullName(a);
          final isProficient = widget.character.characterClass.savingThrows
              .contains(abilityName);
          // Improved Circle Forms (Moon 6): + Wisdom modifier to Con saves in
          // Wild Shape.
          final moonConBonus =
              a == Ability.constitution &&
                  _wildShapeActive &&
                  druidSubclass(widget.character) == 'moon' &&
                  widget.character.level >= 6
              ? druidWisdomModifier(widget.character)
              : 0;
          final bonus = saves[a]! + moonConBonus;
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
      ]),
    ];
  }

  /// Skill check rolls.
  List<Widget> _buildSkillChecks(BuildContext context, _CombatData d) {
    final profBonus = d.profBonus;
    return [
      _collapsibleGroup(context, 'Skill Checks', [
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
                // Primal Order — Magician: + Wisdom modifier (min 1) to
                // Intelligence (Arcana or Nature).
                final magicianBonus =
                    druidIsMagician(widget.character) &&
                        (skill == 'Arcana' || skill == 'Nature')
                    ? magicianLoreBonus(widget.character)
                    : 0;
                // Divine Order — Thaumaturge: + Wisdom modifier (min 1) to
                // Intelligence (Arcana or Religion).
                final thaumaturgeBonus =
                    clericIsThaumaturge(widget.character) &&
                        (skill == 'Arcana' || skill == 'Religion')
                    ? wisdomModifier(widget.character).clamp(1, 20)
                    : 0;
                final bonus =
                    abilityMod +
                    (isProficient ? profBonus : 0) +
                    magicianBonus +
                    thaumaturgeBonus;
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
                        // Remarkable Athlete (Champion): Advantage on
                        // Strength (Athletics) checks.
                        final advantage =
                            skill == 'Athletics' &&
                            hasRemarkableAthlete(widget.character);
                        final first = rollAttack(bonus);
                        var result = first;
                        var advNote = '';
                        if (advantage) {
                          final second = rollAttack(bonus);
                          if (second.total > first.total) result = second;
                          advNote =
                              ' (Advantage - Remarkable Athlete: ${first.rolls.first}/${second.rolls.first})';
                        }
                        _update(() {
                          _lastRollResult =
                              '$skill: ${result.rolls.first} $bonusText = ${result.total}$advNote';
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
      ]),
    ];
  }

  /// Collapsed-by-default group, so long lists don't push the useful
  /// sections down. The open/closed state survives rebuilds.
  Widget _collapsibleGroup(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        key: PageStorageKey('combat_group_$title'),
        initiallyExpanded: true,
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        shape: const Border(),
        collapsedShape: const Border(),
        childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        children: children,
      ),
    );
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

  /// Active sources of Resistance to Bludgeoning, Piercing and Slashing.
  List<String> get _physicalResistance {
    final c = widget.character;
    final subclass = c.classSelections['${c.characterClass.id}_subclass'];
    return [
      if (_isRaging) 'Rage',
      if (c.characterClass.id == 'cleric' &&
          (subclass?.contains('war') ?? false) &&
          c.level >= 17)
        'Avatar of Battle',
      if (c.characterClass.id == 'druid' &&
          (subclass?.contains('stars') ?? false) &&
          c.level >= 14 &&
          _starryConstellation != null)
        'Full of Stars',
    ];
  }
}
