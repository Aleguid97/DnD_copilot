part of '../combat_screen.dart';

extension _RoundTrackerSection on _CombatScreenState {
  /// Combat round counter. "Next round" ages timed effects (Concentration,
  /// Rage, Starry Form, Wrath of the Sea, War God's Blessing) and clears once-per-turn options.
  List<Widget> _buildRoundTracker(BuildContext context, _CombatData d) {
    final characterId = d.characterId;
    final theme = Theme.of(context);
    final timers = <String, int?>{
      if (_concentrationSpell != null)
        _concentrationSpell!: _concentrationRoundsLeft,
      if (_isRaging) 'Rage': _rageRoundsLeft,
      if (_starryConstellation != null) 'Starry Form': _starryRoundsLeft,
      if (_wrathOfTheSeaActive) 'Wrath of the Sea': _wrathRoundsLeft,
      if (_blessingSpellId != null)
        allSpells[_blessingSpellId]!.name: _blessingRoundsLeft,
    };
    return [
      const SizedBox(height: 8),
      Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.hourglass_bottom, color: theme.colorScheme.primary),
              Text(
                _round == 0 ? 'Not in combat' : 'Round $_round',
                style: theme.textTheme.titleSmall,
              ),
              if (_round == 0)
                OutlinedButton(
                  onPressed: () => _update(() {
                    _round = 1;
                    _lastRollResult = 'Combat started: round 1.';
                  }),
                  child: const Text('Start combat'),
                )
              else ...[
                ElevatedButton(
                  onPressed: characterId == null
                      ? null
                      : () => _nextRound(context, characterId),
                  child: const Text('Next round'),
                ),
                TextButton(
                  onPressed: () => _update(() {
                    _round = 0;
                    _lastRollResult = 'Combat ended.';
                  }),
                  child: const Text('End combat'),
                ),
              ],
              for (final t in timers.entries)
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    t.value == null ? t.key : '${t.key}: ${t.value} rds',
                  ),
                ),
            ],
          ),
        ),
      ),
    ];
  }

  Future<void> _nextRound(BuildContext context, int characterId) async {
    final notes = <String>[];
    int? tick(int? left) => left == null ? null : left - 1;

    // Rage lasts until the end of your next turn unless you attacked, forced
    // a saving throw or used a Bonus Action to extend it (max 10 minutes).
    var rageEnds = false;
    if (_isRaging) {
      final keep = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Keep raging?'),
          content: const Text(
            'Rage continues if this turn you attacked an enemy, forced it to '
            'make a saving throw, or used a Bonus Action to extend it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('No, Rage ends'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Yes, extend it'),
            ),
          ],
        ),
      );
      rageEnds = keep == false || (_rageRoundsLeft ?? 1) <= 1;
    }

    final concentration = tick(_concentrationRoundsLeft);
    final concentrationSpell = _concentrationSpell;

    _update(() {
      _round++;
      _savageAttackerArmed = false;
      if (_isRaging) {
        if (rageEnds) {
          _isRaging = false;
          _rageRoundsLeft = null;
          notes.add('Rage ended');
        } else {
          _rageRoundsLeft = tick(_rageRoundsLeft);
        }
      }
      if (_starryConstellation != null) {
        _starryRoundsLeft = tick(_starryRoundsLeft);
        if ((_starryRoundsLeft ?? 1) <= 0) {
          _starryConstellation = null;
          _starryRoundsLeft = null;
          notes.add('Starry Form ended');
        }
      }
      if (_wrathOfTheSeaActive) {
        _wrathRoundsLeft = tick(_wrathRoundsLeft);
        if ((_wrathRoundsLeft ?? 1) <= 0) {
          _wrathOfTheSeaActive = false;
          _wrathRoundsLeft = null;
          notes.add('Wrath of the Sea ended');
        }
      }
      if (_blessingSpellId != null) {
        _blessingRoundsLeft = tick(_blessingRoundsLeft);
        if ((_blessingRoundsLeft ?? 1) <= 0) {
          notes.add('${allSpells[_blessingSpellId]!.name} ended');
          _blessingSpellId = null;
          _blessingRoundsLeft = null;
        }
      }
      _concentrationRoundsLeft = concentration;
    });

    if (concentrationSpell != null &&
        concentration != null &&
        concentration <= 0) {
      await _endConcentration(characterId);
      notes.add('$concentrationSpell expired');
    }
    _showRoll('Round $_round.${notes.isEmpty ? '' : ' ${notes.join('; ')}.'}');
  }
}
