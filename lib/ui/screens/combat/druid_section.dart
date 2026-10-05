part of '../combat_screen.dart';

/// Druid resources rendered by the Druid section instead of the generic
/// Class Resources tracker.
const druidSectionResourceIds = {
  'wild_shape',
  'wild_resurgence_slot',
  'nature_magician',
  'natural_recovery_spell',
  'natural_recovery_slots',
  'moonlight_step',
  'star_map_guiding_bolt',
  'cosmic_omen',
};

const _primalStrikeTypes = ['Cold', 'Fire', 'Lightning', 'Thunder'];

extension _DruidSection on _CombatScreenState {
  /// Druid features: spell slots, Wild Shape, Elemental Fury and circles.
  List<Widget> _buildDruidSection(BuildContext context, _CombatData d) {
    final characterId = d.characterId;
    if (widget.character.characterClass.id != 'druid' || characterId == null) {
      return const [];
    }
    final level = widget.character.level;
    final subclass = druidSubclass(widget.character);
    return [
      const SizedBox(height: 24),
      Text('Druid Features', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      d.resourceUsesAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (e, st) => Text('Error: $e'),
        data: (rows) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (level >= 2) _wildShapeCard(context, characterId, rows),
            if (level >= 7) _elementalFuryCard(context, characterId, d),
            if (level >= 3 && subclass == null)
              _featureCard(
                context,
                'Druid Circle',
                'Choose your Druid Circle in Level Up to unlock its features.',
                const [],
              ),
            if (level >= 3 && subclass == 'land')
              ..._circleOfTheLandCards(context, characterId, rows, d),
            if (level >= 3 && subclass == 'moon')
              ..._circleOfTheMoonCards(context, characterId, rows, d),
            if (level >= 3 && subclass == 'sea')
              ..._circleOfTheSeaCards(context, characterId, rows, d),
            if (level >= 3 && subclass == 'stars')
              ..._circleOfTheStarsCards(context, characterId, rows, d),
          ],
        ),
      ),
    ];
  }

  // ----------------------------------------------------------------- helpers

  int get _wildShapeMax => wildShapeUses(widget.character.level);

  Future<void> _spendWildShape(int characterId) =>
      _spendResource(characterId, 'wild_shape', _wildShapeMax);

  /// Archdruid — Evergreen Wild Shape, called when Initiative is rolled.
  void _evergreenWildShape(
    int characterId,
    AsyncValue<List<CharacterResourceUse>> usesAsync,
  ) {
    final rows = usesAsync.value ?? const <CharacterResourceUse>[];
    if (_resourceRemaining(rows, 'wild_shape', _wildShapeMax) == 0) {
      _regainResource(characterId, 'wild_shape');
    }
  }

  // -------------------------------------------------------------- Wild Shape

  Widget _wildShapeCard(
    BuildContext context,
    int characterId,
    List<CharacterResourceUse> rows,
  ) {
    final level = widget.character.level;
    final isMoon = druidSubclass(widget.character) == 'moon';
    final remaining = _resourceRemaining(rows, 'wild_shape', _wildShapeMax);
    final limits = beastShapeLimits(level, circleOfTheMoon: isMoon);
    final tempHp = wildShapeTempHp(level, circleOfTheMoon: isMoon);
    final hours = level ~/ 2;
    final resurgenceLeft = _resourceRemaining(rows, 'wild_resurgence_slot', 1);
    final natureMagicianLeft = _resourceRemaining(rows, 'nature_magician', 1);

    final details = [
      '$remaining/$_wildShapeMax uses · ${limits.knownForms} known forms · '
          'max CR ${limits.maxCr} · Fly Speed ${limits.flySpeed ? "allowed" : "no"} · '
          'lasts $hours h · $tempHp Temp HP',
      if (isMoon && level >= 3)
        'Circle Forms: AC ${circleFormsArmorClass(widget.character)} if higher than the Beast\'s',
      if (isMoon && level >= 6)
        'Improved Circle Forms: Radiant attacks; +${druidWisdomModifier(widget.character)} to Con saves (applied above while shifted)',
      if (level >= 18) 'Beast Spells: you can cast spells while shifted',
      if (_wildShapeActive) 'Currently in Wild Shape.',
    ].join('\n');

    return _featureCard(context, 'Wild Shape', details, [
      if (!_wildShapeActive)
        ElevatedButton(
          onPressed: remaining > 0
              ? () async {
                  await _spendWildShape(characterId);
                  _update(() {
                    _wildShapeActive = true;
                    if (tempHp > _tempHp) {
                      _tempHp = tempHp;
                      _tempHpSource = 'Wild Shape';
                    }
                    _lastRollResult =
                        'Wild Shape: shape-shifted for up to $hours h, $tempHp Temporary HP.';
                  });
                }
              : null,
          child: const Text('Shape-shift (spend use)'),
        )
      else
        ElevatedButton(
          onPressed: () => _update(() {
            _wildShapeActive = false;
            _lastRollResult = 'Wild Shape ended.';
          }),
          child: const Text('Leave form'),
        ),
      OutlinedButton(
        onPressed: remaining > 0
            ? () async {
                await _spendWildShape(characterId);
                _showRoll(
                  'Wild Companion: Find Familiar cast with a Wild Shape use (Fey familiar until your next Long Rest).',
                );
              }
            : null,
        child: const Text('Wild Companion (use)'),
      ),
      OutlinedButton(
        onPressed: () async {
          final slot = await _pickSlotLevel(context, rows);
          if (slot == null) return;
          await _spendSlot(characterId, slot);
          _showRoll(
            'Wild Companion: Find Familiar cast with a level $slot slot.',
          );
        },
        child: const Text('Wild Companion (slot)'),
      ),
      if (level >= 5) ...[
        OutlinedButton(
          onPressed: remaining == 0
              ? () async {
                  final slot = await _pickSlotLevel(
                    context,
                    rows,
                    title: 'Wild Resurgence: expend which slot?',
                  );
                  if (slot == null) return;
                  await _spendSlot(characterId, slot);
                  await _regainResource(characterId, 'wild_shape');
                  _showRoll(
                    'Wild Resurgence: expended a level $slot slot, regained 1 Wild Shape use (once per turn).',
                  );
                }
              : null,
          child: const Text('Resurgence: slot → use'),
        ),
        OutlinedButton(
          onPressed:
              remaining > 0 &&
                  resurgenceLeft > 0 &&
                  _slotRemaining(rows, 1) < _slotMax(1)
              ? () async {
                  await _spendWildShape(characterId);
                  await _spendResource(characterId, 'wild_resurgence_slot', 1);
                  await _regainResource(characterId, spellSlotResourceId(1));
                  _showRoll(
                    'Wild Resurgence: spent a Wild Shape use, regained a level 1 slot (once per Long Rest).',
                  );
                }
              : null,
          child: Text('Resurgence: use → L1 slot ($resurgenceLeft/1)'),
        ),
      ],
      if (level >= 20)
        OutlinedButton(
          onPressed: remaining > 0 && natureMagicianLeft > 0
              ? () async {
                  final maxConvert = remaining.clamp(1, 4);
                  final uses = await showDialog<int>(
                    context: context,
                    builder: (ctx) => SimpleDialog(
                      title: const Text(
                        'Nature Magician: convert how many uses?',
                      ),
                      children: [
                        for (var n = 1; n <= maxConvert; n++)
                          SimpleDialogOption(
                            onPressed: () => Navigator.of(ctx).pop(n),
                            child: Text(
                              '$n use${n > 1 ? "s" : ""} → level ${2 * n} slot',
                            ),
                          ),
                      ],
                    ),
                  );
                  if (uses == null) return;
                  for (var i = 0; i < uses; i++) {
                    await _spendWildShape(characterId);
                  }
                  await _spendResource(characterId, 'nature_magician', 1);
                  final slotLevel = 2 * uses;
                  final hadSpent =
                      _slotRemaining(rows, slotLevel) < _slotMax(slotLevel);
                  await _regainResource(
                    characterId,
                    spellSlotResourceId(slotLevel),
                  );
                  _showRoll(
                    'Nature Magician: $uses Wild Shape use(s) → a level $slotLevel spell slot'
                    '${hadSpent ? "" : " (all level $slotLevel slots were full: track the extra slot yourself)"}.',
                  );
                }
              : null,
          child: Text('Nature Magician ($natureMagicianLeft/1)'),
        ),
    ]);
  }

  // ---------------------------------------------------------- Elemental Fury

  Widget _elementalFuryCard(
    BuildContext context,
    int characterId,
    _CombatData d,
  ) {
    final level = widget.character.level;
    final wis = druidWisdomModifier(widget.character);
    switch (druidElementalFury(widget.character)) {
      case 'primal_strike':
        final dice = primalStrikeDice(level);
        return _featureCard(
          context,
          'Elemental Fury: Primal Strike',
          'Once per turn on a weapon or Beast-form hit: extra $dice damage.',
          [
            DropdownButton<String>(
              value: _primalStrikeType,
              items: [
                for (final t in _primalStrikeTypes)
                  DropdownMenuItem(value: t, child: Text(t)),
              ],
              onChanged: (v) => _update(() => _primalStrikeType = v ?? 'Fire'),
            ),
            OutlinedButton(
              onPressed: () {
                final r = rollDamage(
                  dice,
                  0,
                  isCritical: _lastAttackWasCritical,
                );
                _showRoll(
                  'Primal Strike ($_primalStrikeType): ${r.rolls.join('+')} = ${r.total}',
                );
              },
              child: Text('Roll $dice'),
            ),
            OutlinedButton(
              onPressed: _selectedEnemyId == null
                  ? null
                  : () async {
                      final r = rollDamage(
                        dice,
                        0,
                        isCritical: _lastAttackWasCritical,
                      );
                      final note = await _damageSelectedEnemy(
                        characterId,
                        r.total,
                      );
                      _showRoll(
                        'Primal Strike ($_primalStrikeType): ${r.rolls.join('+')} = ${r.total}$note',
                      );
                    },
              child: const Text('Roll & damage target'),
            ),
          ],
        );
      case 'potent_spellcasting':
        return _featureCard(
          context,
          'Elemental Fury: Potent Spellcasting',
          'Add +$wis to the damage of your Druid cantrips.'
              '${level >= 15 ? " Cantrips with range 10 ft+ gain +300 ft range." : ""}',
          const [],
        );
      default:
        return _featureCard(
          context,
          'Elemental Fury',
          'Choose Potent Spellcasting or Primal Strike in Level Up.',
          const [],
        );
    }
  }

  // ------------------------------------------------------- Circle of the Land

  List<Widget> _circleOfTheLandCards(
    BuildContext context,
    int characterId,
    List<CharacterResourceUse> rows,
    _CombatData d,
  ) {
    final level = widget.character.level;
    final land = druidLandType(widget.character);
    final wildShapeLeft = _resourceRemaining(rows, 'wild_shape', _wildShapeMax);
    final dc = druidSpellSaveDc(widget.character, d.profBonus);
    final dice = landsAidDice(level);
    final spellLeft = _resourceRemaining(rows, 'natural_recovery_spell', 1);
    final slotsLeft = _resourceRemaining(rows, 'natural_recovery_slots', 1);
    return [
      _featureCard(
        context,
        'Circle Spells (${landTypeNames[land] ?? "choose a land type in Level Up"})',
        druidCircleSpells(widget.character).join(', '),
        const [],
      ),
      _featureCard(
        context,
        'Land\'s Aid',
        'Spend a Wild Shape use: 10-ft Sphere, Con save DC $dc or $dice Necrotic '
            '(half on success); one creature regains $dice HP.'
            '${_landsAidDamage != null ? "\nLast roll: $_landsAidDamage damage, $_landsAidHeal healing." : ""}',
        [
          ElevatedButton(
            onPressed: wildShapeLeft > 0
                ? () async {
                    await _spendWildShape(characterId);
                    final dmg = rollDamage(dice, 0);
                    final heal = rollDamage(dice, 0);
                    _update(() {
                      _landsAidDamage = dmg.total;
                      _landsAidHeal = heal.total;
                      _lastRollResult =
                          'Land\'s Aid: ${dmg.rolls.join('+')} = ${dmg.total} Necrotic (DC $dc Con, half on success); '
                          'heal ${heal.rolls.join('+')} = ${heal.total}';
                    });
                  }
                : null,
            child: const Text('Use (spend Wild Shape)'),
          ),
          if (_landsAidDamage != null) ...[
            OutlinedButton(
              onPressed: _selectedEnemyId == null
                  ? null
                  : () async {
                      final note = await _damageSelectedEnemy(
                        characterId,
                        _landsAidDamage!,
                      );
                      _showRoll(
                        'Land\'s Aid: target failed save, $_landsAidDamage damage$note',
                      );
                    },
              child: const Text('Target failed save'),
            ),
            OutlinedButton(
              onPressed: _selectedEnemyId == null
                  ? null
                  : () async {
                      final half = _landsAidDamage! ~/ 2;
                      final note = await _damageSelectedEnemy(
                        characterId,
                        half,
                      );
                      _showRoll('Land\'s Aid: target saved, $half damage$note');
                    },
              child: const Text('Target saved (half)'),
            ),
            OutlinedButton(
              onPressed: () async {
                final note = await _healSelf(characterId, _landsAidHeal!);
                _update(() {
                  _lastRollResult =
                      'Land\'s Aid: you regain $_landsAidHeal HP$note';
                  _landsAidHeal = 0;
                });
              },
              child: const Text('Heal myself'),
            ),
          ],
        ],
      ),
      if (level >= 6)
        _featureCard(
          context,
          'Natural Recovery',
          'Cast a level 1+ Circle spell without a slot ($spellLeft/1). '
              'On a Short Rest recover slots totalling up to ${naturalRecoveryBudget(level)} levels, none 6+ ($slotsLeft/1).',
          [
            OutlinedButton(
              onPressed: spellLeft > 0
                  ? () async {
                      await _spendResource(
                        characterId,
                        'natural_recovery_spell',
                        1,
                      );
                      _showRoll(
                        'Natural Recovery: Circle spell cast without a slot.',
                      );
                    }
                  : null,
              child: const Text('Free Circle spell'),
            ),
            OutlinedButton(
              onPressed: slotsLeft > 0
                  ? () => _naturalRecoveryDialog(context, characterId, rows)
                  : null,
              child: const Text('Recover slots'),
            ),
          ],
        ),
      if (level >= 10)
        _featureCard(
          context,
          'Nature\'s Ward',
          'Immune to Poisoned; Resistance to ${natureWardResistance[land] ?? "your land type's damage"}.',
          const [],
        ),
      if (level >= 14)
        _featureCard(
          context,
          'Nature\'s Sanctuary',
          '15-ft Cube for 1 minute: Half Cover for you and allies; allies gain your Nature\'s Ward Resistance.',
          [
            OutlinedButton(
              onPressed: wildShapeLeft > 0
                  ? () async {
                      await _spendWildShape(characterId);
                      _showRoll('Nature\'s Sanctuary created (1 minute).');
                    }
                  : null,
              child: const Text('Use (spend Wild Shape)'),
            ),
          ],
        ),
    ];
  }

  Future<void> _naturalRecoveryDialog(
    BuildContext context,
    int characterId,
    List<CharacterResourceUse> rows,
  ) async {
    final budget = naturalRecoveryBudget(widget.character.level);
    final picked = <int, int>{};
    final result = await showDialog<Map<int, int>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) {
          final used = picked.entries.fold(0, (a, e) => a + e.key * e.value);
          return AlertDialog(
            title: Text('Natural Recovery: $used/$budget levels'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var l = 1; l <= 5; l++)
                  if (_slotMax(l) > 0)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Level $l (${_slotMax(l) - _slotRemaining(rows, l)} spent)',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: (picked[l] ?? 0) > 0
                              ? () =>
                                    setDialog(() => picked[l] = picked[l]! - 1)
                              : null,
                        ),
                        Text('${picked[l] ?? 0}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed:
                              used + l <= budget &&
                                  (picked[l] ?? 0) <
                                      _slotMax(l) - _slotRemaining(rows, l)
                              ? () => setDialog(
                                  () => picked[l] = (picked[l] ?? 0) + 1,
                                )
                              : null,
                        ),
                      ],
                    ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: used > 0
                    ? () => Navigator.of(ctx).pop(picked)
                    : null,
                child: const Text('Recover'),
              ),
            ],
          );
        },
      ),
    );
    if (result == null) return;
    for (final e in result.entries) {
      if (e.value > 0) {
        await _regainResource(
          characterId,
          spellSlotResourceId(e.key),
          amount: e.value,
        );
      }
    }
    await _spendResource(characterId, 'natural_recovery_slots', 1);
    _showRoll(
      'Natural Recovery: recovered ${result.entries.where((e) => e.value > 0).map((e) => "${e.value}× L${e.key}").join(", ")}.',
    );
  }

  // ------------------------------------------------------- Circle of the Moon

  List<Widget> _circleOfTheMoonCards(
    BuildContext context,
    int characterId,
    List<CharacterResourceUse> rows,
    _CombatData d,
  ) {
    final level = widget.character.level;
    final stepMax = druidWisdomUses(widget.character);
    final stepLeft = _resourceRemaining(rows, 'moonlight_step', stepMax);
    return [
      _featureCard(
        context,
        'Circle of the Moon Spells',
        '${druidCircleSpells(widget.character).join(', ')} — castable in Wild Shape.',
        const [],
      ),
      if (level >= 10)
        _featureCard(
          context,
          'Moonlight Step',
          'Bonus Action: teleport up to 30 ft, Advantage on your next attack this turn'
              '${level >= 14 ? "; bring one willing creature within 10 ft" : ""}. $stepLeft/$stepMax uses.',
          [
            ElevatedButton(
              onPressed: stepLeft > 0
                  ? () async {
                      await _spendResource(
                        characterId,
                        'moonlight_step',
                        stepMax,
                      );
                      _showRoll(
                        'Moonlight Step: teleported, Advantage on your next attack this turn.',
                      );
                    }
                  : null,
              child: const Text('Use'),
            ),
            OutlinedButton(
              onPressed: stepLeft < stepMax
                  ? () async {
                      final slot = await _pickSlotLevel(
                        context,
                        rows,
                        minLevel: 2,
                        title: 'Restore Moonlight Step: expend which slot?',
                      );
                      if (slot == null) return;
                      await _spendSlot(characterId, slot);
                      await _regainResource(characterId, 'moonlight_step');
                      _showRoll(
                        'Moonlight Step: use restored with a level $slot slot.',
                      );
                    }
                  : null,
              child: const Text('Restore (level 2+ slot)'),
            ),
          ],
        ),
      if (level >= 14)
        _featureCard(
          context,
          'Lunar Form',
          'Once per turn, a Wild Shape attack deals an extra 2d10 Radiant damage.',
          [
            OutlinedButton(
              onPressed: () {
                final r = rollDamage(
                  '2d10',
                  0,
                  isCritical: _lastAttackWasCritical,
                );
                _showRoll(
                  'Improved Lunar Radiance: ${r.rolls.join('+')} = ${r.total} Radiant',
                );
              },
              child: const Text('Roll 2d10'),
            ),
            OutlinedButton(
              onPressed: _selectedEnemyId == null
                  ? null
                  : () async {
                      final r = rollDamage(
                        '2d10',
                        0,
                        isCritical: _lastAttackWasCritical,
                      );
                      final note = await _damageSelectedEnemy(
                        characterId,
                        r.total,
                      );
                      _showRoll(
                        'Improved Lunar Radiance: ${r.rolls.join('+')} = ${r.total} Radiant$note',
                      );
                    },
              child: const Text('Roll & damage target'),
            ),
          ],
        ),
    ];
  }

  // -------------------------------------------------------- Circle of the Sea

  List<Widget> _circleOfTheSeaCards(
    BuildContext context,
    int characterId,
    List<CharacterResourceUse> rows,
    _CombatData d,
  ) {
    final level = widget.character.level;
    final wildShapeLeft = _resourceRemaining(rows, 'wild_shape', _wildShapeMax);
    final dc = druidSpellSaveDc(widget.character, d.profBonus);
    final dice = wrathOfTheSeaDice(widget.character);
    final size = level >= 6 ? 10 : 5;
    return [
      _featureCard(
        context,
        'Circle of the Sea Spells',
        druidCircleSpells(widget.character).join(', '),
        const [],
      ),
      _featureCard(
        context,
        'Wrath of the Sea${_wrathOfTheSeaActive ? " (active)" : ""}',
        '$size-ft Emanation for 10 minutes. Bonus Action: one creature in it makes a Con save '
            '(DC $dc) or takes $dice Cold damage and is pushed 15 ft (Large or smaller).'
            '${level >= 6 ? "\nAquatic Affinity: Swim Speed equal to your Speed." : ""}'
            '${level >= 10 && _wrathOfTheSeaActive ? "\nStormborn: Fly Speed equal to your Speed; Resistance to Cold, Lightning, Thunder." : ""}'
            '${level >= 14 ? "\nOceanic Gift: can manifest it around an ally within 60 ft, or both of you for 2 uses." : ""}',
        [
          if (!_wrathOfTheSeaActive) ...[
            ElevatedButton(
              onPressed: wildShapeLeft > 0
                  ? () async {
                      await _spendWildShape(characterId);
                      _update(() {
                        _wrathOfTheSeaActive = true;
                        _lastRollResult =
                            'Wrath of the Sea manifested (10 minutes).';
                      });
                    }
                  : null,
              child: const Text('Manifest (spend Wild Shape)'),
            ),
            if (level >= 14)
              OutlinedButton(
                onPressed: wildShapeLeft >= 2
                    ? () async {
                        await _spendWildShape(characterId);
                        await _spendWildShape(characterId);
                        _update(() {
                          _wrathOfTheSeaActive = true;
                          _lastRollResult =
                              'Oceanic Gift: Wrath of the Sea around you and an ally (2 uses).';
                        });
                      }
                    : null,
                child: const Text('You + ally (2 uses)'),
              ),
          ] else ...[
            OutlinedButton(
              onPressed: () {
                final r = rollDamage(dice, 0);
                _showRoll(
                  'Wrath of the Sea: ${r.rolls.join('+')} = ${r.total} Cold (DC $dc Con negates)',
                );
              },
              child: Text('Roll $dice'),
            ),
            OutlinedButton(
              onPressed: _selectedEnemyId == null
                  ? null
                  : () async {
                      final r = rollDamage(dice, 0);
                      final note = await _damageSelectedEnemy(
                        characterId,
                        r.total,
                      );
                      _showRoll(
                        'Wrath of the Sea: target failed save, ${r.total} Cold, pushed 15 ft$note',
                      );
                    },
              child: const Text('Target failed save'),
            ),
            OutlinedButton(
              onPressed: () => _update(() {
                _wrathOfTheSeaActive = false;
                _lastRollResult = 'Wrath of the Sea dismissed.';
              }),
              child: const Text('Dismiss'),
            ),
          ],
        ],
      ),
    ];
  }

  // ------------------------------------------------------ Circle of the Stars

  List<Widget> _circleOfTheStarsCards(
    BuildContext context,
    int characterId,
    List<CharacterResourceUse> rows,
    _CombatData d,
  ) {
    final level = widget.character.level;
    final wis = druidWisdomModifier(widget.character);
    final wisUses = druidWisdomUses(widget.character);
    final boltLeft = _resourceRemaining(rows, 'star_map_guiding_bolt', wisUses);
    final omenLeft = _resourceRemaining(rows, 'cosmic_omen', wisUses);
    final wildShapeLeft = _resourceRemaining(rows, 'wild_shape', _wildShapeMax);
    final dice = starryFormDice(level);
    final attackBonus = druidSpellAttackBonus(widget.character, d.profBonus);

    const constellations = {
      'archer': 'Archer',
      'chalice': 'Chalice',
      'dragon': 'Dragon',
    };
    final constellationText = switch (_starryConstellation) {
      'archer' =>
        'Archer: Bonus Action ranged spell attack (+$attackBonus), $dice + $wis Radiant.',
      'chalice' =>
        'Chalice: when a slot spell restores HP, you or a creature within 30 ft regains $dice + $wis HP.',
      'dragon' =>
        'Dragon: treat d20 rolls of 9 or lower as 10 on Int/Wis checks and Concentration Con saves'
            '${level >= 10 ? "; Fly Speed 20 ft (hover)" : ""}.',
      _ => '',
    };

    return [
      _featureCard(
        context,
        'Star Map',
        'Guidance and Guiding Bolt always prepared; cast Guiding Bolt without a slot ($boltLeft/$wisUses).',
        [
          OutlinedButton(
            onPressed: boltLeft > 0
                ? () async {
                    await _spendResource(
                      characterId,
                      'star_map_guiding_bolt',
                      wisUses,
                    );
                    _showRoll(
                      'Star Map: Guiding Bolt cast without a spell slot.',
                    );
                  }
                : null,
            child: const Text('Free Guiding Bolt'),
          ),
        ],
      ),
      _featureCard(
        context,
        'Starry Form${_starryConstellation != null ? " (active)" : ""}',
        _starryConstellation == null
            ? 'Bonus Action, spend a Wild Shape use: luminous form for 10 minutes (Bright Light 10 ft).'
            : '$constellationText'
                  '${level >= 14 ? "\nFull of Stars: Resistance to Bludgeoning, Piercing, Slashing." : ""}'
                  '${level >= 10 ? "\nTwinkling Constellations: change constellation at the start of each turn." : ""}',
        [
          if (_starryConstellation == null)
            for (final e in constellations.entries)
              ElevatedButton(
                onPressed: wildShapeLeft > 0
                    ? () async {
                        await _spendWildShape(characterId);
                        _update(() {
                          _starryConstellation = e.key;
                          _lastRollResult =
                              'Starry Form: ${e.value} (10 minutes).';
                        });
                      }
                    : null,
                child: Text(e.value),
              )
          else ...[
            if (level >= 10)
              DropdownButton<String>(
                value: _starryConstellation,
                items: [
                  for (final e in constellations.entries)
                    DropdownMenuItem(value: e.key, child: Text(e.value)),
                ],
                onChanged: (v) => _update(() => _starryConstellation = v),
              ),
            if (_starryConstellation == 'archer')
              OutlinedButton(
                onPressed: () async {
                  final attack = rollAttack(attackBonus);
                  final natural = attack.rolls.first;
                  final enemies =
                      ref.read(combatEnemiesProvider(characterId)).value ?? [];
                  final target = enemies
                      .where((e) => e.id == _selectedEnemyId)
                      .firstOrNull;
                  final crit = natural == 20;
                  final hit =
                      natural != 1 &&
                      (crit ||
                          target == null ||
                          attack.total >= target.armorClass);
                  final dmg = rollDamage(dice, wis, isCritical: crit);
                  var note = '';
                  if (target != null && hit) {
                    note = await _damageSelectedEnemy(characterId, dmg.total);
                  }
                  _showRoll(
                    'Archer: $natural +$attackBonus = ${attack.total}'
                    '${target != null ? (hit ? " HIT" : " MISS vs AC ${target.armorClass}") : ""}'
                    '${hit ? " — ${dmg.rolls.join('+')} +$wis = ${dmg.total} Radiant$note" : ""}',
                  );
                },
                child: const Text('Archer attack'),
              ),
            if (_starryConstellation == 'chalice')
              OutlinedButton(
                onPressed: () async {
                  final r = rollDamage(dice, wis);
                  final note = await _healSelf(characterId, r.total);
                  _showRoll(
                    'Chalice: ${r.rolls.join('+')} +$wis = ${r.total} HP$note',
                  );
                },
                child: const Text('Chalice: heal myself'),
              ),
            OutlinedButton(
              onPressed: () => _update(() {
                _starryConstellation = null;
                _lastRollResult = 'Starry Form ended.';
              }),
              child: const Text('End form'),
            ),
          ],
        ],
      ),
      if (level >= 6)
        _featureCard(
          context,
          'Cosmic Omen${_cosmicOmen != null ? ": ${_cosmicOmen == "weal" ? "Weal (+1d6)" : "Woe (−1d6)"}" : ""}',
          'Roll after each Long Rest. Reaction: add (Weal) or subtract (Woe) 1d6 on a D20 Test within 30 ft ($omenLeft/$wisUses).',
          [
            OutlinedButton(
              onPressed: () {
                final r = rollDamage('1d6', 0);
                _update(() {
                  _cosmicOmen = r.total.isEven ? 'weal' : 'woe';
                  _lastRollResult =
                      'Cosmic Omen: rolled ${r.total} → ${r.total.isEven ? "Weal (even)" : "Woe (odd)"}';
                });
              },
              child: const Text('Roll omen'),
            ),
            ElevatedButton(
              onPressed: omenLeft > 0 && _cosmicOmen != null
                  ? () async {
                      await _spendResource(characterId, 'cosmic_omen', wisUses);
                      final r = rollDamage('1d6', 0);
                      _showRoll(
                        'Cosmic Omen (${_cosmicOmen == "weal" ? "Weal" : "Woe"}): ${_cosmicOmen == "weal" ? "+" : "−"}${r.total} to the D20 Test',
                      );
                    }
                  : null,
              child: const Text('Use (Reaction)'),
            ),
          ],
        ),
    ];
  }
}
