import '../models/class_resource.dart';

final Map<String, List<ClassResource>> classResources = {
  'fighter': [
    ClassResource(
      id: 'second_wind',
      name: 'Second Wind',
      maxUses: (level) => 2,
      availableFromLevel: 1,
      fullRecoveryOn: RestType.short,
    ),
    ClassResource(
      id: 'action_surge',
      name: 'Action Surge',
      maxUses: (level) => level >= 17 ? 2 : 1,
      availableFromLevel: 2,
      fullRecoveryOn: RestType.short,
    ),
    ClassResource(
      id: 'indomitable',
      name: 'Indomitable',
      maxUses: (level) =>
          level >= 17 ? 3 : (level >= 13 ? 2 : (level >= 9 ? 1 : 0)),
      availableFromLevel: 9,
      fullRecoveryOn: RestType.long,
    ),
  ],
  'cleric': [
    ClassResource(
      id: 'channel_divinity',
      name: 'Channel Divinity',
      maxUses: (level) => 2,
      availableFromLevel: 2,
      fullRecoveryOn: RestType.long,
      shortRestPartialRecovery: 1,
    ),
    ClassResource(
      id: 'war_priest',
      name: 'War Priest (bonus action attack)',
      maxUses: (level) =>
          0, // overridden dynamically by Wisdom modifier — see combat_screen.dart
      availableFromLevel: 3,
      fullRecoveryOn: RestType.short,
    ),
  ],
  'barbarian': [
    ClassResource(
      id: 'rage',
      name: 'Rage',
      maxUses: (level) {
        if (level >= 17) return 6;
        if (level >= 12) return 5;
        if (level >= 6) return 4;
        if (level >= 3) return 3;
        return 2;
      },
      availableFromLevel: 1,
      fullRecoveryOn: RestType.long,
      shortRestPartialRecovery: 1,
    ),
  ],
};
