import 'choice.dart';

/// Given a list of top-level choices and the selections made so far,
/// returns the full list of "active" choices — including any nested
/// choices unlocked by previously selected options.
List<Choice> flattenChoicesWithUnlocked(
  List<Choice> choices,
  Map<String, Set<String>> selections,
) {
  final result = <Choice>[];
  for (final choice in choices) {
    result.add(choice);
    final selectedIds = selections[choice.id] ?? const {};
    for (final option in choice.options) {
      if (selectedIds.contains(option.id)) {
        result.addAll(
          flattenChoicesWithUnlocked(option.unlockedChoices, selections),
        );
      }
    }
  }
  return result;
}
