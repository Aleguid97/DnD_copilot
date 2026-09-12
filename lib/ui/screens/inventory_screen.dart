import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database.dart';
import '../../data/items_data.dart';
import '../../models/item.dart';
import '../../state/database_provider.dart';
import '../../state/inventory_provider.dart';
import '../../models/dice_roller.dart';
import '../../state/current_hp_provider.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  final int characterId;
  final int maxHp;

  const InventoryScreen({
    super.key,
    required this.characterId,
    required this.maxHp,
  });

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(
      characterInventoryProvider(widget.characterId),
    );

    final matches = _query.isEmpty
        ? <GameItem>[]
        : allItems
              .where((i) => i.name.toLowerCase().contains(_query.toLowerCase()))
              .take(8)
              .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search items',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          if (matches.isNotEmpty)
            Expanded(
              flex: 0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: ListView.builder(
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final item = matches[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                        [
                          if (item.damage != null) item.damage!,
                          if (item.armorClass != null) 'AC ${item.armorClass}',
                          '${item.weightLbs} lb',
                          item.costDisplay,
                        ].join(' • '),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () async {
                          await ref
                              .read(appDatabaseProvider)
                              .addInventoryItem(widget.characterId, item.id);
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: inventoryAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (rows) {
                if (rows.isEmpty) {
                  return const Center(
                    child: Text('No items yet. Search above to add some.'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rows.length,
                  itemBuilder: (context, index) {
                    final row = rows[index];
                    final item = allItems.firstWhere(
                      (i) => i.id == row.itemId,
                      orElse: () => GameItem(
                        id: row.itemId,
                        name: row.itemId,
                        category: ItemCategory.simpleMeleeWeapon,
                        costInCopper: 0,
                        weightLbs: 0,
                      ),
                    );
                    final isHealingPotion = item.id == 'potion_of_healing';
                    return Card(
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                          [
                            if (item.damage != null) item.damage!,
                            if (item.armorClass != null)
                              'AC ${item.armorClass}',
                            'Qty: ${row.quantity}',
                          ].join(' • '),
                        ),
                        leading: _isEquippable(item)
                            ? Builder(
                                builder: (context) {
                                  final handsUsed = rows
                                      .where(
                                        (r) => r.equipped && r.id != row.id,
                                      )
                                      .fold<int>(0, (sum, r) {
                                        final otherItem = allItems
                                            .where((i) => i.id == r.itemId)
                                            .firstOrNull;
                                        return sum +
                                            (otherItem?.handsRequired ?? 0);
                                      });
                                  final wouldExceed =
                                      !row.equipped &&
                                      (handsUsed + item.handsRequired) > 2;
                                  return Checkbox(
                                    value: row.equipped,
                                    onChanged: wouldExceed
                                        ? null
                                        : (v) => ref
                                              .read(appDatabaseProvider)
                                              .toggleEquipped(
                                                row.id,
                                                v ?? false,
                                              ),
                                  );
                                },
                              )
                            : const SizedBox(width: 24),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isHealingPotion)
                              IconButton(
                                icon: const Icon(Icons.local_drink),
                                tooltip: 'Drink (heal 2d4+2)',
                                onPressed: () async {
                                  final healResult = rollDamage('2d4', 2);
                                  final currentHpValue = await ref.read(
                                    currentHpProvider(
                                      widget.characterId,
                                    ).future,
                                  );
                                  final baseline =
                                      currentHpValue ?? widget.maxHp;
                                  final newHp = (baseline + healResult.total)
                                      .clamp(0, widget.maxHp);
                                  await ref
                                      .read(appDatabaseProvider)
                                      .setCurrentHp(widget.characterId, newHp);
                                  await ref
                                      .read(appDatabaseProvider)
                                      .setInventoryQuantity(
                                        row.id,
                                        row.quantity - 1,
                                      );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Healed ${healResult.total} HP (rolled ${healResult.rolls.join('+')} +2)',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => ref
                                  .read(appDatabaseProvider)
                                  .setInventoryQuantity(
                                    row.id,
                                    row.quantity - 1,
                                  ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => ref
                                  .read(appDatabaseProvider)
                                  .setInventoryQuantity(
                                    row.id,
                                    row.quantity + 1,
                                  ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => ref
                                  .read(appDatabaseProvider)
                                  .removeInventoryItem(row.id),
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

  static const Set<String> _equippableGearIds = {
    'arcane_focus',
    'druidic_focus',
    'holy_symbol', // also usable as a Spellcasting Focus by Clerics/Paladins
  };

  bool _isEquippable(GameItem item) {
    final isWeaponArmorOrShield =
        item.category == ItemCategory.simpleMeleeWeapon ||
        item.category == ItemCategory.simpleRangedWeapon ||
        item.category == ItemCategory.martialMeleeWeapon ||
        item.category == ItemCategory.martialRangedWeapon ||
        item.category == ItemCategory.lightArmor ||
        item.category == ItemCategory.mediumArmor ||
        item.category == ItemCategory.heavyArmor ||
        item.category == ItemCategory.shield;
    return isWeaponArmorOrShield || _equippableGearIds.contains(item.id);
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
