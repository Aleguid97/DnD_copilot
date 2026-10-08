part of '../combat_screen.dart';

extension _FighterSection on _CombatScreenState {
  /// Fighter features (PHB 2024, chapter 3): Second Wind, Tactical Mind,
  /// Indomitable and the subclasses.
  List<Widget> _buildFighterSection(BuildContext context, _CombatData d) {
    final characterId = d.characterId;
    final c = widget.character;
    if (c.characterClass.id != 'fighter' || characterId == null) {
      return const [];
    }
    final subclass = fighterSubclass(c);
    return [
      const SizedBox(height: 24),
      Text('Fighter Features', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      d.resourceUsesAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (e, st) => Text('Error: $e'),
        data: (rows) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _secondWindCard(context, characterId, rows),
            if (c.level >= 2) _tacticalMindCard(context, characterId, rows),
            if (c.level >= 9) _indomitableCard(context, characterId, rows),
            if (subclass == 'battle_master' && c.level >= 3)
              ..._battleMasterCards(context, characterId, rows, d),
            if (subclass == 'psi_warrior' && c.level >= 3)
              ..._psiWarriorCards(context, characterId, rows, d),
            if (subclass == 'champion' && c.level >= 10)
              _featureCard(
                context,
                'Heroic Warrior',
                'Heroic Inspiration: ${_heroicInspiration ? 'yes' : 'no'}. '
                    'In combat you gain it whenever you start your turn without '
                    'it (Next round). Spend it to reroll any die immediately.',
                [
                  OutlinedButton(
                    onPressed: _heroicInspiration
                        ? () => _update(() {
                            _heroicInspiration = false;
                            _lastRollResult =
                                'Heroic Inspiration spent: reroll the die and use the new roll.';
                          })
                        : () => _update(() => _heroicInspiration = true),
                    child: Text(
                      _heroicInspiration ? 'Use Heroic Inspiration' : 'Gain it',
                    ),
                  ),
                ],
              ),
            if (subclass == 'champion' && c.level >= 18)
              _featureCard(
                context,
                'Survivor',
                'Defy Death: Advantage on Death Saving Throws, 18-20 counts as '
                    'a 20. Heroic Rally: at the start of each turn (Next round), '
                    'if Bloodied with at least 1 HP, regain '
                    '${5 + d.stats.constitutionModifier} HP.',
                const [],
              ),
          ],
        ),
      ),
    ];
  }

  Widget _secondWindCard(
    BuildContext context,
    int characterId,
    List<CharacterResourceUse> rows,
  ) {
    final level = widget.character.level;
    final max = secondWindUses(level);
    final left = _resourceRemaining(rows, 'second_wind', max);
    return _featureCard(
      context,
      'Second Wind ($left/$max)',
      'Bonus Action: regain 1d10 + $level HP. One use back on a Short Rest, '
          'all on a Long Rest.'
          '${level >= 5 ? ' Tactical Shift: also move up to half your Speed without provoking Opportunity Attacks.' : ''}',
      [
        ElevatedButton(
          onPressed: left > 0
              ? () async {
                  await _spendResource(characterId, 'second_wind', max);
                  final roll = rollDamage('1d10', level);
                  final note = await _healSelf(characterId, roll.total);
                  _showRoll(
                    'Second Wind: ${roll.rolls.first} + $level = ${roll.total} HP$note',
                  );
                }
              : null,
          child: const Text('Use Second Wind'),
        ),
      ],
    );
  }

  /// Tactical Mind (level 2): add 1d10 to a failed ability check; the Second
  /// Wind use is spent only if the check then succeeds.
  Widget _tacticalMindCard(
    BuildContext context,
    int characterId,
    List<CharacterResourceUse> rows,
  ) {
    final max = secondWindUses(widget.character.level);
    final left = _resourceRemaining(rows, 'second_wind', max);
    return _featureCard(
      context,
      'Tactical Mind',
      _lastSkillRollForCorrection != null
          ? 'Last check: $_lastSkillRolledName = $_lastSkillRollForCorrection. '
                'If the check still fails, the Second Wind use is kept.'
          : 'Roll an ability check first (Checks tab).',
      [
        OutlinedButton(
          onPressed: left > 0 && _lastSkillRollForCorrection != null
              ? () {
                  final bonus = rollDamage('1d10', 0);
                  final newTotal = _lastSkillRollForCorrection! + bonus.total;
                  _update(() {
                    _lastRollResult =
                        'Tactical Mind: +${bonus.total} → $_lastSkillRolledName new total: $newTotal (did it succeed?)';
                    _lastSkillRollForCorrection = newTotal;
                  });
                }
              : null,
          child: const Text('Add 1d10'),
        ),
        OutlinedButton(
          onPressed: left > 0
              ? () => _spendResource(characterId, 'second_wind', max)
              : null,
          child: const Text('It worked (spend use)'),
        ),
      ],
    );
  }

  /// Indomitable (level 9): reroll a failed save with a bonus equal to the
  /// Fighter level.
  Widget _indomitableCard(
    BuildContext context,
    int characterId,
    List<CharacterResourceUse> rows,
  ) {
    final level = widget.character.level;
    final max = level >= 17 ? 3 : (level >= 13 ? 2 : 1);
    final left = _resourceRemaining(rows, 'indomitable', max);
    return _featureCard(
      context,
      'Indomitable ($left/$max)',
      _lastSaveModifier == null
          ? 'Roll a saving throw first (Checks tab); if you fail, reroll it '
                'with +$level.'
          : 'Reroll your last $_lastSaveAbilityShort save with +$level; you '
                'must use the new roll. Back on a Long Rest.',
      [
        ElevatedButton(
          onPressed: left > 0 && _lastSaveModifier != null
              ? () async {
                  await _spendResource(characterId, 'indomitable', max);
                  final mod = _lastSaveModifier! + level;
                  final roll = rollAttack(mod);
                  _showRoll(
                    'Indomitable: $_lastSaveAbilityShort save reroll ${roll.rolls.first} +$mod = ${roll.total}',
                  );
                }
              : null,
          child: const Text('Reroll failed save'),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Battle Master

  int _battleMasterDc(_CombatData d) {
    final c = widget.character;
    final str = c.abilityScores.modifierFor(
      Ability.strength,
      bonuses: c.totalAbilityBonuses,
    );
    return 8 +
        d.profBonus +
        (str > d.stats.dexModifier ? str : d.stats.dexModifier);
  }

  List<Widget> _battleMasterCards(
    BuildContext context,
    int characterId,
    List<CharacterResourceUse> rows,
    _CombatData d,
  ) {
    final c = widget.character;
    final level = c.level;
    final max = superiorityDiceCount(level);
    final left = _resourceRemaining(rows, 'superiority_dice', max);
    final die = superiorityDie(level);
    final known = knownManeuvers(c);
    final relentless = level >= 15 && !_relentlessUsed;
    return [
      _featureCard(
        context,
        'Superiority Dice ($left/$max $die)',
        'All back on a Short or Long Rest. Maneuver save DC ${_battleMasterDc(d)}. '
            'One maneuver per attack.'
            '${level >= 15 ? ' Relentless: once per turn roll 1d8 instead of expending a die${_relentlessUsed ? ' (used this turn)' : ''}.' : ''}'
            '${known.isEmpty ? '\nNo maneuvers chosen yet (Level Up).' : ''}',
        [
          for (final m in known)
            Tooltip(
              message: m.summary,
              child: OutlinedButton(
                onPressed: left > 0 || relentless
                    ? () => _useManeuver(characterId, rows, d, m)
                    : null,
                child: Text(m.name),
              ),
            ),
        ],
      ),
      if (level >= 7)
        _featureCard(
          context,
          'Know Your Enemy (${_resourceRemaining(rows, 'know_your_enemy', 1)}/1)',
          'Bonus Action: learn the Immunities, Resistances and Vulnerabilities '
              'of a creature within 30 ft. Back on a Long Rest, or expend a '
              'Superiority Die to restore it.',
          [
            OutlinedButton(
              onPressed: _resourceRemaining(rows, 'know_your_enemy', 1) > 0
                  ? () async {
                      await _spendResource(characterId, 'know_your_enemy', 1);
                      _showRoll(
                        'Know Your Enemy: ask the DM for the target\'s '
                        'Immunities, Resistances and Vulnerabilities.',
                      );
                    }
                  : (left > 0
                        ? () async {
                            await _spendResource(
                              characterId,
                              'superiority_dice',
                              max,
                            );
                            await _regainResource(
                              characterId,
                              'know_your_enemy',
                            );
                            _showRoll(
                              'Know Your Enemy restored with a Superiority Die.',
                            );
                          }
                        : null),
              child: Text(
                _resourceRemaining(rows, 'know_your_enemy', 1) > 0
                    ? 'Use (Bonus Action)'
                    : 'Restore with a Superiority Die',
              ),
            ),
          ],
        ),
    ];
  }

  /// Rolls the Superiority Die for [m] (or Relentless' free 1d8) and applies
  /// what it can: damage and save effects on the target, Temp HP, notes.
  Future<void> _useManeuver(
    int characterId,
    List<CharacterResourceUse> rows,
    _CombatData d,
    Maneuver m,
  ) async {
    final c = widget.character;
    final level = c.level;
    final max = superiorityDiceCount(level);
    final hasDie = _resourceRemaining(rows, 'superiority_dice', max) > 0;
    var useRelentless = level >= 15 && !_relentlessUsed && !hasDie;
    if (level >= 15 && !_relentlessUsed && hasDie && mounted) {
      final choice = await showDialog<bool>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: Text(m.name),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'Expend a Superiority Die (${superiorityDie(level)})',
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Relentless: roll 1d8, no die spent'),
            ),
          ],
        ),
      );
      if (choice == null) return;
      useRelentless = choice;
    }
    if (useRelentless) {
      _update(() => _relentlessUsed = true);
    } else {
      await _spendResource(characterId, 'superiority_dice', max);
    }
    final roll = rollDamage(
      '1${useRelentless ? 'd8' : superiorityDie(level)}',
      0,
    );
    final x = roll.total;
    final head =
        '${m.name}: ${useRelentless ? 'Relentless 1d8' : superiorityDie(level)} = $x';
    switch (m.use) {
      case ManeuverUse.damage:
        final dmgNote = _selectedEnemyId == null
            ? ' (add it to the damage)'
            : await _damageSelectedEnemy(characterId, x);
        var saveNote = '';
        if (m.save != null) {
          saveNote = await _featureSave(
            characterId,
            title: '${m.name}: DC ${_battleMasterDc(d)} ${m.save} save',
            condition: '${m.condition} (${m.name})',
          );
        } else if (m.condition != null) {
          final target = _enemies(
            characterId,
          ).where((e) => e.id == _selectedEnemyId).firstOrNull;
          if (target != null) {
            await _addCondition(target, '${m.condition} (${m.name})');
          }
        }
        _showRoll('$head extra damage$dmgNote$saveNote. ${m.summary}');
      case ManeuverUse.attackRoll:
        final last = _lastAttackRollForCorrection;
        _showRoll(
          last == null
              ? '$head: add it to your attack roll.'
              : '$head: attack roll $last + $x = ${last + x}.',
        );
        if (last != null) {
          _update(() => _lastAttackRollForCorrection = last + x);
        }
      case ManeuverUse.check:
        final last = _lastSkillRollForCorrection;
        _showRoll(
          last == null
              ? '$head: add it to the check.'
              : '$head: $_lastSkillRolledName $last + $x = ${last + x}.',
        );
        if (last != null) _update(() => _lastSkillRollForCorrection = last + x);
      case ManeuverUse.armorClass:
        _showRoll(
          '$head: +$x AC until the start of your next turn. ${m.summary}',
        );
      case ManeuverUse.reduceDamage:
        final str = c.abilityScores.modifierFor(
          Ability.strength,
          bonuses: c.totalAbilityBonuses,
        );
        final mod = str > d.stats.dexModifier ? str : d.stats.dexModifier;
        _showRoll('$head: reduce the damage by $x + $mod = ${x + mod}.');
      case ManeuverUse.tempHp:
        _showRoll(
          '$head: the ally gains $x + ${level ~/ 2} = ${x + level ~/ 2} Temporary HP.',
        );
      case ManeuverUse.otherCreature:
        _showRoll(
          '$head: a second creature within 5 ft of the target takes $x damage '
          'if your attack roll would hit it.',
        );
    }
  }

  // -------------------------------------------------------------------------
  // Psi Warrior

  int get _intModifier => widget.character.abilityScores.modifierFor(
    Ability.intelligence,
    bonuses: widget.character.totalAbilityBonuses,
  );

  List<Widget> _psiWarriorCards(
    BuildContext context,
    int characterId,
    List<CharacterResourceUse> rows,
    _CombatData d,
  ) {
    final level = widget.character.level;
    final (die, max) = psionicEnergyDice(level);
    final left = _resourceRemaining(rows, 'psionic_energy', max);
    final intMod = _intModifier;
    final dc = 8 + intMod + d.profBonus;
    Future<int?> spendDie() async {
      if (_resourceRemaining(rows, 'psionic_energy', max) <= 0) {
        _showRoll('No Psionic Energy Dice left.');
        return null;
      }
      await _spendResource(characterId, 'psionic_energy', max);
      return rollDamage('1$die', 0).total;
    }

    /// A power usable once per rest that a Psionic Energy Die can restore.
    Widget power(String id, String name, String text) {
      final ready = _resourceRemaining(rows, id, 1) > 0;
      return _featureCard(context, '$name (${ready ? 1 : 0}/1)', text, [
        OutlinedButton(
          onPressed: ready
              ? () async {
                  await _spendResource(characterId, id, 1);
                  _showRoll('$name used.');
                }
              : (left > 0
                    ? () async {
                        await _spendResource(
                          characterId,
                          'psionic_energy',
                          max,
                        );
                        await _regainResource(characterId, id);
                        _showRoll('$name restored with a Psionic Energy Die.');
                      }
                    : null),
          child: Text(ready ? 'Use' : 'Restore with a die'),
        ),
      ]);
    }

    return [
      _featureCard(
        context,
        'Psionic Energy Dice ($left/$max $die)',
        'One back on a Short Rest, all on a Long Rest.'
            '${level >= 7 ? ' Telekinetic Thrust: Psionic Strike forces a DC $dc Strength save (Prone or moved 10 ft).' : ''}',
        [
          ElevatedButton(
            onPressed: left > 0 && !_psionicStrikeUsed
                ? () async {
                    final x = await spendDie();
                    if (x == null) return;
                    _update(() => _psionicStrikeUsed = true);
                    final total = x + intMod;
                    final dmg = _selectedEnemyId == null
                        ? ''
                        : await _damageSelectedEnemy(characterId, total);
                    final thrust = level >= 7
                        ? await _featureSave(
                            characterId,
                            title: 'Telekinetic Thrust: DC $dc Strength save',
                            condition: 'Prone (Telekinetic Thrust)',
                          )
                        : '';
                    _showRoll(
                      'Psionic Strike: $x + $intMod = $total Force$dmg$thrust',
                    );
                  }
                : null,
            child: Text(
              _psionicStrikeUsed
                  ? 'Psionic Strike (used this turn)'
                  : 'Psionic Strike (after a hit)',
            ),
          ),
          OutlinedButton(
            onPressed: left > 0
                ? () async {
                    final x = await spendDie();
                    if (x == null) return;
                    final reduce = (x + intMod) < 1 ? 1 : x + intMod;
                    _showRoll(
                      'Protective Field: reduce the damage by $x + $intMod = $reduce.',
                    );
                  }
                : null,
            child: const Text('Protective Field (Reaction)'),
          ),
          if (level >= 10)
            OutlinedButton(
              onPressed: left > 0
                  ? () async {
                      if (await spendDie() == null) return;
                      _showRoll(
                        'Guarded Mind: every effect giving you Charmed or '
                        'Frightened ends.',
                      );
                    }
                  : null,
              child: const Text('Guarded Mind: end Charmed/Frightened'),
            ),
        ],
      ),
      power(
        'telekinetic_movement',
        'Telekinetic Movement',
        'Magic action: move a Large or smaller loose object or a willing '
            'creature up to 30 ft. Back on a Short or Long Rest.',
      ),
      if (level >= 7)
        power(
          'psi_powered_leap',
          'Psi-Powered Leap',
          'Bonus Action: Fly Speed equal to twice your Speed until the end of '
              'the turn. Back on a Short or Long Rest.',
        ),
      if (level >= 15)
        power(
          'bulwark_of_force',
          'Bulwark of Force',
          'Bonus Action: up to ${intMod < 1 ? 1 : intMod} creatures within '
              '30 ft have Half Cover for 1 minute. Back on a Long Rest.',
        ),
      if (level >= 18)
        power(
          'telekinetic_master',
          'Telekinetic Master',
          'Cast Telekinesis without a slot (Intelligence); while you '
              'concentrate, one weapon attack as a Bonus Action each turn. '
              'Back on a Long Rest.',
        ),
      if (level >= 10)
        _featureCard(
          context,
          'Guarded Mind',
          'You have Resistance to Psychic damage.',
          const [],
        ),
    ];
  }
}
