class Spell {
  final String id;
  final String name;

  /// 0 for cantrips.
  final int level;
  final String school;
  final bool concentration;
  final bool ritual;

  /// Requires a specific Material component.
  final bool material;

  const Spell(
    this.id,
    this.name,
    this.level,
    this.school, {
    this.concentration = false,
    this.ritual = false,
    this.material = false,
  });

  bool get isCantrip => level == 0;

  /// "C, R, M" tags as printed in the PHB spell lists.
  String get tags =>
      [if (concentration) 'C', if (ritual) 'R', if (material) 'M'].join(', ');
}
