import 'package:flutter/material.dart';
import '../../models/choice.dart';

/// Callback generico: data una Choice e l'id di un'opzione, gestisce la selezione.
typedef OnOptionSelected = void Function(Choice choice, String optionId);

class ChoiceCard extends StatelessWidget {
  final Choice choice;
  final Set<String> selectedOptionIds;
  final OnOptionSelected onOptionToggle;

  const ChoiceCard({
    super.key,
    required this.choice,
    required this.selectedOptionIds,
    required this.onOptionToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(choice.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...choice.options.map((option) {
              final isChecked = selectedOptionIds.contains(option.id);
              return CheckboxListTile(
                value: isChecked,
                title: Text(option.label),
                subtitle: option.description != null ? Text(option.description!) : null,
                onChanged: (_) => onOptionToggle(choice, option.id),
              );
            }),
          ],
        ),
      ),
    );
  }
}