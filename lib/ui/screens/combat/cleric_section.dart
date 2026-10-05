part of '../combat_screen.dart';

extension _ClericSection on _CombatScreenState {
  /// Cleric features (Channel Divinity, domains, ...).
  List<Widget> _buildClericSection(BuildContext context, _CombatData d) {
    final characterId = d.characterId;
    final resourceUsesAsync = d.resourceUsesAsync;
    final domain = d.domain;
    return [
      if (widget.character.characterClass.id == 'cleric' &&
          characterId != null) ...[
        const SizedBox(height: 24),
        Text('Cleric Features', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Builder(
          builder: (context) {
            final partyAsync = ref.watch(partyMembersProvider(characterId));
            return partyAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
              data: (members) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite, size: 18),
                        const SizedBox(width: 8),
                        const Text('Heal target: '),
                        DropdownButton<int?>(
                          value: _healTargetPartyMemberId,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Myself'),
                            ),
                            ...members.map(
                              (m) => DropdownMenuItem(
                                value: m.id,
                                child: Text(
                                  '${m.name} (${m.currentHp}/${m.maxHp} HP)',
                                ),
                              ),
                            ),
                          ],
                          onChanged: (v) =>
                              _update(() => _healTargetPartyMemberId = v),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Divine Spark',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  'Heal a target, or force a Constitution save (fail: full damage, success: half).',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final isLife = domain == 'life';
                          final hasSupreme =
                              isLife && widget.character.level >= 17;
                          final result = rollDivineSpark(widget.character);
                          final healTotal = hasSupreme
                              ? maxHealingRoll(
                                      '${divineSparkDiceCount(widget.character.level)}d8',
                                    ) +
                                    result.modifier
                              : result.total;

                          if (_healTargetPartyMemberId == null) {
                            final maxHp = widget.character.totalHitPoints;
                            final currentStored = await ref.read(
                              currentHpProvider(characterId).future,
                            );
                            final currentHp = currentStored ?? maxHp;

                            if (currentHp >= maxHp) {
                              _update(() {
                                _lastRollResult =
                                    'Divine Spark: your HP already at maximum ($currentHp/$maxHp) — no healing applied.';
                              });
                              return;
                            }

                            var newHp = (currentHp + healTotal).clamp(0, maxHp);
                            String selfHealNote = '';
                            if (isLife && widget.character.level >= 6) {
                              newHp = (newHp + blessedHealerSelfHeal()).clamp(
                                0,
                                maxHp,
                              );
                              selfHealNote =
                                  ' (+ ${blessedHealerSelfHeal()} self-heal, Blessed Healer)';
                            }
                            await ref
                                .read(appDatabaseProvider)
                                .setCurrentHp(characterId, newHp);
                            _update(() {
                              _lastRollResult =
                                  'Divine Spark (self-heal): ${hasSupreme ? "MAX " : ""}${result.rolls.join('+')} + ${result.modifier} = $healTotal HP$selfHealNote → now $newHp/$maxHp HP';
                            });
                          } else {
                            final members =
                                ref
                                    .read(partyMembersProvider(characterId))
                                    .value ??
                                [];
                            final target = members
                                .where((m) => m.id == _healTargetPartyMemberId)
                                .firstOrNull;
                            if (target == null) return;

                            if (target.currentHp >= target.maxHp) {
                              _update(() {
                                _lastRollResult =
                                    'Divine Spark: ${target.name} already at maximum HP (${target.currentHp}/${target.maxHp}) — no healing applied.';
                              });
                              return;
                            }

                            var newHp = (target.currentHp + healTotal).clamp(
                              0,
                              target.maxHp,
                            );
                            String selfHealNote = '';
                            if (isLife && widget.character.level >= 6) {
                              final maxHp = widget.character.totalHitPoints;
                              final currentStored = await ref.read(
                                currentHpProvider(characterId).future,
                              );
                              final currentSelfHp = currentStored ?? maxHp;
                              final selfHeal = blessedHealerSelfHeal();
                              final newSelfHp = (currentSelfHp + selfHeal)
                                  .clamp(0, maxHp);
                              await ref
                                  .read(appDatabaseProvider)
                                  .setCurrentHp(characterId, newSelfHp);
                              selfHealNote =
                                  ' (+ $selfHeal self-heal, Blessed Healer)';
                            }
                            await ref
                                .read(appDatabaseProvider)
                                .updatePartyMemberHp(target.id, newHp);
                            _update(() {
                              _lastRollResult =
                                  'Divine Spark (${target.name}): ${hasSupreme ? "MAX " : ""}${result.rolls.join('+')} + ${result.modifier} = $healTotal HP$selfHealNote → now $newHp/${target.maxHp} HP';
                            });
                          }
                        },
                        child: const Text('Heal'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final result = rollDivineSpark(widget.character);
                          String targetNote = '';
                          if (_selectedEnemyId != null) {
                            final enemies =
                                ref
                                    .read(combatEnemiesProvider(characterId))
                                    .value ??
                                [];
                            final target = enemies
                                .where((e) => e.id == _selectedEnemyId)
                                .firstOrNull;
                            if (target != null) {
                              final newHp = (target.currentHp - result.total)
                                  .clamp(0, target.maxHp);
                              if (newHp <= 0) {
                                await ref
                                    .read(appDatabaseProvider)
                                    .removeEnemy(target.id);
                                targetNote = ' — ${target.name} defeated!';
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
                                'Divine Spark (damage, target fails save): ${result.total}$targetNote';
                          });
                        },
                        child: const Text('Damage (fail)'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Turn Undead',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  'Undead within 30 ft make a Wisdom save or are Frightened + Incapacitated for 1 minute.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
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
                                    (jsonDecode(target.conditionsJson) as List)
                                        .cast<String>();
                                if (!current.contains(
                                  'Frightened + Incapacitated (Turn Undead)',
                                )) {
                                  current.add(
                                    'Frightened + Incapacitated (Turn Undead)',
                                  );
                                }
                                await ref
                                    .read(appDatabaseProvider)
                                    .updateEnemyConditions(target.id, current);
                                _update(
                                  () => _lastRollResult =
                                      '${target.name}: failed save, Turned.',
                                );
                              },
                        child: const Text('Target failed save'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (widget.character.level >= 5)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final result = rollSearUndead(widget.character);
                            String targetNote = '';
                            if (_selectedEnemyId != null) {
                              final enemies =
                                  ref
                                      .read(combatEnemiesProvider(characterId))
                                      .value ??
                                  [];
                              final target = enemies
                                  .where((e) => e.id == _selectedEnemyId)
                                  .firstOrNull;
                              if (target != null) {
                                final newHp = (target.currentHp - result.total)
                                    .clamp(0, target.maxHp);
                                if (newHp <= 0) {
                                  await ref
                                      .read(appDatabaseProvider)
                                      .removeEnemy(target.id);
                                  targetNote = ' — ${target.name} defeated!';
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
                                  'Sear Undead: ${result.total} Radiant$targetNote';
                            });
                          },
                          child: const Text('Sear Undead'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (domain == 'war') ...[
          const SizedBox(height: 8),
          resourceUsesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
            data: (usesRows) {
              final wisMod = wisdomModifier(widget.character).clamp(1, 20);
              final row = usesRows
                  .where((r) => r.resourceId == 'war_priest')
                  .firstOrNull;
              final spent = row?.usesSpent ?? 0;
              final remaining = (wisMod - spent).clamp(0, wisMod);
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'War Priest',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        'Bonus Action weapon/Unarmed Strike attack. Uses: $remaining / $wisMod (recharge on Short or Long Rest)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: remaining > 0
                              ? () => ref
                                    .read(appDatabaseProvider)
                                    .useResource(
                                      characterId,
                                      'war_priest',
                                      wisMod,
                                    )
                              : null,
                          child: const Text('Use bonus action attack'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Guided Strike',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    _lastAttackRollForCorrection != null
                        ? 'Last attack roll: $_lastAttackRollForCorrection'
                        : 'No recent attack roll to correct.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _lastAttackRollForCorrection == null
                          ? null
                          : () {
                              final corrected = applyGuidedStrike(
                                _lastAttackRollForCorrection!,
                              );
                              _update(() {
                                _lastRollResult =
                                    'Guided Strike: $_lastAttackRollForCorrection + 10 = $corrected';
                              });
                            },
                      child: const Text('Apply +10 to missed roll'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (domain == 'life') ...[
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preserve Life',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    'Total pool: ${preserveLifePool(widget.character.level)} HP, split among Bloodied allies within 30 ft (max half their HP max each).',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      final partyAsync = ref.watch(
                        partyMembersProvider(characterId),
                      );
                      return partyAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (e, st) => const SizedBox.shrink(),
                        data: (members) {
                          if (members.isEmpty) {
                            return const Text(
                              'No party members added yet. Add allies from the Party screen first.',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('Target: '),
                                  DropdownButton<int?>(
                                    value: _preserveLifeTargetId,
                                    hint: const Text('Choose ally'),
                                    items: members
                                        .map(
                                          (m) => DropdownMenuItem(
                                            value: m.id,
                                            child: Text(
                                              '${m.name} (${m.currentHp}/${m.maxHp} HP)',
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) => _update(
                                      () => _preserveLifeTargetId = v,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _preserveLifeController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'HP to give this ally',
                                        isDense: true,
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final amount = int.tryParse(
                                        _preserveLifeController.text,
                                      );
                                      if (amount == null ||
                                          _preserveLifeTargetId == null) {
                                        return;
                                      }
                                      final target = members
                                          .where(
                                            (m) =>
                                                m.id == _preserveLifeTargetId,
                                          )
                                          .firstOrNull;
                                      if (target == null) return;
                                      final cap = target.maxHp ~/ 2;
                                      final actualHeal = amount > cap
                                          ? cap
                                          : amount;
                                      final newHp =
                                          (target.currentHp + actualHeal).clamp(
                                            0,
                                            target.maxHp,
                                          );
                                      await ref
                                          .read(appDatabaseProvider)
                                          .updatePartyMemberHp(
                                            target.id,
                                            newHp,
                                          );
                                      _update(() {
                                        _lastRollResult =
                                            'Preserve Life: ${target.name} healed $actualHeal HP (capped at half max) → $newHp/${target.maxHp}';
                                        _preserveLifeController.clear();
                                      });
                                    },
                                    child: const Text('Apply'),
                                  ),
                                ],
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
        ],
        if (domain == 'light') ...[
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Radiance of the Dawn',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    '2d10 + Cleric level Radiant, 30 ft emanation, Con save for half (apply per enemy manually).',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        final result = rollRadianceOfTheDawn(widget.character);
                        _update(() {
                          _lastRollResult =
                              'Radiance of the Dawn: ${result.rolls.join('+')} + ${widget.character.level} = ${result.total} (half on successful save)';
                        });
                      },
                      child: const Text('Roll damage'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Warding Flare',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    'Reaction: impose Disadvantage on an incoming attack. Uses available: ${wardingFlareUses(widget.character)} (min 1, recharge on Long Rest).',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
        if (domain == 'trickery') ...[
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Blessing of the Trickster',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    'Grant Advantage on Dexterity (Stealth) checks to yourself or a willing creature within 30 ft, until you finish a Long Rest or use this again.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invoke Duplicity',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    'Channel Divinity: create an illusory duplicate of yourself for 1 minute (Cast Spells / Distract / Move benefits). Track manually at the table.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    ];
  }
}
