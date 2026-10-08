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
}
