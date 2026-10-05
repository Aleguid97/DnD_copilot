part of '../combat_screen.dart';

extension _FighterSection on _CombatScreenState {
  /// Fighter features (Tactical Mind).
  List<Widget> _buildFighterSection(BuildContext context, _CombatData d) {
    final characterId = d.characterId;
    final resourceUsesAsync = d.resourceUsesAsync;
    return [
      if (widget.character.characterClass.id == 'fighter' &&
          widget.character.level >= 2 &&
          characterId != null) ...[
        const SizedBox(height: 8),
        resourceUsesAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (e, st) => const SizedBox.shrink(),
          data: (usesRows) {
            final swResource = (classResources['fighter'] ?? []).firstWhere(
              (r) => r.id == 'second_wind',
            );
            final maxUses = swResource.maxUses(widget.character.level);
            final row = usesRows
                .where((r) => r.resourceId == 'second_wind')
                .firstOrNull;
            final spent = row?.usesSpent ?? 0;
            final remaining = (maxUses - spent).clamp(0, maxUses);
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tactical Mind',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      _lastSkillRollForCorrection != null
                          ? 'Last check: $_lastSkillRolledName = $_lastSkillRollForCorrection. Second Wind uses: $remaining/$maxUses.'
                          : 'Roll a Skill Check above first.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                (remaining > 0 &&
                                    _lastSkillRollForCorrection != null)
                                ? () {
                                    final bonus = rollDamage('1d10', 0);
                                    final newTotal =
                                        _lastSkillRollForCorrection! +
                                        bonus.total;
                                    _update(() {
                                      _lastRollResult =
                                          'Tactical Mind: +${bonus.total} → $_lastSkillRolledName new total: $newTotal (did it succeed?)';
                                      _lastSkillRollForCorrection = newTotal;
                                    });
                                  }
                                : null,
                            child: const Text('Add 1d10'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => ref
                                .read(appDatabaseProvider)
                                .useResource(
                                  characterId,
                                  'second_wind',
                                  maxUses,
                                ),
                            child: const Text('It worked (spend use)'),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'If the check still fails, don\'t press "It worked" — the use stays free.',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    ];
  }
}
