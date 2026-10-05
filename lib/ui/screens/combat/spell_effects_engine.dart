part of '../combat_screen.dart';

/// Conditions placed by a spell are tagged "Condition (Spell)" so they can be
/// removed when the spell's Concentration ends.
String _spellConditionLabel(String condition, String spellName) =>
    '$condition ($spellName)';

/// Markers that give Advantage on attack rolls against the creature
/// (Faerie Fire's outline, Guiding Bolt's glimmer).
bool _grantsAdvantage(String condition) =>
    condition.startsWith('Outlined (') ||
    condition.startsWith('Guiding Bolt (');

List<String> _conditionsOf(CombatEnemy e) =>
    (jsonDecode(e.conditionsJson) as List).cast<String>();

extension _SpellEffectsEngine on _CombatScreenState {
  List<CombatEnemy> _enemies(int characterId) =>
      ref.read(combatEnemiesProvider(characterId)).value ?? const [];

  /// Whether attacks against the selected target have Advantage from a spell
  /// marker. Guiding Bolt's marker is used up by the attack ([consume]).
  Future<bool> _targetMarkerAdvantage(
    int characterId, {
    bool consume = true,
  }) async {
    final target = _enemies(
      characterId,
    ).where((e) => e.id == _selectedEnemyId).firstOrNull;
    if (target == null) return false;
    final conditions = _conditionsOf(target);
    final has = conditions.any(_grantsAdvantage);
    if (consume && conditions.any((c) => c.startsWith('Guiding Bolt ('))) {
      await ref
          .read(appDatabaseProvider)
          .updateEnemyConditions(
            target.id,
            conditions.where((c) => !c.startsWith('Guiding Bolt (')).toList(),
          );
    }
    return has;
  }

  Future<void> _addCondition(CombatEnemy enemy, String label) async {
    final current = _conditionsOf(enemy);
    if (current.contains(label)) return;
    await ref.read(appDatabaseProvider).updateEnemyConditions(enemy.id, [
      ...current,
      label,
    ]);
  }

  /// Ends Concentration and removes the conditions that spell imposed.
  Future<void> _endConcentration(int characterId, {String reason = ''}) async {
    final name = _concentrationSpell;
    if (name == null) return;
    for (final e in _enemies(characterId)) {
      final current = _conditionsOf(e);
      final kept = current.where((c) => !c.endsWith('($name)')).toList();
      if (kept.length != current.length) {
        await ref.read(appDatabaseProvider).updateEnemyConditions(e.id, kept);
      }
    }
    _update(() {
      _concentrationSpell = null;
      _concentrationSpellId = null;
      _concentrationSlotLevel = null;
      if (reason.isNotEmpty) _lastRollResult = reason;
    });
  }

  /// Applies [amount] damage to [enemy]; returns a short result note.
  Future<String> _damageEnemy(CombatEnemy enemy, int amount) async {
    final newHp = (enemy.currentHp - amount).clamp(0, enemy.maxHp);
    if (newHp <= 0) {
      await ref.read(appDatabaseProvider).removeEnemy(enemy.id);
      return '${enemy.name} −$amount → defeated';
    }
    await ref.read(appDatabaseProvider).updateEnemyHp(enemy.id, newHp);
    return '${enemy.name} −$amount → $newHp/${enemy.maxHp}';
  }

