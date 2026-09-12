import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database.dart';
import '../../data/xp_table.dart';
import '../../models/character_reconstruction.dart';
import '../../models/character_save_data.dart';
import '../../state/database_provider.dart';
import '../../state/inventory_provider.dart';
import '../widgets/character_sheet_body.dart';
import 'combat_screen.dart';
import 'level_up_screen.dart';

class SavedCharacterViewScreen extends ConsumerStatefulWidget {
  final SavedCharacter savedCharacter;

  const SavedCharacterViewScreen({super.key, required this.savedCharacter});

  @override
  ConsumerState<SavedCharacterViewScreen> createState() =>
      _SavedCharacterViewScreenState();
}

class _SavedCharacterViewScreenState
    extends ConsumerState<SavedCharacterViewScreen> {
  late int currentXp;
  late int currentLevel;
  late String currentDataJson;
  final TextEditingController _xpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentXp = widget.savedCharacter.xp;
    currentLevel = widget.savedCharacter.level;
    currentDataJson = widget.savedCharacter.dataJson;
  }

  @override
  void dispose() {
    _xpController.dispose();
    super.dispose();
  }

  Future<void> _addXp() async {
    final toAdd = int.tryParse(_xpController.text);
    if (toAdd == null || toAdd <= 0) return;

    final newXp = currentXp + toAdd;
    final potentialLevel = levelForXp(newXp).clamp(1, 20);

    final db = ref.read(appDatabaseProvider);
    await db.updateXpOnly(widget.savedCharacter.id, newXp);

    if (potentialLevel > currentLevel) {
      final latest = await db.getCharacterById(widget.savedCharacter.id);
      if (mounted) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => LevelUpScreen(
            savedCharacter: latest,
            pendingLevel: potentialLevel,
          ),
        );
      }
    }

    final refreshed = await db.getCharacterById(widget.savedCharacter.id);
    setState(() {
      currentXp = refreshed.xp;
      currentLevel = refreshed.level;
      currentDataJson = refreshed.dataJson;
      _xpController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final saveData = CharacterSaveData.fromJson(currentDataJson);
    final character = characterFromSaveData(
      saveData,
      id: widget.savedCharacter.id,
    );
    final inventoryAsync = ref.watch(
      characterInventoryProvider(widget.savedCharacter.id),
    );

    final currentThreshold = xpThresholds[currentLevel] ?? 0;
    final nextThreshold = currentLevel < 20
        ? xpThresholds[currentLevel + 1]
        : null;
    final progress = nextThreshold == null
        ? 1.0
        : (currentXp - currentThreshold) / (nextThreshold - currentThreshold);

    return Scaffold(
      appBar: AppBar(title: const Text('Character Sheet')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Level $currentLevel',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      nextThreshold != null
                          ? '$currentXp / $nextThreshold XP'
                          : 'Max level',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _xpController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Add XP',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: _addXp, child: const Text('Add')),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: inventoryAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
              data: (rows) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CombatScreen(character: character),
                      ),
                    ),
                    icon: const Icon(Icons.shield),
                    label: const Text('Combat'),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          Expanded(
            child: CharacterSheetBody(
              character: character,
              raceActiveChoices: character.race.choices,
              classActiveChoices: character.characterClass.levelFeatures
                  .where((f) => f.level <= character.level)
                  .expand((f) => f.choices)
                  .toList(),
              backgroundActiveChoices: character.background.choices,
            ),
          ),
        ],
      ),
    );
  }
}
