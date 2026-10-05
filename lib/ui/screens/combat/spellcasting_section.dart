part of '../combat_screen.dart';

/// Per-class spellcasting rules the section needs. Add a class here once its
/// spell list is in spells_data.dart.
class _CasterRules {
  final int cantrips;
  final int prepared;
  final List<String> alwaysPreparedNames;
  final int saveDc;
  final int attackBonus;

  const _CasterRules({
    required this.cantrips,
    required this.prepared,
    required this.alwaysPreparedNames,
    required this.saveDc,
    required this.attackBonus,
  });
}

extension _SpellcastingSection on _CombatScreenState {
  _CasterRules? _casterRules(int profBonus) {
    final c = widget.character;
    switch (c.characterClass.id) {
      case 'druid':
        return _CasterRules(
          cantrips: druidCantripCount(c),
          prepared: druidPreparedSpellCount(c.level),
          alwaysPreparedNames: druidAlwaysPreparedNames(c),
          saveDc: druidSpellSaveDc(c, profBonus),
          attackBonus: druidSpellAttackBonus(c, profBonus),
        );
    }
    return null;
  }

  String get _cantripsKey => '${widget.character.characterClass.id}_cantrips';
  String get _preparedKey =>
      '${widget.character.characterClass.id}_prepared_spells';

  List<String> get _knownCantrips =>
      _cantripsOverride ??
      (widget.character.classSelections[_cantripsKey]?.toList() ?? const []);

  List<String> get _preparedSpellIds =>
      _preparedOverride ??
      (widget.character.classSelections[_preparedKey]?.toList() ?? const []);

  int get _maxSlotLevel {
    for (var l = 9; l >= 1; l--) {
      if (_slotMax(l) > 0) return l;
    }
    return 0;
  }

  /// Why the character can't cast [spell] right now, or null if they can.
  String? _castBlockedReason(Spell? spell, String name) {
    final c = widget.character;
    if (c.characterClass.id == 'druid' && _wildShapeActive) {
      final moonCircleSpell =
          druidSubclass(c) == 'moon' &&
          druidCircleSpells(
            c,
          ).any((n) => n.toLowerCase() == name.toLowerCase());
      if (c.level < 18 && !moonCircleSpell) return 'Not in Wild Shape';
    }
    return null;
  }

