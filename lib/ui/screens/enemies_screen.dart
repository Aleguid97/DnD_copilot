import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database.dart';
import '../../state/database_provider.dart';
import '../../state/enemies_provider.dart';

class EnemiesScreen extends ConsumerStatefulWidget {
  final int characterId;

  const EnemiesScreen({super.key, required this.characterId});

  @override
  ConsumerState<EnemiesScreen> createState() => _EnemiesScreenState();
}

class _EnemiesScreenState extends ConsumerState<EnemiesScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hpController = TextEditingController(text: '10');
  final TextEditingController _acController = TextEditingController(text: '10');

  @override
  void dispose() {
    _nameController.dispose();
    _hpController.dispose();
    _acController.dispose();
    super.dispose();
  }

  List<String> _parseConditions(String json) {
    try {
      return List<String>.from(jsonDecode(json) as List);
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final enemiesAsync = ref.watch(combatEnemiesProvider(widget.characterId));

    return Scaffold(
      appBar: AppBar(title: const Text('Enemies')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Enemy',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _hpController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'HP',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _acController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'AC',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = _nameController.text.trim();
                          final hp = int.tryParse(_hpController.text) ?? 10;
                          final ac = int.tryParse(_acController.text) ?? 10;
                          if (name.isEmpty) return;
                          await ref
                              .read(appDatabaseProvider)
                              .addEnemy(
                                widget.characterId,
                                name,
                                hp,
                                armorClass: ac,
                              );
                          _nameController.clear();
                        },
                        child: const Text('Add Enemy'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: enemiesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (enemies) {
                if (enemies.isEmpty) {
                  return const Center(child: Text('No enemies tracked yet.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: enemies.length,
                  itemBuilder: (context, index) {
                    final enemy = enemies[index];
                    final conditions = _parseConditions(enemy.conditionsJson);
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
                                  enemy.name,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => ref
                                      .read(appDatabaseProvider)
                                      .removeEnemy(enemy.id),
                                ),
                              ],
                            ),
                            Text(
                              'AC ${enemy.armorClass} • HP ${enemy.currentHp} / ${enemy.maxHp}',
                            ),
                            if (conditions.isNotEmpty)
                              Wrap(
                                spacing: 6,
                                children: conditions
                                    .map((c) => Chip(label: Text(c)))
                                    .toList(),
                              ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => ref
                                      .read(appDatabaseProvider)
                                      .updateEnemyHp(
                                        enemy.id,
                                        (enemy.currentHp - 1).clamp(
                                          0,
                                          enemy.maxHp,
                                        ),
                                      ),
                                ),
                                Text('${enemy.currentHp}'),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => ref
                                      .read(appDatabaseProvider)
                                      .updateEnemyHp(
                                        enemy.id,
                                        (enemy.currentHp + 1).clamp(
                                          0,
                                          enemy.maxHp,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
