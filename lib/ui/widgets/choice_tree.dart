import 'package:flutter/material.dart';
import '../../models/choice.dart';
import 'choice_card.dart';

class ChoiceTree extends StatelessWidget {
  final List<Choice> choices;
  final Map<String, Set<String>> selections;
  final OnOptionSelected onOptionToggle;
  final double indent;

  const ChoiceTree({
    super.key,
    required this.choices,
    required this.selections,
    required this.onOptionToggle,
    this.indent = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: choices.map((choice) {
        final selected = selections[choice.id] ?? const {};
        return Padding(
          padding: EdgeInsets.only(left: indent, top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChoiceCard(
                choice: choice,
                selectedOptionIds: selected,
                onOptionToggle: onOptionToggle,
              ),
              ...choice.options
                  .where(
                    (o) =>
                        selected.contains(o.id) && o.unlockedChoices.isNotEmpty,
                  )
                  .map(
                    (o) => ChoiceTree(
                      choices: o.unlockedChoices,
                      selections: selections,
                      onOptionToggle: onOptionToggle,
                      indent: indent + 16,
                    ),
                  ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