  /// Spellcasting: slots, concentration, cantrips and prepared spells.
  List<Widget> _buildSpellcastingSection(BuildContext context, _CombatData d) {
    final characterId = d.characterId;
    final rules = _casterRules(d.profBonus);
    if (characterId == null ||
        rules == null ||
        !hasSpellcastingSupport(widget.character.characterClass.id)) {
      return const [];
    }
    final theme = Theme.of(context);
    return [
      const SizedBox(height: 24),
      Text('Spellcasting', style: theme.textTheme.titleMedium),
      Text(
        'Spell save DC ${rules.saveDc} · Spell attack +${rules.attackBonus}',
        style: theme.textTheme.bodySmall,
      ),
      const SizedBox(height: 8),
      d.resourceUsesAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (e, st) => Text('Error: $e'),
        data: (rows) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_concentrationSpell != null)
              Card(
                color: theme.colorScheme.tertiaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.center_focus_strong),
                  title: Text('Concentrating on $_concentrationSpell'),
                  subtitle: const Text(
                    'Casting another Concentration spell ends it.',
                  ),
                  trailing: OutlinedButton(
                    onPressed: () => _update(() {
                      _lastRollResult =
                          'Concentration on $_concentrationSpell ended.';
                      _concentrationSpell = null;
                    }),
                    child: const Text('End'),
                  ),
                ),
              ),
            if (_maxSlotLevel > 0) _spellSlotsCard(context, characterId, rows),
            _cantripsCard(context, characterId, rules),
            _preparedSpellsCard(context, characterId, rows, rules),
          ],
        ),
      ),
    ];
  }

  Widget _cantripsCard(
    BuildContext context,
    int characterId,
    _CasterRules rules,
  ) {
    final known = _knownCantrips;
    return _featureCard(
      context,
      'Cantrips (${known.length}/${rules.cantrips})',
      known.isEmpty ? 'No cantrips chosen yet.' : 'Tap to cast (no slot).',
      [
        for (final id in known)
          ActionChip(
            label: Text(allSpells[id]?.name ?? id),
            onPressed:
                _castBlockedReason(allSpells[id], allSpells[id]?.name ?? id) ==
                    null
                ? () => _castSpell(context, characterId, const [], id: id)
                : null,
          ),
        TextButton.icon(
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Change'),
          onPressed: () => _manageSpellsDialog(
            context,
            characterId,
            title: 'Known cantrips',
            selectionKey: _cantripsKey,
            limit: rules.cantrips,
            candidates: [
              for (final id
                  in classSpellLists[widget.character.characterClass.id]!)
                if (allSpells[id]!.isCantrip) allSpells[id]!,
            ],
            current: known,
            onSaved: (ids) => _cantripsOverride = ids,
          ),
        ),
      ],
    );
  }

  Widget _preparedSpellsCard(
    BuildContext context,
    int characterId,
    List<CharacterResourceUse> rows,
    _CasterRules rules,
  ) {
    final theme = Theme.of(context);
    final prepared = _preparedSpellIds;
    final always = rules.alwaysPreparedNames;
    final alwaysIds = {
      for (final n in always)
        if (spellByName(n) != null) spellByName(n)!.id,
    };

    // (name, spell or null if not catalogued yet, always prepared?)
    final entries = <(String, Spell?, bool)>[
      for (final n in always)
        if (!(spellByName(n)?.isCantrip ?? false)) (n, spellByName(n), true),
      for (final id in prepared)
        if (!alwaysIds.contains(id))
          (allSpells[id]?.name ?? id, allSpells[id], false),
    ]..sort((a, b) => (a.$2?.level ?? 0).compareTo(b.$2?.level ?? 0));

    final alwaysCantrips = [
      for (final n in always)
        if (spellByName(n)?.isCantrip ?? false) n,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Prepared Spells (${prepared.where((id) => !alwaysIds.contains(id)).length}/${rules.prepared} + always prepared)',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Change'),
                  onPressed: () => _manageSpellsDialog(
                    context,
                    characterId,
                    title: 'Prepared spells',
                    selectionKey: _preparedKey,
                    limit: rules.prepared,
                    candidates: [
                      for (final id
                          in classSpellLists[widget
                              .character
                              .characterClass
                              .id]!)
                        if (!allSpells[id]!.isCantrip &&
                            allSpells[id]!.level <= _maxSlotLevel &&
                            !alwaysIds.contains(id))
                          allSpells[id]!,
                    ],
                    current: [
                      for (final id in prepared)
                        if (!alwaysIds.contains(id)) id,
                    ],
                    onSaved: (ids) => _preparedOverride = ids,
                  ),
                ),
              ],
            ),
            Text(
              'Casting expends a slot of the spell\'s level or higher (choose a higher slot to upcast).',
              style: theme.textTheme.bodySmall,
            ),
            if (alwaysCantrips.isNotEmpty)
              Text(
                'Always-prepared cantrips: ${alwaysCantrips.join(', ')}',
                style: theme.textTheme.bodySmall,
              ),
            for (final (name, spell, isAlways) in entries)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(name),
                subtitle: Text(
                  [
                    spell == null
                        ? 'level not catalogued'
                        : 'Level ${spell.level}',
                    if (spell != null) spell.school,
                    if (spell != null && spell.tags.isNotEmpty) spell.tags,
                    if (isAlways) 'always prepared',
                  ].join(' · '),
                ),
                trailing: Builder(
                  builder: (context) {
                    final blocked = _castBlockedReason(spell, name);
                    return OutlinedButton(
                      onPressed: blocked == null
                          ? () => _castSpell(
                              context,
                              characterId,
                              rows,
                              id: spell?.id,
                              name: name,
                            )
                          : null,
                      child: Text(blocked ?? 'Cast'),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Casts a spell: cantrips are free; leveled spells expend a slot of the
  /// spell's level or higher. Concentration replaces the current one.
  Future<void> _castSpell(
    BuildContext context,
    int characterId,
    List<CharacterResourceUse> rows, {
    String? id,
    String? name,
  }) async {
    final spell = id != null ? allSpells[id] : null;
    final spellName = spell?.name ?? name ?? id ?? '?';
    var slotNote = '';
    if (spell == null || !spell.isCantrip) {
      final minLevel = spell?.level ?? 1;
      final slot = await _pickSlotLevel(
        context,
        rows,
        minLevel: minLevel,
        title: 'Cast $spellName with which slot?',
      );
      if (slot == null) return;
      await _spendSlot(characterId, slot);
      slotNote = spell != null && slot > spell.level
          ? ' using a level $slot slot (upcast)'
          : ' using a level $slot slot';
    }
    var concentrationNote = '';
    if (spell?.concentration ?? false) {
      if (_concentrationSpell != null && _concentrationSpell != spellName) {
        concentrationNote = ' — Concentration on $_concentrationSpell ended';
      }
      concentrationNote += ' — Concentrating';
    }
    _update(() {
      if (spell?.concentration ?? false) _concentrationSpell = spellName;
      _lastRollResult = 'Cast $spellName$slotNote$concentrationNote.';
    });
  }

  Future<void> _manageSpellsDialog(
    BuildContext context,
    int characterId, {
    required String title,
    required String selectionKey,
    required int limit,
    required List<Spell> candidates,
    required List<String> current,
    required void Function(List<String>) onSaved,
  }) async {
    final chosen = {...current};
    final result = await showDialog<List<String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text('$title (${chosen.length}/$limit)'),
          content: SizedBox(
            width: 420,
            height: 480,
            child: ListView(
              children: [
                for (final s in candidates)
                  CheckboxListTile(
                    dense: true,
                    value: chosen.contains(s.id),
                    title: Text(s.name),
                    subtitle: Text(
                      [
                        s.isCantrip ? 'Cantrip' : 'Level ${s.level}',
                        s.school,
                        if (s.tags.isNotEmpty) s.tags,
                      ].join(' · '),
                    ),
                    onChanged: chosen.contains(s.id) || chosen.length < limit
                        ? (v) => setDialog(() {
                            if (v == true) {
                              chosen.add(s.id);
                            } else {
                              chosen.remove(s.id);
                            }
                          })
                        : null,
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(chosen.toList()),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    await ref
        .read(appDatabaseProvider)
        .updateClassSelection(characterId, selectionKey, result);
    _update(() {
      onSaved(result);
      _lastRollResult = '$title updated (${result.length}/$limit).';
    });
  }
}
