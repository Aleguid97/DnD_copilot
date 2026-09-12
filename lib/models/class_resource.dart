enum RestType { short, long }

class ClassResource {
  final String id;
  final String name;
  final int Function(int level) maxUses;
  final int availableFromLevel;
  final RestType
  fullRecoveryOn; // short = full recovery on Short or Long Rest; long = only on Long Rest
  final int
  shortRestPartialRecovery; // extra uses regained on a Short Rest even if fullRecoveryOn == long

  const ClassResource({
    required this.id,
    required this.name,
    required this.maxUses,
    required this.availableFromLevel,
    required this.fullRecoveryOn,
    this.shortRestPartialRecovery = 0,
  });
}
