import 'package:flutter/material.dart';
import '../../models/character.dart';
import '../../models/character_spells.dart';

class SpellListScreen extends StatelessWidget {
  final Character character;

  const SpellListScreen({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    final spellbook = characterSpellbook(character);

    return Scaffold(
      appBar: AppBar(title: const Text('Spells')),
      body: spellbook.isEmpty
          ? const Center(child: Text('This character knows no spells.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (spellbook.cantrips.isNotEmpty) ...[
                  Text(
                    'Cantrips',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ...spellbook.cantrips.map(
                    (s) => _SpellGroupCard(selection: s),
                  ),
                  const SizedBox(height: 16),
                ],
                if (spellbook.spells.isNotEmpty) ...[
                  Text('Spells', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...spellbook.spells.map((s) => _SpellGroupCard(selection: s)),
                ],
              ],
            ),
    );
  }
}

class _SpellGroupCard extends StatelessWidget {
  final SpellSelection selection;

  const _SpellGroupCard({required this.selection});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selection.sourceTitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: selection.spellNames
                  .map((name) => Chip(label: Text(name)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
