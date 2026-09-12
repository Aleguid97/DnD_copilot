import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/currency.dart';
import '../../state/database_provider.dart';
import '../../state/gold_provider.dart';

class GoldSection extends ConsumerStatefulWidget {
  final int characterId;

  const GoldSection({super.key, required this.characterId});

  @override
  ConsumerState<GoldSection> createState() => _GoldSectionState();
}

class _GoldSectionState extends ConsumerState<GoldSection> {
  final TextEditingController _adjustController = TextEditingController(
    text: '0',
  );

  @override
  void dispose() {
    _adjustController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goldAsync = ref.watch(characterGoldProvider(widget.characterId));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Currency', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            goldAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Error: $e'),
              data: (totalCopper) {
                final display = CurrencyDisplay.fromCopper(totalCopper);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      display.toString(),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _adjustController,
                            keyboardType: const TextInputType.numberWithOptions(
                              signed: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Adjust GP (+earn / -spend)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final deltaGold = int.tryParse(
                              _adjustController.text,
                            );
                            if (deltaGold == null) return;
                            final newTotal = (totalCopper + deltaGold * 100)
                                .clamp(0, 1 << 30);
                            await ref
                                .read(appDatabaseProvider)
                                .setGold(widget.characterId, newTotal);
                            _adjustController.clear();
                          },
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
