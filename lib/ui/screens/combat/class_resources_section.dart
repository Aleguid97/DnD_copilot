part of '../combat_screen.dart';

extension _ClassResourcesSection on _CombatScreenState {
  /// Generic class resource trackers.
  List<Widget> _buildClassResourcesSection(
    BuildContext context,
    _CombatData d,
  ) {
    final characterId = d.characterId;
    final availableResources = d.availableResources;
    final resourceUsesAsync = d.resourceUsesAsync;
    return [
      if (availableResources.isNotEmpty) ...[
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Class Resources',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (characterId != null)
              PopupMenuButton<RestType>(
                child: const Chip(label: Text('Rest')),
                onSelected: (restType) async {
                  await ref
                      .read(appDatabaseProvider)
                      .applyRest(characterId, restType, availableResources);
                  _update(() => _relentlessRageUsesSinceRest = 0);
                  if (restType == RestType.long) {
                    final swapInfo = swapInfoFor(
                      widget.character.race.id,
                      widget.character.raceSelections,
                    );
                    if (swapInfo != null && context.mounted) {
                      final chosen = await showDialog<String>(
                        context: context,
                        builder: (ctx) => SimpleDialog(
                          title: const Text('Swap racial cantrip? (Long Rest)'),
                          children: swapInfo.availableCantrips.entries
                              .map(
                                (e) => SimpleDialogOption(
                                  onPressed: () => Navigator.of(ctx).pop(e.key),
                                  child: Text(e.value),
                                ),
                              )
                              .toList(),
                        ),
                      );
                      if (chosen != null) {
                        await ref
                            .read(appDatabaseProvider)
                            .setRacialCantripOverride(characterId, chosen);
                      }
                    }
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: RestType.short,
                    child: Text('Short Rest'),
                  ),
                  PopupMenuItem(value: RestType.long, child: Text('Long Rest')),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        resourceUsesAsync.when(
          loading: () => const CircularProgressIndicator(),
          error: (e, st) => Text('Error: $e'),
          data: (usesRows) {
            return Column(
              children: availableResources
                  .where(
                    (r) =>
                        r.id != 'war_priest' &&
                        r.id != 'second_wind' &&
                        r.id != 'indomitable' &&
                        r.id != 'rage' &&
                        r.id != 'warrior_of_the_gods_pool' &&
                        r.id != 'zealous_presence' &&
                        r.id != 'luck_points' &&
                        !isSpellSlotResource(r.id) &&
                        !druidSectionResourceIds.contains(r.id),
                  )
                  .map((resource) {
                    final maxUses = resource.maxUses(widget.character.level);
                    final row = usesRows
                        .where((r) => r.resourceId == resource.id)
                        .firstOrNull;
                    final spent = row?.usesSpent ?? 0;
                    final remaining = (maxUses - spent).clamp(0, maxUses);
                    return Card(
                      child: ListTile(
                        title: Text(resource.name),
                        subtitle: Text(
                          '$remaining / $maxUses remaining · ${resource.recoveryText}',
                        ),
                        trailing: ElevatedButton(
                          onPressed: remaining > 0 && characterId != null
                              ? () => ref
                                    .read(appDatabaseProvider)
                                    .useResource(
                                      characterId,
                                      resource.id,
                                      maxUses,
                                    )
                              : null,
                          child: const Text('Use'),
                        ),
                      ),
                    );
                  })
                  .toList(),
            );
          },
        ),
      ],
    ];
  }
}