  /// Rolls and applies a spell's combat effect. [slotLevel] is 0 for cantrips.
  Future<void> _resolveSpellEffect(
    BuildContext context,
    int characterId,
    Spell spell,
    SpellEffect effect,
    int slotLevel,
    _CasterRules rules, {
    String prefix = '',
  }) async {
    final level = widget.character.level;
    final dice = scaledDice(
      effect,
      spellLevel: spell.level,
      slotLevel: slotLevel,
      characterLevel: level,
    );
    // Potent Spellcasting (Druid Elemental Fury): + Wisdom to cantrip damage.
    final potent =
        spell.isCantrip &&
        effect.dealsDamage &&
        widget.character.characterClass.id == 'druid' &&
        druidElementalFury(widget.character) == 'potent_spellcasting';
    final damageMod = (effect.addModifier || potent) ? rules.abilityMod : 0;
    final type = effect.damageType ?? '';
    final note = effect.note.isEmpty ? '' : ' (${effect.note})';

    switch (effect.kind) {
      case SpellEffectKind.heal:
        final flat = scaledFlat(
          effect,
          spellLevel: spell.level,
          slotLevel: slotLevel,
        );
        final roll = dice == null
            ? null
            : rollDamage(
                dice,
                (effect.addModifier ? rules.abilityMod : 0) + flat,
              );
        final total = roll?.total ?? flat;
        if (!context.mounted) return;
        final targetNote = await _healChosenTarget(context, characterId, total);
        _showRoll(
          '$prefix${spell.name}: ${roll != null ? "${roll.rolls.join('+')}${roll.modifier != 0 ? " +${roll.modifier}" : ""} = " : ""}$total HP$targetNote$note',
        );
        return;

      case SpellEffectKind.automatic:
        final roll = rollDamage(dice!, damageMod);
        final target = _enemies(
          characterId,
        ).where((e) => e.id == _selectedEnemyId).firstOrNull;
        final hit = target != null
            ? ' — ${await _damageEnemy(target, roll.total)}'
            : '';
        _showRoll(
          '$prefix${spell.name}: ${roll.rolls.join('+')}${damageMod != 0 ? " +$damageMod" : ""} = ${roll.total} $type$hit$note',
        );
        return;

      case SpellEffectKind.attack:
        final target = _enemies(
          characterId,
        ).where((e) => e.id == _selectedEnemyId).firstOrNull;
        final advantage = await _targetMarkerAdvantage(characterId);
        final first = rollAttack(rules.attackBonus);
        var attack = first;
        var advNote = '';
        if (advantage) {
          final second = rollAttack(rules.attackBonus);
          if (second.total > first.total) attack = second;
          advNote = ' (Advantage ${first.rolls.first}/${second.rolls.first})';
        }
        final natural = attack.rolls.first;
        final crit = natural == 20;
        final hit =
            natural != 1 &&
            (crit || target == null || attack.total >= target.armorClass);
        var text =
            '$prefix${spell.name}: ${effect.melee ? "melee" : "ranged"} spell attack $natural +${rules.attackBonus} = ${attack.total}$advNote';
        if (target != null) {
          text += hit
              ? (crit ? ' CRITICAL HIT' : ' HIT')
              : ' MISS vs AC ${target.armorClass}';
        }
        if (hit) {
          final dmg = rollDamage(dice!, damageMod, isCritical: crit);
          text +=
              ' — ${dmg.rolls.join('+')}${damageMod != 0 ? " +$damageMod" : ""} = ${dmg.total} $type';
          if (target != null) {
            text += ' — ${await _damageEnemy(target, dmg.total)}';
            final survivor = _enemies(
              characterId,
            ).where((e) => e.id == target.id).firstOrNull;
            if (effect.condition != null && survivor != null) {
              await _addCondition(
                survivor,
                _spellConditionLabel(effect.condition!, spell.name),
              );
              text += ', ${effect.condition}';
            }
          }
        }
        _showRoll('$text$note');
        if (effect.secondary != null && context.mounted) {
          await _resolveSpellEffect(
            context,
            characterId,
            spell,
            effect.secondary!,
            slotLevel,
            rules,
            prefix: '${hit ? "Hit" : "Miss"} — then ',
          );
        }
        return;

      case SpellEffectKind.save:
        final enemies = _enemies(characterId);
        Map<int, bool>? outcomes = {};
        if (enemies.isNotEmpty && context.mounted) {
          outcomes = await showDialog<Map<int, bool>>(
            context: context,
            builder: (_) => _SaveTargetsDialog(
              title:
                  '${spell.name}: DC ${rules.saveDc} ${effect.saveAbility} save',
              enemies: enemies,
              multi: effect.multiTarget,
              preselected: _selectedEnemyId,
            ),
          );
          if (outcomes == null) return;
        }
        final dmg = dice != null ? rollDamage(dice, damageMod) : null;
        final extra = effect.extraDice != null
            ? rollDamage(effect.extraDice!, 0)
            : null;
        final parts = <String>[];
        for (final e in enemies) {
          final failed = outcomes[e.id];
          if (failed == null) continue;
          final full = (dmg?.total ?? 0) + (extra?.total ?? 0);
          final amount = failed ? full : (effect.halfOnSave ? full ~/ 2 : 0);
          var line = '${e.name} ${failed ? "fails" : "saves"}';
          if (amount > 0) line = '$line: ${await _damageEnemy(e, amount)}';
          if (failed && effect.condition != null) {
            final survivor = _enemies(
              characterId,
            ).where((x) => x.id == e.id).firstOrNull;
            if (survivor != null) {
              await _addCondition(
                survivor,
                _spellConditionLabel(effect.condition!, spell.name),
              );
              line = '$line, ${effect.condition}';
            }
          }
          parts.add(line);
        }
        final rollText = dmg == null
            ? ''
            : ' ${dmg.rolls.join('+')}${damageMod != 0 ? " +$damageMod" : ""} = ${dmg.total} $type'
                  '${extra != null ? " + ${extra.rolls.join('+')} = ${extra.total} ${effect.extraDamageType}" : ""}'
                  '${effect.halfOnSave ? " (half on save)" : ""}';
        _showRoll(
          '$prefix${spell.name}: DC ${rules.saveDc} ${effect.saveAbility}$rollText'
          '${effect.condition != null ? ", ${effect.condition} on a failed save" : ""}'
          '${parts.isEmpty ? "" : " — ${parts.join("; ")}"}$note',
        );
        return;
    }
  }

