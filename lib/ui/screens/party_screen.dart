import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database.dart';
import '../../state/database_provider.dart';
import '../../state/party_provider.dart';

class PartyScreen extends ConsumerStatefulWidget {
  final int characterId;

  const PartyScreen({super.key, required this.characterId});

  @override
  ConsumerState<PartyScreen> createState() => _PartyScreenState();
}

class _PartyScreenState extends ConsumerState<PartyScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hpController = TextEditingController(text: '10');

  @override
  void dispose() {
    _nameController.dispose();
    _hpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final partyAsync = ref.watch(partyMembersProvider(widget.characterId));

    return Scaffold(
      appBar: AppBar(title: const Text('Party')),
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
                      'Add Party Member',
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
                              labelText: 'Max HP',
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
                          if (name.isEmpty) return;
                          await ref
                              .read(appDatabaseProvider)
                              .addPartyMember(widget.characterId, name, hp);
                          _nameController.clear();
                        },
                        child: const Text('Add'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: partyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (members) {
                if (members.isEmpty) {
                  return const Center(child: Text('No party members yet.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return Card(
                      child: ListTile(
                        title: Text(member.name),
                        subtitle: Text(
                          '${member.currentHp} / ${member.maxHp} HP',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => ref
                                  .read(appDatabaseProvider)
                                  .updatePartyMemberHp(
                                    member.id,
                                    (member.currentHp - 1).clamp(
                                      0,
                                      member.maxHp,
                                    ),
                                  ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => ref
                                  .read(appDatabaseProvider)
                                  .updatePartyMemberHp(
                                    member.id,
                                    (member.currentHp + 1).clamp(
                                      0,
                                      member.maxHp,
                                    ),
                                  ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => ref
                                  .read(appDatabaseProvider)
                                  .removePartyMember(member.id),
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
