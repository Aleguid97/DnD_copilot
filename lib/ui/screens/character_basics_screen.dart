import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../state/character_basics_provider.dart';
import '../../services/image_picker_service.dart';
import 'race_selection_screen.dart';

class CharacterBasicsScreen extends ConsumerWidget {
  const CharacterBasicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final basics = ref.watch(characterBasicsNotifierProvider);
    final notifier = ref.read(characterBasicsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Character Basics')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () async {
                        final newPath = await pickAndStoreCharacterImage();
                        if (newPath != null) {
                          notifier.setImagePath(newPath);
                        }
                      },
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            backgroundImage: basics.imagePath != null
                                ? FileImage(File(basics.imagePath!))
                                : null,
                            child: basics.imagePath == null
                                ? Icon(
                                    Icons.person,
                                    size: 48,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              child: Icon(
                                Icons.add_a_photo,
                                size: 16,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    basics.imagePath != null
                        ? 'Tap to change photo'
                        : 'Tap to add a photo',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Character Name *',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: notifier.setName,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => notifier.setAge(int.tryParse(v)),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Height',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: notifier.setHeight,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: notifier.setWeight,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: basics.isComplete
                  ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RaceSelectionScreen(),
                      ),
                    )
                  : null,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
