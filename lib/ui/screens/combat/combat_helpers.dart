part of '../combat_screen.dart';

/// Shared building blocks for the class sections: resource counters, spell
/// slots, feature cards and applying damage/healing.
extension _CombatHelpers on _CombatScreenState {
  int _resourceRemaining(List<CharacterResourceUse> rows, String id, int max) {
    final spent =
        rows.where((r) => r.resourceId == id).firstOrNull?.usesSpent ?? 0;
    return (max - spent).clamp(0, max);
  }

  int _slotMax(int spellLevel) =>
      fullCasterSlots(widget.character.level, spellLevel);

  int _slotRemaining(List<CharacterResourceUse> rows, int spellLevel) =>
      _resourceRemaining(
        rows,
        spellSlotResourceId(spellLevel),
        _slotMax(spellLevel),
      );

  Future<void> _spendResource(int characterId, String id, int max) =>
      ref.read(appDatabaseProvider).useResource(characterId, id, max);

  Future<void> _regainResource(int characterId, String id, {int amount = 1}) =>
      ref
          .read(appDatabaseProvider)
          .regainResource(characterId, id, amount: amount);

  Future<void> _spendSlot(int characterId, int spellLevel) => _spendResource(
    characterId,
    spellSlotResourceId(spellLevel),
    _slotMax(spellLevel),
  );

  void _showRoll(String text) => _update(() => _lastRollResult = text);

  Widget _featureCard(
    BuildContext context,
    String title,
    String subtitle,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            if (subtitle.isNotEmpty)
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            if (children.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: children,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Asks which spell slot level to expend, among those with slots left.
  Future<int?> _pickSlotLevel(
    BuildContext context,
    List<CharacterResourceUse> rows, {
    int minLevel = 1,
    String title = 'Expend which spell slot?',
  }) {
    final options = [
      for (var l = minLevel; l <= 9; l++)
        if (_slotRemaining(rows, l) > 0) l,
    ];
    if (options.isEmpty) {
      _showRoll('No spell slots of level $minLevel+ left.');
      return Future.value(null);
    }
    return showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(title),
        children: [
          for (final l in options)
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(l),
              child: Text(
                'Level $l (${_slotRemaining(rows, l)}/${_slotMax(l)} left)',
              ),
            ),
        ],
      ),
    );
  }

  /// Damages the selected enemy; returns a note for the roll banner.
  Future<String> _damageSelectedEnemy(int characterId, int amount) async {
    final enemies = ref.read(combatEnemiesProvider(characterId)).value ?? [];
    final target = enemies.where((e) => e.id == _selectedEnemyId).firstOrNull;
    if (target == null) return ' (no target selected)';
    final newHp = (target.currentHp - amount).clamp(0, target.maxHp);
    if (newHp <= 0) {
      await ref.read(appDatabaseProvider).removeEnemy(target.id);
      return ' — ${target.name} defeated!';
    }
    await ref.read(appDatabaseProvider).updateEnemyHp(target.id, newHp);
    return ' — ${target.name}: $newHp/${target.maxHp} HP left';
  }

  Future<String> _healSelf(int characterId, int amount) async {
    final maxHp = widget.character.totalHitPoints;
    final current =
        await ref.read(currentHpProvider(characterId).future) ?? maxHp;
    final newHp = (current + amount).clamp(0, maxHp);
    await ref.read(appDatabaseProvider).setCurrentHp(characterId, newHp);
    return ' → you: $newHp/$maxHp HP';
  }

  Widget _spellSlotsCard(
    BuildContext context,
    int characterId,
    List<CharacterResourceUse> rows,
  ) {
    return _featureCard(
      context,
      'Spell Slots',
      'Tap − to expend a slot, + to restore one. All slots return on a Long Rest.',
      [
        for (var l = 1; l <= 9; l++)
          if (_slotMax(l) > 0)
            Container(
              padding: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('L$l  ${_slotRemaining(rows, l)}/${_slotMax(l)}'),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.remove),
                    tooltip: 'Expend a level $l slot',
                    onPressed: _slotRemaining(rows, l) > 0
                        ? () => _spendSlot(characterId, l)
                        : null,
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.add),
                    tooltip: 'Restore a level $l slot',
                    onPressed: _slotRemaining(rows, l) < _slotMax(l)
                        ? () => _regainResource(
                            characterId,
                            spellSlotResourceId(l),
                          )
                        : null,
                  ),
                ],
              ),
            ),
      ],
    );
  }
}
