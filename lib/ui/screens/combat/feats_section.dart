part of '../combat_screen.dart';

extension _FeatsSection on _CombatScreenState {
  /// Origin feats that have something to press in combat: Lucky, Healer,
  /// Savage Attacker and Tavern Brawler. Tough and Alert have no button
  /// (their effect is already part of Hit Points / Initiative), Skilled and
  /// Magic Initiate are handled by the skills and spell sections.
  List<Widget> _buildFeatsSection(BuildContext context, _CombatData d) {
    final characterId = d.characterId;
    final feats = widget.character.featIds;
    final hasLucky = feats.contains('lucky');
    final hasHealer = feats.contains('healer');
    final hasSavage = feats.contains('savage_attacker');
    final hasBrawler = feats.contains('tavern_brawler');

    if (characterId == null ||
        !(hasLucky || hasHealer || hasSavage || hasBrawler)) {
      return const <Widget>[];
    }

    final cards = <Widget>[];

    if (hasLucky) {
      cards.add(
        d.resourceUsesAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (e, st) => const SizedBox.shrink(),
          data: (rows) => _luckyCard(context, characterId, rows),
        ),
      );
    }
    if (hasHealer) {
      cards.add(_healerCard(context, characterId, d));
    }
    if (hasSavage) {
      cards.add(_savageAttackerCard(context));
    }
    if (hasBrawler) {
      cards.add(_tavernBrawlerCard(context, characterId));
    }

    return [
      const SizedBox(height: 24),
      Text('Feats', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      for (final card in cards)
        Padding(padding: const EdgeInsets.only(bottom: 8), child: card),
    ];
  }

  /// Lucky: Luck Points equal to the Proficiency Bonus, back on a Long Rest.
  Widget _luckyCard(
    BuildContext context,
    int characterId,
    List<CharacterResourceUse> rows,
  ) {
    final max = proficiencyBonusForLevel(widget.character.level);
    final remaining = _resourceRemaining(rows, 'luck_points', max);

    Future<void> spend(String label, bool advantage) async {
      await _spendResource(characterId, 'luck_points', max);
      final a = rollAttack(0).rolls.first;
      final b = rollAttack(0).rolls.first;
      final kept = advantage ? (a > b ? a : b) : (a < b ? a : b);
      _showRoll(
        'Lucky — $label: d20 rolled $a and $b → use $kept (add your modifier). '
        'Luck Points left: ${remaining - 1}/$max',
      );
    }

    return _featureCard(
      context,
      'Lucky',
      'Luck Points: $remaining/$max (all return on a Long Rest). Spend 1 to '
          'take Advantage on a d20 Test, or to impose Disadvantage on an '
          'attack roll against you.',
      [
        OutlinedButton(
          onPressed: remaining > 0
              ? () => spend('Advantage on your d20 Test (keep the higher)', true)
              : null,
          child: const Text('Advantage (spend 1)'),
        ),
        OutlinedButton(
          onPressed: remaining > 0
              ? () => spend(
                  'Disadvantage on the attack against you (the lower counts)',
                  false,
                )
              : null,
          child: const Text('Impose Disadvantage (spend 1)'),
        ),
      ],
    );
  }

  /// Healer: Battle Medic (needs a Healer's Kit). The Healing Rerolls part
  /// (1s on healing dice are rerolled) is also applied to healing spells.
  Widget _healerCard(BuildContext context, int characterId, _CombatData d) {
    final hasKit = d.inventoryRows.any(
      (r) => r.itemId == 'healers_kit' && r.quantity > 0,
    );
    return _featureCard(
      context,
      'Healer — Battle Medic',
      hasKit
          ? 'Utilize action: spend one use of your Healer\'s Kit on a creature '
                'within 5 feet. It spends one of its Hit Point Dice, you roll '
                'it, and it regains the roll + your Proficiency Bonus '
                '(+${d.profBonus}). A 1 on the die is rerolled once. '
                'Kit uses are not tracked here.'
          : 'You need a Healer\'s Kit in your Inventory to use Battle Medic.',
      [
        DropdownButton<int>(
          value: _battleMedicDie,
          items: [
            for (final sides in const [6, 8, 10, 12])
              DropdownMenuItem(
                value: sides,
                child: Text('Target\'s Hit Die: d$sides'),
              ),
          ],
          onChanged: (v) => _update(() => _battleMedicDie = v ?? 8),
        ),
        ElevatedButton(
          onPressed: hasKit
              ? () async {
                  final roll = rollDamageWithReroll(
                    '1d$_battleMedicDie',
                    0,
                    rerollThreshold: 1,
                  );
                  final total = roll.total + d.profBonus;
                  if (!context.mounted) return;
                  final (note, _) = await _healChosenTarget(
                    context,
                    characterId,
                    total,
                  );
                  _showRoll(
                    'Battle Medic: d$_battleMedicDie → ${roll.rolls.join('+')} '
                    '+ ${d.profBonus} (Proficiency) = $total HP$note',
                  );
                }
              : null,
          child: const Text('Tend to a creature'),
        ),
      ],
    );
  }

  /// Savage Attacker: once per turn, a weapon hit rolls its damage dice twice
  /// and keeps the better roll. Arm it here, the next weapon Roll Damage uses
  /// it and disarms it (the app has no turn tracker, so you arm it each turn).
  Widget _savageAttackerCard(BuildContext context) {
    return _featureCard(
      context,
      'Savage Attacker',
      'Once per turn, when you hit with a weapon, roll its damage dice twice '
          'and use either roll. Arm it before the weapon\'s Roll Damage.',
      [
        OutlinedButton(
          onPressed: () =>
              _update(() => _savageAttackerArmed = !_savageAttackerArmed),
          child: Text(
            _savageAttackerArmed
                ? 'Armed: next weapon damage rolls twice (tap to cancel)'
                : 'Arm for the next weapon hit',
          ),
        ),
      ],
    );
  }

  /// Tavern Brawler: Unarmed Strike dice, damage rerolls and the push.
  Widget _tavernBrawlerCard(BuildContext context, int characterId) {
    return _featureCard(
      context,
      'Tavern Brawler',
      'Your Unarmed Strike deals 1d4 + Strength and a 1 on its damage die is '
          'rerolled (already applied in the Unarmed Strike section). You are '
          'proficient with improvised weapons. When you hit with an Unarmed '
          'Strike as part of the Attack action, once per turn you can also '
          'push the target 5 feet.',
      [
        OutlinedButton(
          onPressed: _selectedEnemyId == null
              ? null
              : () async {
                  final enemies =
                      ref.read(combatEnemiesProvider(characterId)).value ?? [];
                  final target = enemies
                      .where((e) => e.id == _selectedEnemyId)
                      .firstOrNull;
                  if (target == null) return;
                  final current = (jsonDecode(target.conditionsJson) as List)
                      .cast<String>();
                  const label = 'Pushed 5 ft (Tavern Brawler)';
                  if (!current.contains(label)) current.add(label);
                  await ref
                      .read(appDatabaseProvider)
                      .updateEnemyConditions(target.id, current);
                  _showRoll('${target.name}: pushed 5 ft (Tavern Brawler).');
                },
          child: const Text('Push target 5 ft (on hit)'),
        ),
      ],
    );
  }
}
