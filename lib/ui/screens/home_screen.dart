import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/database_provider.dart';
import '../../state/saved_characters_provider.dart';
import 'character_basics_screen.dart';
import 'saved_character_view_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charactersAsync = ref.watch(savedCharactersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('D&D Copilot')),
      body: charactersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (characters) {
          if (characters.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_stories,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No characters yet',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tap the button below to start creating your first character.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final c = characters[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: c.imagePath != null
                        ? FileImage(File(c.imagePath!))
                        : null,
                    child: c.imagePath == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(c.name),
                  subtitle: Text('${c.raceId} ${c.classId} — Level ${c.level}'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          SavedCharacterViewScreen(savedCharacter: c),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete character?'),
                          content: Text(
                            'This will permanently delete ${c.name}.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await ref
                            .read(appDatabaseProvider)
                            .deleteCharacter(c.id);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CharacterBasicsScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Character'),
      ),
    );
  }
}
