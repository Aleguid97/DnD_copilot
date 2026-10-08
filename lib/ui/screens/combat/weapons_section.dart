part of '../combat_screen.dart';

extension _WeaponsSection on _CombatScreenState {
  /// Equipped weapons: attack/damage rolls, Weapon Mastery.
  List<Widget> _buildWeaponsSection(BuildContext context, _CombatData d) {
    final characterId = d.characterId;
    final inventoryRows = d.inventoryRows;
    final stats = d.stats;
    final profBonus = d.profBonus;
    final weapons = d.weapons;
    return [
      const SizedBox(height: 24),
      Text('Equipped Weapons', style: Theme.of(context).textTheme.titleMedium),
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
          final usesGwf = stats.weaponUsesGreatWeaponFighting(w);
          final masteryProp = weaponMasteryProperty[w.id];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(w.name, style: Theme.of(context).textTheme.titleSmall),
                  Text(
                    [
                      w.damage ?? '',
                      ...w.properties,
                    ].where((s) => s.isNotEmpty).join(' • '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (usesGwf)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Great Weapon Fighting active: 1s and 2s auto-reroll',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            // Faerie Fire / Guiding Bolt on the target.
                            final markerAdvantage = characterId != null
                                ? await _targetMarkerAdvantage(characterId)
                                : false;
                            final hasAdvantage =
                                _hasAdvantageFromVex ||
                                _hasAdvantageFromStudiedAttacks ||
                                markerAdvantage ||
                                (widget.character.characterClass.id ==
                                        'barbarian' &&
                                    _isRecklessAttack);
                            final firstRoll = rollAttack(info.attackBonus);
                            DiceRollResult result = firstRoll;
                            String advantageNote = '';
                            if (hasAdvantage) {
                              final secondRoll = rollAttack(info.attackBonus);
                              if (secondRoll.total > firstRoll.total) {
                                result = secondRoll;
                              }
                              advantageNote =
                                  ' (Advantage: ${firstRoll.rolls.first}/${secondRoll.rolls.first})';
                            }

                            String ammoNote = '';
                            if (w.ammunitionItemId != null &&
                                characterId != null) {
                              final ammoRow = inventoryRows
                                  .where((r) => r.itemId == w.ammunitionItemId)
                                  .firstOrNull;
                              if (ammoRow != null && ammoRow.quantity > 0) {
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
                            final isNat20 = result.rolls.first == 20;
                            if (characterId != null &&
                                _selectedEnemyId != null) {
                              final enemies =
                                  ref
                                      .read(combatEnemiesProvider(characterId))
                                      .value ??
                                  [];
                              final target = enemies
                                  .where((e) => e.id == _selectedEnemyId)
                                  .firstOrNull;
                              if (target != null) {
                                final didHit =
                                    isNat20 ||
                                    result.total >= target.armorClass;
                                hitNote = didHit
                                    ? (isNat20 ? ' — CRITICAL HIT!' : ' — HIT!')
                                    : ' — MISS';
                                _update(() => _lastAttackHit = didHit);
                                _update(
                                  () => _lastAttackWasCritical =
                                      isNat20 && didHit,
                                );
                                if (isNat20) {
                                  hitNote = ' — CRITICAL HIT (natural 20)!';
                                }
                                if (didHit && masteryProp == 'Vex') {
                                  _update(() => _hasAdvantageFromVex = true);
                                  masteryNote =
                                      ' — Vex: Advantage granted on your next attack vs this target';
                                } else if (hasAdvantage) {
                                  _update(() {
                                    _hasAdvantageFromVex = false;
                                    _hasAdvantageFromStudiedAttacks = false;
                                  });
                                }
                                if (!didHit &&
                                    widget.character.characterClass.id ==
                                        'fighter' &&
                                    widget.character.level >= 13) {
                                  _update(
                                    () =>
                                        _hasAdvantageFromStudiedAttacks = true,
                                  );
                                  masteryNote +=
                                      ' — Studied Attacks: Advantage granted on your next attack vs this target';
                                }
                              }
                            } else {
                              _update(() => _lastAttackWasCritical = isNat20);
                              if (isNat20) {
                                hitNote = ' — CRITICAL HIT (natural 20)!';
                              }
                              if (masteryProp == 'Vex') {
                                _update(() => _hasAdvantageFromVex = true);
                                masteryNote =
                                    ' — Vex: Advantage granted on your next attack vs this target';
                              } else if (hasAdvantage) {
                                _update(() => _hasAdvantageFromVex = false);
                              }
                            }

                            _update(() {
                              _lastRollResult =
                                  '${w.name} — Attack roll: ${result.rolls.first} $attackText = ${result.total}$hitNote$advantageNote$ammoNote$masteryNote';
                              _lastAttackRollForCorrection = result.total;
                            });
                          },
                          child: Text('Roll to Hit ($attackText)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: !_lastAttackHit
                              ? null
                              : () async {
                                  final isCrit = _lastAttackWasCritical;
                                  DiceRollResult rollBase() => usesGwf
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
                                  var baseResult = rollBase();
                                  // Savage Attacker: roll the weapon's damage
                                  // dice twice and use either roll (the higher).
                                  var savageNote = '';
                                  if (_savageAttackerArmed) {
                                    final second = rollBase();
                                    final keptSecond =
                                        second.total > baseResult.total;
                                    savageNote =
                                        ' [Savage Attacker: ${baseResult.total} / ${second.total}, kept ${keptSecond ? second.total : baseResult.total}]';
                                    if (keptSecond) baseResult = second;
                                  }

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

                                  if (widget.character.characterClass.id ==
                                      'cleric') {
                                    final blessedChoice = widget
                                        .character
                                        .classSelections['cleric_blessed_strikes']
                                        ?.firstOrNull;
                                    // Divine Strike: once on each of your
                                    // turns (tracked while in combat).
                                    if (blessedChoice == 'divine_strike' &&
                                        !_divineStrikeUsed) {
                                      if (_round > 0) _divineStrikeUsed = true;
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

                                  if (widget.character.characterClass.id ==
                                          'barbarian' &&
                                      _isRaging) {
                                    final bonus = rageDamageBonus(
                                      widget.character.level,
                                    );
                                    parts.add('+$bonus (Rage)');
                                    grandTotal += bonus;

                                    final subclass = widget
                                        .character
                                        .classSelections['barbarian_subclass']
                                        ?.firstOrNull;
                                    if (subclass == 'berserker') {
                                      final extra = rollDamage(
                                        frenzyExtraDice(widget.character.level),
                                        0,
                                        isCritical: isCrit,
                                      );
                                      parts.add('+${extra.total} (Frenzy)');
                                      grandTotal += extra.total;
                                    }
                                    if (subclass == 'zealot') {
                                      final extra = rollDamage(
                                        divineFuryExtraDice(),
                                        divineFuryFlatBonus(
                                          widget.character.level,
                                        ),
                                        isCritical: isCrit,
                                      );
                                      parts.add(
                                        '+${extra.total} (Divine Fury)',
                                      );
                                      grandTotal += extra.total;
                                    }
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
                                        .where((e) => e.id == _selectedEnemyId)
                                        .firstOrNull;
                                    if (target != null) {
                                      final newHp =
                                          (target.currentHp - grandTotal).clamp(
                                            0,
                                            target.maxHp,
                                          );
                                      if (newHp <= 0) {
                                        await ref
                                            .read(appDatabaseProvider)
                                            .removeEnemy(target.id);
                                        targetNote =
                                            ' — ${target.name} defeated!';
                                        _update(() => _selectedEnemyId = null);
                                      } else {
                                        await ref
                                            .read(appDatabaseProvider)
                                            .updateEnemyHp(target.id, newHp);
                                        targetNote =
                                            ' — ${target.name}: $newHp/${target.maxHp} HP left';
                                      }
                                    }
                                  }

                                  _update(() {
                                    _lastRollResult =
                                        '${w.name} — Damage: ${parts.join(' ')} = $grandTotal ${info.damageType}$savageNote$targetNote';
                                    _lastAttackWasCritical = false;
                                    _savageAttackerArmed = false;
                                  });
                                },

                          child: Text('Roll Damage (${info.damageDice})'),
                        ),
                      ),
                    ],
                  ),
                  Builder(
                    builder: (context) {
                      if (masteryProp == null || masteryProp == 'Vex') {
                        return const SizedBox.shrink();
                      }

                      Future<CombatEnemy?> currentTarget() async {
                        if (characterId == null || _selectedEnemyId == null) {
                          return null;
                        }
                        final enemies =
                            ref
                                .read(combatEnemiesProvider(characterId))
                                .value ??
                            [];
                        return enemies
                            .where((e) => e.id == _selectedEnemyId)
                            .firstOrNull;
                      }

                      Future<void> applyCondition(String label) async {
                        final target = await currentTarget();
                        if (target == null) {
                          _update(
                            () => _lastRollResult =
                                '$masteryProp: no target selected.',
                          );
                          return;
                        }
                        final current = target.conditionsJson;
                        final list = (jsonDecode(current) as List)
                            .cast<String>();
                        if (!list.contains(label)) {
                          list.add(label);
                        }
                        await ref
                            .read(appDatabaseProvider)
                            .updateEnemyConditions(target.id, list);
                        _update(
                          () => _lastRollResult =
                              '${target.name}: $label applied.',
                        );
                      }

                      switch (masteryProp) {
                        case 'Graze':
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  String targetNote = '';
                                  final target = await currentTarget();
                                  if (target != null) {
                                    final newHp =
                                        (target.currentHp - info.damageModifier)
                                            .clamp(0, target.maxHp);
                                    if (newHp <= 0) {
                                      await ref
                                          .read(appDatabaseProvider)
                                          .removeEnemy(target.id);
                                      targetNote =
                                          ' — ${target.name} defeated!';
                                      _update(() => _selectedEnemyId = null);
                                    } else {
                                      await ref
                                          .read(appDatabaseProvider)
                                          .updateEnemyHp(target.id, newHp);
                                      targetNote =
                                          ' — ${target.name}: $newHp/${target.maxHp} HP left';
                                    }
                                  }
                                  _update(() {
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
                            padding: const EdgeInsets.only(top: 8),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => applyCondition(
                                  'Pushed 10 ft (Large or smaller)',
                                ),
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text('Push target 10 ft (on hit)'),
                              ),
                            ),
                          );

                        case 'Sap':
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => applyCondition(
                                  'Disadvantage on next attack',
                                ),
                                icon: const Icon(Icons.trending_down),
                                label: const Text(
                                  'Sap: target has Disadvantage (on hit)',
                                ),
                              ),
                            ),
                          );

                        case 'Slow':
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final target = await currentTarget();
                                  if (target == null) {
                                    _update(
                                      () => _lastRollResult =
                                          'Slow: no target selected.',
                                    );
                                    return;
                                  }
                                  final reducedSpeed = (target.speed - 10)
                                      .clamp(0, 999);
                                  await ref
                                      .read(appDatabaseProvider)
                                      .updateEnemySpeed(
                                        target.id,
                                        reducedSpeed,
                                      );
                                  await applyCondition('Slowed (-10 ft Speed)');
                                },
                                icon: const Icon(Icons.slow_motion_video),
                                label: const Text(
                                  'Slow: reduce Speed by 10 ft (on hit)',
                                ),
                              ),
                            ),
                          );

                        case 'Topple':
                          final dc = 8 + info.damageModifier + profBonus;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Topple: target makes a Constitution save (DC $dc) or falls Prone.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () => applyCondition('Prone'),
                                    icon: const Icon(Icons.arrow_downward),
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
                            padding: const EdgeInsets.only(top: 8),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  if (characterId == null) return;
                                  final enemies =
                                      ref
                                          .read(
                                            combatEnemiesProvider(characterId),
                                          )
                                          .value ??
                                      [];
                                  final others = enemies
                                      .where((e) => e.id != _selectedEnemyId)
                                      .toList();
                                  if (others.isEmpty) {
                                    _update(
                                      () => _lastRollResult =
                                          'Cleave: no second target available.',
                                    );
                                    return;
                                  }
                                  final secondTarget =
                                      await showDialog<CombatEnemy>(
                                        context: context,
                                        builder: (ctx) => SimpleDialog(
                                          title: const Text(
                                            'Choose second target (Cleave)',
                                          ),
                                          children: others
                                              .map(
                                                (e) => SimpleDialogOption(
                                                  onPressed: () =>
                                                      Navigator.of(ctx).pop(e),
                                                  child: Text(
                                                    '${e.name} (${e.currentHp}/${e.maxHp} HP)',
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      );
                                  if (secondTarget == null) {
                                    return;
                                  }
                                  final cleaveModifier = info.damageModifier < 0
                                      ? info.damageModifier
                                      : 0;
                                  final result = rollDamage(
                                    info.damageDice,
                                    cleaveModifier,
                                  );
                                  final newHp =
                                      (secondTarget.currentHp - result.total)
                                          .clamp(0, secondTarget.maxHp);
                                  if (newHp <= 0) {
                                    await ref
                                        .read(appDatabaseProvider)
                                        .removeEnemy(secondTarget.id);
                                    _update(
                                      () => _lastRollResult =
                                          'Cleave — ${secondTarget.name}: ${result.total} damage, defeated!',
                                    );
                                  } else {
                                    await ref
                                        .read(appDatabaseProvider)
                                        .updateEnemyHp(secondTarget.id, newHp);
                                    _update(
                                      () => _lastRollResult =
                                          'Cleave — ${secondTarget.name}: ${result.total} damage, $newHp/${secondTarget.maxHp} HP left',
                                    );
                                  }
                                },
                                icon: const Icon(Icons.call_split),
                                label: const Text(
                                  'Cleave: attack second target (on hit)',
                                ),
                              ),
                            ),
                          );

                        case 'Nick':
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Nick: your off-hand attack can be made as part of the Attack action instead of a Bonus Action.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontStyle: FontStyle.italic),
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
                            .where((r) => r.itemId == w.ammunitionItemId)
                            .firstOrNull;
                        final ammoItem = allItems
                            .where((i) => i.id == w.ammunitionItemId)
                            .firstOrNull;
                        final remaining = ammoRow?.quantity ?? 0;
                        return Row(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 16,
                              color: remaining > 0 ? Colors.grey : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${ammoItem?.name ?? w.ammunitionItemId}: $remaining left',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: remaining > 0 ? null : Colors.red,
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
    ];
  }

  /// Unarmed Strike.
  List<Widget> _buildUnarmedStrikeSection(BuildContext context, _CombatData d) {
    final stats = d.stats;
    final profBonus = d.profBonus;
    return [
      const SizedBox(height: 24),
      Text('Unarmed Strike', style: Theme.of(context).textTheme.titleMedium),
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
                        final result = rollAttack(info.attackBonus);
                        final isNat20 = result.rolls.first == 20;
                        _update(() {
                          _lastAttackWasCritical = isNat20;
                          _lastAttackRollForCorrection = result.total;
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
                        // Tavern Brawler: a 1 on an Unarmed Strike damage die
                        // is rerolled once.
                        final tavern = widget.character.hasFeat(
                          'tavern_brawler',
                        );
                        final result = tavern
                            ? rollDamageWithReroll(
                                info.damageDice,
                                info.damageModifier,
                                rerollThreshold: 1,
                                isCritical: isCrit,
                              )
                            : rollDamage(
                                info.damageDice,
                                info.damageModifier,
                                isCritical: isCrit,
                              );
                        final modText = info.damageModifier == 0
                            ? ''
                            : ' ${info.damageModifier >= 0 ? "+" : ""}${info.damageModifier}';
                        _update(() {
                          _lastRollResult =
                              'Unarmed Strike — Damage: ${result.rolls.join('+')}$modText = ${result.total} ${info.damageType}${tavern ? " (Tavern Brawler: 1s rerolled)" : ""}';
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
          final offHandInfo = stats.offHandAttackInfo(profBonus);
          final offHandWeapon = stats.offHandWeapon;
          if (offHandInfo == null || offHandWeapon == null) {
            return const SizedBox.shrink();
          }
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
                            final result = rollAttack(offHandInfo.attackBonus);
                            _update(() {
                              _lastRollResult =
                                  'Off-Hand (${offHandWeapon.name}) — Attack roll: ${result.rolls.first} $attackText = ${result.total}';
                            });
                          },
                          child: Text('Roll to Hit ($attackText)'),
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
                            _update(() {
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
    ];
  }
}