  /// Asks who receives healing (you or a party member) and applies it.
  Future<String> _healChosenTarget(
    BuildContext context,
    int characterId,
    int amount,
  ) async {
    final members =
        ref.read(partyMembersProvider(characterId)).value ?? const [];
    int? memberId;
    if (members.isNotEmpty) {
      final choice = await showDialog<int>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: const Text('Heal whom?'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(-1),
              child: const Text('Myself'),
            ),
            for (final m in members)
              SimpleDialogOption(
                onPressed: () => Navigator.of(ctx).pop(m.id),
                child: Text('${m.name} (${m.currentHp}/${m.maxHp} HP)'),
              ),
          ],
        ),
      );
      if (choice == null) return ' (not applied)';
      memberId = choice == -1 ? null : choice;
    }
    if (memberId == null) return _healSelf(characterId, amount);
    final m = members.firstWhere((x) => x.id == memberId);
    final newHp = (m.currentHp + amount).clamp(0, m.maxHp);
    await ref.read(appDatabaseProvider).updatePartyMemberHp(m.id, newHp);
    return ' → ${m.name}: $newHp/${m.maxHp} HP';
  }
}

/// Picks which enemies are affected by a saving-throw spell and whether each
/// one failed. Returns enemy id → failed.
class _SaveTargetsDialog extends StatefulWidget {
  final String title;
  final List<CombatEnemy> enemies;
  final bool multi;
  final int? preselected;

  const _SaveTargetsDialog({
    required this.title,
    required this.enemies,
    required this.multi,
    this.preselected,
  });

  @override
  State<_SaveTargetsDialog> createState() => _SaveTargetsDialogState();
}

class _SaveTargetsDialogState extends State<_SaveTargetsDialog> {
  /// enemy id → failed the save
  late final Map<int, bool> _outcomes = {
    if (widget.preselected != null &&
        widget.enemies.any((e) => e.id == widget.preselected))
      widget.preselected!: true
    else if (!widget.multi && widget.enemies.isNotEmpty)
      widget.enemies.first.id: true,
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 460,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              widget.multi
                  ? 'Tick every creature in the area, then mark who failed.'
                  : 'Choose the target, then mark the result.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            for (final e in widget.enemies)
              Row(
                children: [
                  Checkbox(
                    value: _outcomes.containsKey(e.id),
                    onChanged: (v) => setState(() {
                      if (!widget.multi) _outcomes.clear();
                      if (v == true) {
                        _outcomes[e.id] = true;
                      } else {
                        _outcomes.remove(e.id);
                      }
                    }),
                  ),
                  Expanded(child: Text('${e.name} (${e.currentHp} HP)')),
                  if (_outcomes.containsKey(e.id))
                    SegmentedButton<bool>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: true, label: Text('Failed')),
                        ButtonSegment(value: false, label: Text('Saved')),
                      ],
                      selected: {_outcomes[e.id]!},
                      onSelectionChanged: (s) =>
                          setState(() => _outcomes[e.id] = s.first),
                    ),
                ],
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
          onPressed: () => Navigator.of(context).pop(_outcomes),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
