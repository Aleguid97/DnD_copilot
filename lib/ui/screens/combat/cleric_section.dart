part of '../combat_screen.dart';

extension _ClericSection on _CombatScreenState {
  /// Cleric features (PHB 2024, chapter 3): Channel Divinity and its options,
  /// domain features, Divine Intervention.
  List<Widget> _buildClericSection(BuildContext context, _CombatData d) {
    final characterId = d.characterId;
    final c = widget.character;
    if (c.characterClass.id != 'cleric' || characterId == null) {
      return const [];
    }
    final domain = d.domain;
    final level = c.level;
    return [
      const SizedBox(height: 24),
      Text('Cleric Features', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      d.resourceUsesAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (e, st) => Text('Error: $e'),
        data: (rows) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (level >= 2) _channelDivinityCard(context, characterId, rows, d),
            if (domain == 'war' && level >= 3)
              _warPriestCard(context, characterId, rows),
            if (domain == 'light' && level >= 3)
              _wardingFlareCard(context, characterId, rows),
            if (domain == 'light' && level >= 17)
              _coronaOfLightCard(context, characterId, rows),
            if (domain == 'trickery' && level >= 3)
              _featureCard(
                context,
                'Blessing of the Trickster',
                'Magic action: you or a willing creature within 30 ft has '
                    'Advantage on Dexterity (Stealth) checks until you finish '
                    'a Long Rest or use this again.',
                const [],
              ),
            if (_improvedPotentSpellcasting)
              _featureCard(
                context,
                'Improved Blessed Strikes',
                'When a Cleric cantrip deals damage: you or a creature within '
                    '60 ft gains ${2 * wisdomModifier(c)} Temporary HP.',
                [
                  OutlinedButton(
                    onPressed: () => _gainTempHp(
                      2 * wisdomModifier(c),
                      'Improved Blessed Strikes',
                    ),
                    child: const Text('Take the Temp HP'),
                  ),
                ],
              ),
          ],
        ),
      ),
      if (domain == 'war' && level >= 6) ..._warGodsBlessing(context, d),
      if (level >= 10) ..._divineIntervention(context, d),
    ];
  }

  bool get _improvedPotentSpellcasting =>
      widget.character.level >= 14 &&
      widget.character.classSelections['cleric_blessed_strikes']?.contains(
            'potent_spellcasting',
          ) ==
          true;

  /// Temporary Hit Points don't stack: keep the higher amount.
  void _gainTempHp(int amount, String source) {
    if (amount <= _tempHp) {
      _showRoll('$source: you already have $_tempHp Temporary HP.');
      return;
    }
    _update(() {
      _tempHp = amount;
      _tempHpSource = source;
      _lastRollResult = '$source: $amount Temporary HP.';
    });
  }

  /// Spends one Channel Divinity use; false (with a message) if none is left.
  Future<bool> _useChannelDivinity(
    int characterId,
    List<CharacterResourceUse> rows,
  ) async {
    final max = channelDivinityUses(widget.character.level);
    if (_resourceRemaining(rows, 'channel_divinity', max) <= 0) {
      _showRoll('No Channel Divinity uses left.');
      return false;
    }
    await _spendResource(characterId, 'channel_divinity', max);
    return true;
  }

  Widget _channelDivinityCard(
    BuildContext context,
    int characterId,
    List<CharacterResourceUse> rows,
    _CombatData d,
  ) {
    final c = widget.character;
    final domain = d.domain;
    final level = c.level;
    final max = channelDivinityUses(level);
    final left = _resourceRemaining(rows, 'channel_divinity', max);
    final dc = _casterRules(d.profBonus)!.saveDc;
    final sparkDice = '${divineSparkDiceCount(level)}d8';
    VoidCallback? use(Future<void> Function() action) => left > 0
        ? () async {
            if (await _useChannelDivinity(characterId, rows)) await action();
          }
        : null;
    return _featureCard(
      context,
      'Channel Divinity ($left/$max)',
      'One use back on a Short Rest, all on a Long Rest. Save DC $dc.\n'
          'Divine Spark: $sparkDice + Wis, heal or Con save (half). '
          'Turn Undead: Wis save or Frightened + Incapacitated for 1 minute'
          '${level >= 5 ? ', Sear Undead adds Radiant damage' : ''}.',
      [
        OutlinedButton(
          onPressed: use(() => _divineSparkHeal(characterId)),
          child: const Text('Divine Spark: heal'),
        ),
        OutlinedButton(
          onPressed: use(() => _divineSparkDamage(characterId, dc)),
          child: const Text('Divine Spark: damage'),
        ),
        OutlinedButton(
          onPressed: use(() => _turnUndead(characterId, dc)),
          child: const Text('Turn Undead'),
        ),
        if (domain == 'life' && level >= 3)
          OutlinedButton(
            onPressed: left > 0 ? () => _preserveLife(characterId, rows) : null,
            child: const Text('Preserve Life'),
          ),
        if (domain == 'light' && level >= 3)
          OutlinedButton(
            onPressed: use(() => _radianceOfTheDawn(characterId, dc)),
            child: const Text('Radiance of the Dawn'),
          ),
        if (domain == 'trickery' && level >= 3)
          OutlinedButton(
            onPressed: use(
              () async => _update(() {
                _duplicityRoundsLeft = 10;
                _lastRollResult =
                    'Invoke Duplicity: illusion for 1 minute. Advantage on '
                    'attacks vs creatures within 5 ft of you both'
                    '${level >= 17 ? "; allies too near the illusion (Improved Duplicity)" : ""}.';
              }),
            ),
            child: const Text('Invoke Duplicity'),
          ),
        if (domain == 'war' && level >= 3)
          OutlinedButton(
            onPressed: _lastAttackRollForCorrection == null
                ? null
                : use(() async {
                    final roll = _lastAttackRollForCorrection!;
                    _update(() {
                      _lastRollResult =
                          'Guided Strike: $roll + 10 = ${applyGuidedStrike(roll)}';
                      _lastAttackRollForCorrection = null;
                    });
                  }),
            child: const Text('Guided Strike (+10)'),
          ),
        if (_duplicityRoundsLeft != null)
          InputChip(
            label: Text(
              'Duplicity active${_round > 0 ? ': $_duplicityRoundsLeft rds' : ''}',
            ),
            onDeleted: () => _update(() => _duplicityRoundsLeft = null),
          ),
      ],
    );
  }

  Future<void> _divineSparkHeal(int characterId) async {
    final c = widget.character;
    final dice = '${divineSparkDiceCount(c.level)}d8';
    final wis = wisdomModifier(c);
    // Supreme Healing (Life 17) also covers Channel Divinity healing.
    final supreme =
        c.classSelections['cleric_subclass']?.contains('life') == true &&
        c.level >= 17;
    final roll = rollDamage(dice, wis);
    final total = supreme ? maxHealingRoll(dice) + wis : roll.total;
    if (!mounted) return;
    final (note, _) = await _healChosenTarget(context, characterId, total);
    _showRoll(
      'Divine Spark: ${supreme ? 'MAX ${maxHealingRoll(dice)}' : roll.rolls.join('+')} + $wis = $total HP$note',
    );
  }

  Future<void> _divineSparkDamage(int characterId, int dc) async {
    final roll = rollDivineSpark(widget.character);
    final note = await _featureSave(
      characterId,
      title: 'Divine Spark: DC $dc Constitution save',
      damage: roll.total,
      halfOnSave: true,
    );
    _showRoll(
      'Divine Spark: ${roll.rolls.join('+')} + ${roll.modifier} = ${roll.total} '
      'Necrotic or Radiant (half on save)$note',
    );
  }

  Future<void> _turnUndead(int characterId, int dc) async {
    // Sear Undead (level 5): Wisdom-modifier d8s of Radiant to each Undead
    // that fails; the damage doesn't end the Turn.
    final sear = widget.character.level >= 5
        ? rollSearUndead(widget.character)
        : null;
    final note = await _featureSave(
      characterId,
      title: 'Turn Undead: DC $dc Wisdom save (Undead only)',
      multi: true,
      damage: sear?.total ?? 0,
      condition: 'Frightened + Incapacitated (Turn Undead)',
    );
    _showRoll(
      'Turn Undead: fail = Frightened + Incapacitated for 1 minute'
      '${sear == null ? '' : ', Sear Undead ${sear.rolls.join('+')} = ${sear.total} Radiant'}$note',
    );
  }

  Future<void> _radianceOfTheDawn(int characterId, int dc) async {
    final roll = rollRadianceOfTheDawn(widget.character);
    final note = await _featureSave(
      characterId,
      title: 'Radiance of the Dawn: DC $dc Constitution save',
      multi: true,
      damage: roll.total,
      halfOnSave: true,
    );
    _showRoll(
      'Radiance of the Dawn: ${roll.rolls.join('+')} + ${roll.modifier} = '
      '${roll.total} Radiant (half on save), magical Darkness dispelled$note',
    );
  }

  /// A Channel Divinity effect that forces a saving throw on enemies: asks who
  /// is affected and who failed, then applies damage and conditions.
  Future<String> _featureSave(
    int characterId, {
    required String title,
    bool multi = false,
    int damage = 0,
    bool halfOnSave = false,
    String? condition,
  }) async {
    final enemies = _enemies(characterId);
    if (enemies.isEmpty || !mounted) return '';
    final outcomes = await showDialog<Map<int, bool>>(
      context: context,
      builder: (_) => _SaveTargetsDialog(
        title: title,
        enemies: enemies,
        multi: multi,
        preselected: _selectedEnemyId,
      ),
    );
    if (outcomes == null) return ' (not applied)';
    final parts = <String>[];
    for (final e in enemies) {
      final failed = outcomes[e.id];
      if (failed == null) continue;
      final amount = failed ? damage : (halfOnSave ? damage ~/ 2 : 0);
      var line = '${e.name} ${failed ? "fails" : "saves"}';
      if (amount > 0) line = '$line: ${await _damageEnemy(e, amount)}';
      if (failed && condition != null) {
        final survivor = _enemies(
          characterId,
        ).where((x) => x.id == e.id).firstOrNull;
        if (survivor != null) await _addCondition(survivor, condition);
      }
      parts.add(line);
    }
    return parts.isEmpty ? '' : ' — ${parts.join('; ')}';
  }

  /// Preserve Life (Life 3): 5 × Cleric level HP split among Bloodied
  /// creatures (you included), none above half its Hit Point maximum.
  Future<void> _preserveLife(
    int characterId,
    List<CharacterResourceUse> rows,
  ) async {
    final c = widget.character;
    final maxHp = c.totalHitPoints;
    final myHp = await ref.read(currentHpProvider(characterId).future) ?? maxHp;
    final members =
        ref.read(partyMembersProvider(characterId)).value ?? const [];
    final candidates = <_PreserveLifeTarget>[
      _PreserveLifeTarget(null, 'You', myHp, maxHp),
      for (final m in members)
        _PreserveLifeTarget(m.id, m.name, m.currentHp, m.maxHp),
    ].where((t) => t.room > 0).toList();
    if (candidates.isEmpty) {
      _showRoll('Preserve Life: nobody is Bloodied (at half HP or less).');
      return;
    }
    if (!mounted) return;
    final split = await showDialog<Map<_PreserveLifeTarget, int>>(
      context: context,
      builder: (_) => _PreserveLifeDialog(
        pool: preserveLifePool(c.level),
        targets: candidates,
      ),
    );
    if (split == null || split.values.every((v) => v == 0)) return;
    if (!await _useChannelDivinity(characterId, rows)) return;
    final notes = <String>[];
    for (final MapEntry(key: t, value: hp) in split.entries) {
      if (hp <= 0) continue;
      final newHp = t.current + hp;
      if (t.partyMemberId == null) {
        await ref.read(appDatabaseProvider).setCurrentHp(characterId, newHp);
      } else {
        await ref
            .read(appDatabaseProvider)
            .updatePartyMemberHp(t.partyMemberId!, newHp);
      }
      notes.add('${t.name} +$hp → $newHp/${t.max}');
    }
    _showRoll('Preserve Life: ${notes.join('; ')}');
  }

  Widget _warPriestCard(
    BuildContext context,
    int characterId,
    List<CharacterResourceUse> rows,
  ) {
    final max = wardingFlareUses(widget.character);
    final left = _resourceRemaining(rows, 'war_priest', max);
    return _featureCard(
      context,
      'War Priest ($left/$max)',
      'Bonus Action: one attack with a weapon or an Unarmed Strike. Uses '
          'come back on a Short or Long Rest.',
      [
        OutlinedButton(
          onPressed: left > 0
              ? () async {
                  await _spendResource(characterId, 'war_priest', max);
                  _showRoll('War Priest: make one extra attack now.');
                }
              : null,
          child: const Text('Use bonus action attack'),
        ),
      ],
    );
  }

  Widget _wardingFlareCard(
    BuildContext context,
    int characterId,
    List<CharacterResourceUse> rows,
  ) {
    final c = widget.character;
    final max = wardingFlareUses(c);
    final left = _resourceRemaining(rows, 'warding_flare', max);
    final improved = c.level >= 6;
    return _featureCard(
      context,
      'Warding Flare ($left/$max)',
      'Reaction: a creature you can see within 30 ft has Disadvantage on its '
          'attack roll. ${improved ? 'Back on a Short or Long Rest; the target of the attack gains 2d6 + Wis Temporary HP.' : 'Back on a Long Rest.'}',
      [
        OutlinedButton(
          onPressed: left > 0
              ? () async {
                  await _spendResource(characterId, 'warding_flare', max);
                  if (!improved) {
                    _showRoll('Warding Flare: the attack has Disadvantage.');
                    return;
                  }
                  final temp = rollDamage('2d6', wisdomModifier(c));
                  _showRoll(
                    'Warding Flare: the attack has Disadvantage; its target '
                    'gains ${temp.rolls.join('+')} + ${temp.modifier} = '
                    '${temp.total} Temporary HP.',
                  );
                }
              : null,
          child: const Text('Use Warding Flare'),
        ),
      ],
    );
  }

  Widget _coronaOfLightCard(
    BuildContext context,
    int characterId,
    List<CharacterResourceUse> rows,
  ) {
    final max = wardingFlareUses(widget.character);
    final left = _resourceRemaining(rows, 'corona_of_light', max);
    return _featureCard(
      context,
      'Corona of Light ($left/$max)',
      'Magic action: 1-minute aura of sunlight (60 ft Bright, +30 ft Dim). '
          'Enemies in the Bright Light have Disadvantage on saves against '
          'Radiance of the Dawn and spells that deal Fire or Radiant damage.'
          '${_coronaRoundsLeft == null ? '' : ' Active${_round > 0 ? ': $_coronaRoundsLeft rds' : ''}.'}',
      [
        OutlinedButton(
          onPressed: left > 0 && _coronaRoundsLeft == null
              ? () async {
                  await _spendResource(characterId, 'corona_of_light', max);
                  _update(() {
                    _coronaRoundsLeft = 10;
                    _lastRollResult = 'Corona of Light: aura for 1 minute.';
                  });
                }
              : null,
          child: const Text('Emit Corona of Light'),
        ),
        if (_coronaRoundsLeft != null)
          TextButton(
            onPressed: () => _update(() => _coronaRoundsLeft = null),
            child: const Text('Dismiss'),
          ),
      ],
    );
  }

  /// War God's Blessing (War, level 6): spend a Channel Divinity use to cast
  /// Shield of Faith or Spiritual Weapon without a slot or Concentration.
  List<Widget> _warGodsBlessing(BuildContext context, _CombatData d) {
    final characterId = d.characterId!;
    final rules = _casterRules(d.profBonus)!;
    final maxCd = channelDivinityUses(widget.character.level);
    final active = _blessingSpellId != null
        ? allSpells[_blessingSpellId]
        : null;
    return [
      const SizedBox(height: 8),
      d.resourceUsesAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (e, st) => const SizedBox.shrink(),
        data: (rows) {
          final left = _resourceRemaining(rows, 'channel_divinity', maxCd);
          return _featureCard(
            context,
            "War God's Blessing",
            'Spend 1 Channel Divinity ($left/$maxCd left): no slot, no '
                'Concentration, lasts 1 minute (ends if you cast it again, are '
                'Incapacitated or die).'
                '${active == null ? '' : ' Active: ${active.name}${_blessingRoundsLeft == null || _round == 0 ? '' : ', $_blessingRoundsLeft rds'}.'}',
            [
              for (final id in warGodsBlessingSpells)
                OutlinedButton(
                  onPressed: left > 0
                      ? () async {
                          await _spendResource(
                            characterId,
                            'channel_divinity',
                            maxCd,
                          );
                          _update(() {
                            _blessingSpellId = id;
                            _blessingRoundsLeft = 10;
                          });
                          if (!mounted) return;
                          await _castSpell(
                            this.context,
                            characterId,
                            rows,
                            rules,
                            id: id,
                            freeCastSource: "War God's Blessing",
                            noConcentration: true,
                          );
                        }
                      : null,
                  child: Text(allSpells[id]!.name),
                ),
              if (active != null && spellEffects[active.id] != null)
                ElevatedButton(
                  onPressed: () => _resolveSpellEffect(
                    context,
                    characterId,
                    active,
                    spellEffects[active.id]!,
                    active.level,
                    rules,
                    prefix: 'Again — ',
                  ),
                  child: Text('${active.name}: attack again'),
                ),
              if (active != null)
                TextButton(
                  onPressed: () => _update(() {
                    _lastRollResult = '${active.name} ended.';
                    _blessingSpellId = null;
                    _blessingRoundsLeft = null;
                  }),
                  child: const Text('End'),
                ),
            ],
          );
        },
      ),
    ];
  }

  /// Divine Intervention (level 10): as a Magic action, cast any Cleric spell
  /// of level 5 or lower that isn't cast as a Reaction, with no slot and no
  /// Material components. Once per Long Rest.
  List<Widget> _divineIntervention(BuildContext context, _CombatData d) {
    final characterId = d.characterId!;
    final rules = _casterRules(d.profBonus)!;
    return [
      const SizedBox(height: 8),
      d.resourceUsesAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (e, st) => const SizedBox.shrink(),
        data: (rows) {
          final left = _resourceRemaining(rows, 'divine_intervention', 1);
          return _featureCard(
            context,
            'Divine Intervention',
            'Magic action: cast a Cleric spell of level 5 or lower (not a '
                'Reaction spell) without a slot or Material components. '
                '$left/1 (Long Rest).',
            [
              ElevatedButton(
                onPressed: left > 0
                    ? () async {
                        final id = await _pickDivineInterventionSpell(context);
                        if (id == null) return;
                        await _spendResource(
                          characterId,
                          'divine_intervention',
                          1,
                        );
                        if (id == 'wish') {
                          // Greater Divine Intervention (level 20).
                          final rests = rollDamage('2d4', 0);
                          _showRoll(
                            'Divine Intervention: Wish! You can\'t use Divine '
                            'Intervention again until you finish '
                            '${rests.rolls.join('+')} = ${rests.total} Long Rests.',
                          );
                          return;
                        }
                        if (!mounted) return;
                        await _castSpell(
                          this.context,
                          characterId,
                          rows,
                          rules,
                          id: id,
                          freeCastSource: 'Divine Intervention',
                        );
                      }
                    : null,
                child: const Text('Call on your deity'),
              ),
            ],
          );
        },
      ),
    ];
  }

  Future<String?> _pickDivineInterventionSpell(BuildContext context) {
    final candidates = [
      for (final id in classSpellLists['cleric']!)
        if (allSpells[id]!.level >= 1 && allSpells[id]!.level <= 5)
          allSpells[id]!,
    ]..sort((a, b) => a.level.compareTo(b.level));
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Divine Intervention: choose a spell'),
        content: SizedBox(
          width: 420,
          height: 480,
          child: ListView(
            children: [
              if (widget.character.level >= 20)
                ListTile(
                  dense: true,
                  title: const Text('Wish'),
                  subtitle: const Text(
                    'Greater Divine Intervention: afterwards 2d4 Long Rests '
                    'before you can use Divine Intervention again',
                  ),
                  onTap: () => Navigator.of(ctx).pop('wish'),
                ),
              for (final s in candidates)
                ListTile(
                  dense: true,
                  title: Text(s.name),
                  subtitle: Text(
                    [
                      'Level ${s.level}',
                      s.school,
                      if (s.tags.isNotEmpty) s.tags,
                    ].join(' · '),
                  ),
                  onTap: () => Navigator.of(ctx).pop(s.id),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _PreserveLifeTarget {
  final int? partyMemberId;
  final String name;
  final int current;
  final int max;

  const _PreserveLifeTarget(
    this.partyMemberId,
    this.name,
    this.current,
    this.max,
  );

  /// HP that can still be restored: only while Bloodied, up to half max.
  int get room => current * 2 <= max ? max ~/ 2 - current : 0;
}

/// Splits the Preserve Life pool among Bloodied creatures.
class _PreserveLifeDialog extends StatefulWidget {
  final int pool;
  final List<_PreserveLifeTarget> targets;

  const _PreserveLifeDialog({required this.pool, required this.targets});

  @override
  State<_PreserveLifeDialog> createState() => _PreserveLifeDialogState();
}

class _PreserveLifeDialogState extends State<_PreserveLifeDialog> {
  late final Map<_PreserveLifeTarget, int> _split = {
    for (final t in widget.targets) t: 0,
  };

  int get _left => widget.pool - _split.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Preserve Life: $_left/${widget.pool} HP left'),
      content: SizedBox(
        width: 420,
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final t in widget.targets)
              ListTile(
                dense: true,
                title: Text('${t.name} (${t.current}/${t.max} HP)'),
                subtitle: Text('Up to ${t.room} HP (half its maximum)'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _split[t]! > 0
                          ? () => setState(() => _split[t] = _split[t]! - 1)
                          : null,
                    ),
                    Text('${_split[t]}'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _split[t]! < t.room && _left > 0
                          ? () => setState(() => _split[t] = _split[t]! + 1)
                          : null,
                    ),
                    TextButton(
                      onPressed: () => setState(
                        () => _split[t] =
                            _split[t]! + (t.room - _split[t]!).clamp(0, _left),
                      ),
                      child: const Text('Max'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_split),
          child: const Text('Heal'),
        ),
      ],
    );
  }
}
