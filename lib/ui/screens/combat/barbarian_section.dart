part of '../combat_screen.dart';

extension _BarbarianSection on _CombatScreenState {
  /// Barbarian features (Rage, subclasses, ...).
  List<Widget> _buildBarbarianSection(BuildContext context, _CombatData d) {
    final characterId = d.characterId;
    final profBonus = d.profBonus;
    final resourceUsesAsync = d.resourceUsesAsync;
    return [
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
            final rageResources = classResources['barbarian'] ?? [];
            final rageResource = rageResources.firstWhere(
              (r) => r.id == 'rage',
            );
            final maxUses = rageResource.maxUses(widget.character.level);
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rage',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text('$remaining / $maxUses uses'),
                      ],
                    ),
                    Text(
                      _isRaging
                          ? 'Active: Resistance to B/P/S damage, +${rageDamageBonus(widget.character.level)} Strength damage, Advantage on Str checks/saves'
                          : 'Not currently raging.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isRaging
                            ? () => _update(() => _isRaging = false)
                            : (remaining > 0
                                  ? () async {
                                      await ref
                                          .read(appDatabaseProvider)
                                          .useResource(
                                            characterId,
                                            'rage',
                                            maxUses,
                                          );
                                      final subclass = widget
                                          .character
                                          .classSelections['barbarian_subclass']
                                          ?.firstOrNull;
                                      _update(() {
                                        _isRaging = true;
                                        _fanaticalFocusUsedThisRage = false;
                                        if (subclass == 'world_tree') {
                                          _tempHp =
                                              _tempHp > widget.character.level
                                              ? _tempHp
                                              : widget.character.level;
                                        }
                                      });
                                    }
                                  : null),
                        child: Text(_isRaging ? 'End Rage' : 'Activate Rage'),
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
                      onPressed: () =>
                          _update(() => _isRecklessAttack = !_isRecklessAttack),
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
          if (widget.character.level >= 3 && _isRaging) ...[
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Primal Knowledge (Strength checks)',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      'While raging, use Strength for these checks instead of the normal ability.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    ...[
                      'Acrobatics',
                      'Intimidation',
                      'Perception',
                      'Stealth',
                      'Survival',
                    ].map((skill) {
                      final strMod = widget.character.abilityScores.modifierFor(
                        Ability.strength,
                        bonuses: widget.character.totalAbilityBonuses,
                      );
                      final isProficient = widget
                          .character
                          .classSelections
                          .values
                          .any(
                            (set) => set.contains(
                              skill.toLowerCase().replaceAll(' ', '_'),
                            ),
                          );
                      final bonus = strMod + (isProficient ? profBonus : 0);
                      final bonusText = bonus >= 0 ? '+$bonus' : '$bonus';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(skill),
                            OutlinedButton(
                              onPressed: () {
                                final result = rollAttack(bonus);
                                _update(() {
                                  _lastRollResult =
                                      '$skill (Str): ${result.rolls.first} $bonusText = ${result.total}';
                                });
                              },
                              child: Text('Roll ($bonusText)'),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
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
                            final dice = widget.character.level >= 17
                                ? '2d10'
                                : '1d10';
                            final result = rollDamage(dice, 0);
                            _update(() {
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
                                            combatEnemiesProvider(characterId),
                                          )
                                          .value ??
                                      [];
                                  final target = enemies
                                      .where((e) => e.id == _selectedEnemyId)
                                      .firstOrNull;
                                  if (target == null) return;
                                  final current =
                                      (jsonDecode(target.conditionsJson)
                                              as List)
                                          .cast<String>();
                                  if (!current.contains(
                                    'Pushed 15 ft (Forceful Blow)',
                                  )) {
                                    current.add('Pushed 15 ft (Forceful Blow)');
                                  }
                                  await ref
                                      .read(appDatabaseProvider)
                                      .updateEnemyConditions(
                                        target.id,
                                        current,
                                      );
                                  _update(
                                    () => _lastRollResult =
                                        '${target.name}: Forceful Blow applied.',
                                  );
                                },
                          child: const Text('Forceful Blow'),
                        ),
                      ),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _selectedEnemyId == null
                              ? null
                              : () async {
                                  final enemies =
                                      ref
                                          .read(
                                            combatEnemiesProvider(characterId!),
                                          )
                                          .value ??
                                      [];
                                  final target = enemies
                                      .where((e) => e.id == _selectedEnemyId)
                                      .firstOrNull;
                                  if (target == null) return;
                                  final newSpeed = (target.speed - 15).clamp(
                                    0,
                                    999,
                                  );
                                  await ref
                                      .read(appDatabaseProvider)
                                      .updateEnemySpeed(target.id, newSpeed);
                                  _update(
                                    () => _lastRollResult =
                                        '${target.name}: Speed reduced by 15 ft (Hamstring Blow).',
                                  );
                                },
                          child: const Text('Hamstring Blow'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (widget.character.level >= 11)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Relentless Rage',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        'If you drop to 0 HP while raging, Constitution save (DC ${relentlessRageDc(_relentlessRageUsesSinceRest)}) to drop to ${2 * widget.character.level} HP instead.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isRaging
                              ? () {
                                  final dc = relentlessRageDc(
                                    _relentlessRageUsesSinceRest,
                                  );
                                  final conSave =
                                      d.saves[Ability.constitution]!;
                                  final result = rollAttack(conSave);
                                  final success = result.total >= dc;
                                  _update(() {
                                    if (success) {
                                      _relentlessRageUsesSinceRest++;
                                    }
                                    _lastRollResult = success
                                        ? 'Relentless Rage: CON save ${result.rolls.first} ${conSave >= 0 ? '+' : ''}$conSave = ${result.total} vs DC $dc — SUCCESS! HP set to ${2 * widget.character.level}.'
                                        : 'Relentless Rage: CON save ${result.rolls.first} ${conSave >= 0 ? '+' : ''}$conSave = ${result.total} vs DC $dc — FAILED. You drop to 0 HP.';
                                  });
                                }
                              : null,
                          child: const Text(
                            'Attempt Relentless Rage (rolled CON save)',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (widget
                      .character
                      .classSelections['barbarian_subclass']
                      ?.firstOrNull ==
                  'berserker' &&
              widget.character.level >= 10) ...[
            const SizedBox(height: 8),
            Card(
              color: _retaliationAvailable
                  ? Theme.of(context).colorScheme.errorContainer
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Retaliation',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      _retaliationAvailable
                          ? 'Available! Use the Equipped Weapons "Roll to Hit" button above, then tap Consume below.'
                          : 'Triggers when you take damage while raging.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (_retaliationAvailable) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () =>
                              _update(() => _retaliationAvailable = false),
                          child: const Text('Consume Retaliation'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (widget.character.level >= 14)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: resourceUsesAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (e, st) => const SizedBox.shrink(),
                  data: (usesRows) {
                    final row = usesRows
                        .where((r) => r.resourceId == 'intimidating_presence')
                        .firstOrNull;
                    final spent = row?.usesSpent ?? 0;
                    final freeUseAvailable = spent < 1;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Intimidating Presence',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              'Bonus Action, 30 ft: Wisdom save (DC ${8 + rageDamageBonus(widget.character.level) + profBonus}) or Frightened 1 minute.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                OutlinedButton(
                                  onPressed:
                                      (freeUseAvailable &&
                                          _selectedEnemyId != null)
                                      ? () async {
                                          await ref
                                              .read(appDatabaseProvider)
                                              .useResource(
                                                characterId!,
                                                'intimidating_presence',
                                                1,
                                              );
                                          final enemies =
                                              ref
                                                  .read(
                                                    combatEnemiesProvider(
                                                      characterId!,
                                                    ),
                                                  )
                                                  .value ??
                                              [];
                                          final target = enemies
                                              .where(
                                                (e) => e.id == _selectedEnemyId,
                                              )
                                              .firstOrNull;
                                          if (target != null) {
                                            final current =
                                                (jsonDecode(
                                                          target.conditionsJson,
                                                        )
                                                        as List)
                                                    .cast<String>();
                                            if (!current.contains(
                                              'Frightened (Intimidating Presence)',
                                            )) {
                                              current.add(
                                                'Frightened (Intimidating Presence)',
                                              );
                                            }
                                            await ref
                                                .read(appDatabaseProvider)
                                                .updateEnemyConditions(
                                                  target.id,
                                                  current,
                                                );
                                          }
                                          _update(
                                            () => _lastRollResult =
                                                'Intimidating Presence used (free use).',
                                          );
                                        }
                                      : null,
                                  child: const Text('Use (free, 1/Long Rest)'),
                                ),
                                OutlinedButton(
                                  onPressed:
                                      (_isRaging && _selectedEnemyId != null)
                                      ? () async {
                                          final rageResource =
                                              (classResources['barbarian'] ??
                                                      [])
                                                  .firstWhere(
                                                    (r) => r.id == 'rage',
                                                  );
                                          final maxUses = rageResource.maxUses(
                                            widget.character.level,
                                          );
                                          await ref
                                              .read(appDatabaseProvider)
                                              .useResource(
                                                characterId!,
                                                'rage',
                                                maxUses,
                                              );
                                          final enemies =
                                              ref
                                                  .read(
                                                    combatEnemiesProvider(
                                                      characterId!,
                                                    ),
                                                  )
                                                  .value ??
                                              [];
                                          final target = enemies
                                              .where(
                                                (e) => e.id == _selectedEnemyId,
                                              )
                                              .firstOrNull;
                                          if (target != null) {
                                            final current =
                                                (jsonDecode(
                                                          target.conditionsJson,
                                                        )
                                                        as List)
                                                    .cast<String>();
                                            if (!current.contains(
                                              'Frightened (Intimidating Presence)',
                                            )) {
                                              current.add(
                                                'Frightened (Intimidating Presence)',
                                              );
                                            }
                                            await ref
                                                .read(appDatabaseProvider)
                                                .updateEnemyConditions(
                                                  target.id,
                                                  current,
                                                );
                                          }
                                          _update(
                                            () => _lastRollResult =
                                                'Intimidating Presence used (spent a Rage use).',
                                          );
                                        }
                                      : null,
                                  child: const Text('Use (spend Rage use)'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
          Builder(
            builder: (context) {
              final subclass = widget
                  .character
                  .classSelections['barbarian_subclass']
                  ?.firstOrNull;
              final wildHeartAspect = widget
                  .character
                  .classSelections['barbarian_rage_of_the_wilds']
                  ?.firstOrNull;
              final powerAspect = widget
                  .character
                  .classSelections['barbarian_power_of_the_wilds']
                  ?.firstOrNull;

              if (subclass == 'wild_heart' &&
                  powerAspect == 'ram' &&
                  widget.character.level >= 14) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ram: Force Prone',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _selectedEnemyId == null
                                  ? null
                                  : () async {
                                      final enemies =
                                          ref
                                              .read(
                                                combatEnemiesProvider(
                                                  characterId!,
                                                ),
                                              )
                                              .value ??
                                          [];
                                      final target = enemies
                                          .where(
                                            (e) => e.id == _selectedEnemyId,
                                          )
                                          .firstOrNull;
                                      if (target == null) {
                                        return;
                                      }
                                      final current =
                                          (jsonDecode(target.conditionsJson)
                                                  as List)
                                              .cast<String>();
                                      if (!current.contains('Prone (Ram)')) {
                                        current.add('Prone (Ram)');
                                      }
                                      await ref
                                          .read(appDatabaseProvider)
                                          .updateEnemyConditions(
                                            target.id,
                                            current,
                                          );
                                      _update(
                                        () => _lastRollResult =
                                            '${target.name}: failed save, Prone (Ram).',
                                      );
                                    },
                              child: const Text('Target failed save → Prone'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (subclass == 'world_tree') {
                return Column(
                  children: [
                    if (widget.character.level >= 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Life-Giving Force',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  'While raging, give an ally Temp HP (${lifeGivingForceDice(widget.character.level)}) at the start of your turn.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                Builder(
                                  builder: (context) {
                                    final partyAsync = ref.watch(
                                      partyMembersProvider(characterId!),
                                    );
                                    return partyAsync.when(
                                      loading: () => const SizedBox.shrink(),
                                      error: (e, st) => const SizedBox.shrink(),
                                      data: (members) {
                                        if (members.isEmpty) {
                                          return const Text(
                                            'Add allies from the Party screen.',
                                          );
                                        }
                                        return Column(
                                          children: [
                                            DropdownButton<int?>(
                                              value: _lifeGivingForceTargetId,
                                              hint: const Text('Choose ally'),
                                              items: members
                                                  .map(
                                                    (m) => DropdownMenuItem(
                                                      value: m.id,
                                                      child: Text(m.name),
                                                    ),
                                                  )
                                                  .toList(),
                                              onChanged: (v) => _update(
                                                () => _lifeGivingForceTargetId =
                                                    v,
                                              ),
                                            ),
                                            SizedBox(
                                              width: double.infinity,
                                              child: OutlinedButton(
                                                onPressed:
                                                    _lifeGivingForceTargetId ==
                                                        null
                                                    ? null
                                                    : () async {
                                                        final target = members
                                                            .where(
                                                              (m) =>
                                                                  m.id ==
                                                                  _lifeGivingForceTargetId,
                                                            )
                                                            .firstOrNull;
                                                        if (target == null) {
                                                          return;
                                                        }
                                                        final result = rollDamage(
                                                          lifeGivingForceDice(
                                                            widget
                                                                .character
                                                                .level,
                                                          ),
                                                          0,
                                                        );
                                                        final newHp =
                                                            (target.currentHp +
                                                                    result
                                                                        .total)
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
                                                        _update(() {
                                                          _lastRollResult =
                                                              'Life-Giving Force: ${target.name} +${result.total} Temp HP';
                                                        });
                                                      },
                                                child: const Text(
                                                  'Grant Temp HP',
                                                ),
                                              ),
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
                      ),
                    if (widget.character.level >= 6)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Branches of the Tree',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  'Reaction: teleport a creature within 30 ft and reduce its Speed to 0 (Str save DC ${8 + rageDamageBonus(widget.character.level) + profBonus}).',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: _selectedEnemyId == null
                                        ? null
                                        : () async {
                                            final enemies =
                                                ref
                                                    .read(
                                                      combatEnemiesProvider(
                                                        characterId!,
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
                                            if (target == null) {
                                              return;
                                            }
                                            await ref
                                                .read(appDatabaseProvider)
                                                .updateEnemySpeed(target.id, 0);
                                            _update(
                                              () => _lastRollResult =
                                                  '${target.name}: Speed reduced to 0 (Branches of the Tree).',
                                            );
                                          },
                                    child: const Text(
                                      'Target failed save → Speed 0',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }
              if (subclass == 'zealot') {
                return Column(
                  children: [
                    if (widget.character.level >= 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: resourceUsesAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (e, st) => const SizedBox.shrink(),
                          data: (usesRows) {
                            final poolSize = warriorOfTheGodsPoolSize(
                              widget.character.level,
                            );
                            final row = usesRows
                                .where(
                                  (r) =>
                                      r.resourceId ==
                                      'warrior_of_the_gods_pool',
                                )
                                .firstOrNull;
                            final spent = row?.usesSpent ?? 0;
                            final remaining = (poolSize - spent).clamp(
                              0,
                              poolSize,
                            );
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Warrior of the Gods',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                    Text(
                                      'd12 pool: $remaining/$poolSize remaining (refills on Long Rest)',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: remaining > 0
                                            ? () async {
                                                final result = rollDamage(
                                                  '1d12',
                                                  0,
                                                );
                                                await ref
                                                    .read(appDatabaseProvider)
                                                    .useResource(
                                                      characterId!,
                                                      'warrior_of_the_gods_pool',
                                                      poolSize,
                                                    );
                                                final maxHp = widget
                                                    .character
                                                    .totalHitPoints;
                                                final currentStored = await ref
                                                    .read(
                                                      currentHpProvider(
                                                        characterId!,
                                                      ).future,
                                                    );
                                                final currentHp =
                                                    currentStored ?? maxHp;
                                                final newHp =
                                                    (currentHp + result.total)
                                                        .clamp(0, maxHp);
                                                await ref
                                                    .read(appDatabaseProvider)
                                                    .setCurrentHp(
                                                      characterId!,
                                                      newHp,
                                                    );
                                                _update(() {
                                                  _lastRollResult =
                                                      'Warrior of the Gods: healed ${result.total} HP → $newHp/$maxHp';
                                                });
                                              }
                                            : null,
                                        child: const Text(
                                          'Spend 1 die to heal (Bonus Action)',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if (widget.character.level >= 6)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fanatical Focus',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  _fanaticalFocusUsedThisRage
                                      ? 'Already used this Rage.'
                                      : (_lastSaveModifier != null
                                            ? 'Reroll your last save ($_lastSaveAbilityShort) with +${rageDamageBonus(widget.character.level)}.'
                                            : 'Roll a Saving Throw above first.'),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed:
                                        (_isRaging &&
                                            !_fanaticalFocusUsedThisRage &&
                                            _lastSaveModifier != null)
                                        ? () {
                                            final bonus = rageDamageBonus(
                                              widget.character.level,
                                            );
                                            final result = rollAttack(
                                              _lastSaveModifier! + bonus,
                                            );
                                            _update(() {
                                              _fanaticalFocusUsedThisRage =
                                                  true;
                                              _lastRollResult =
                                                  'Fanatical Focus: $_lastSaveAbilityShort reroll: ${result.rolls.first} +${_lastSaveModifier! + bonus} = ${result.total}';
                                            });
                                          }
                                        : null,
                                    child: const Text('Reroll failed save'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (widget.character.level >= 10)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: resourceUsesAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (e, st) => const SizedBox.shrink(),
                          data: (usesRows) {
                            final row = usesRows
                                .where(
                                  (r) => r.resourceId == 'zealous_presence',
                                )
                                .firstOrNull;
                            final spent = row?.usesSpent ?? 0;
                            final freeUseAvailable = spent < 1;
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Zealous Presence',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                    Text(
                                      'Bonus Action: up to 10 allies within 60 ft gain Advantage on attacks and saves until the start of your next turn.',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        OutlinedButton(
                                          onPressed: freeUseAvailable
                                              ? () async {
                                                  await ref
                                                      .read(appDatabaseProvider)
                                                      .useResource(
                                                        characterId!,
                                                        'zealous_presence',
                                                        1,
                                                      );
                                                  _update(
                                                    () => _lastRollResult =
                                                        'Zealous Presence activated (free use)!',
                                                  );
                                                }
                                              : null,
                                          child: const Text(
                                            'Use (free, 1/Long Rest)',
                                          ),
                                        ),
                                        OutlinedButton(
                                          onPressed: _isRaging
                                              ? () async {
                                                  final rageResource =
                                                      (classResources['barbarian'] ??
                                                              [])
                                                          .firstWhere(
                                                            (r) =>
                                                                r.id == 'rage',
                                                          );
                                                  final maxUses = rageResource
                                                      .maxUses(
                                                        widget.character.level,
                                                      );
                                                  await ref
                                                      .read(appDatabaseProvider)
                                                      .useResource(
                                                        characterId!,
                                                        'rage',
                                                        maxUses,
                                                      );
                                                  _update(
                                                    () => _lastRollResult =
                                                        'Zealous Presence activated (spent a Rage use)!',
                                                  );
                                                }
                                              : null,
                                          child: const Text(
                                            'Use (spend Rage use)',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ],
    ];
  }
}
