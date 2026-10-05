import '../models/class_resource.dart';
import '../models/barbarian_features.dart';
import '../models/druid_features.dart';
import 'spell_slots_data.dart';

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
    ...fullCasterSlotResources,
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
    ClassResource(
      id: 'warrior_of_the_gods_pool',
      name: 'Warrior of the Gods (d12 healing pool)',
      maxUses: warriorOfTheGodsPoolSize,
      availableFromLevel: 3,
      fullRecoveryOn: RestType.long,
    ),
    ClassResource(
      id: 'zealous_presence',
      name: 'Zealous Presence',
      maxUses: (level) => 1,
      availableFromLevel: 10,
      fullRecoveryOn: RestType.long,
    ),

    ClassResource(
      id: 'intimidating_presence',
      name: 'Intimidating Presence',
      maxUses: (level) => 1,
      availableFromLevel: 14,
      fullRecoveryOn: RestType.long,
    ),
  ],
  'druid': [
    ...fullCasterSlotResources,
    ClassResource(
      id: 'wild_shape',
      name: 'Wild Shape',
      maxUses: wildShapeUses,
      availableFromLevel: 2,
      fullRecoveryOn: RestType.long,
      shortRestPartialRecovery: 1,
    ),
    ClassResource(
      id: 'wild_resurgence_slot',
      name: 'Wild Resurgence (Wild Shape → level 1 slot)',
      maxUses: (level) => 1,
      availableFromLevel: 5,
      fullRecoveryOn: RestType.long,
    ),
    ClassResource(
      id: 'nature_magician',
      name: 'Archdruid: Nature Magician',
      maxUses: (level) => 1,
      availableFromLevel: 20,
      fullRecoveryOn: RestType.long,
    ),
    // Subclass resources below are shown only in the Druid section, which
    // filters them by circle and computes Wisdom-based maximums.
    ClassResource(
      id: 'natural_recovery_spell',
      name: 'Natural Recovery (free Circle spell)',
      maxUses: (level) => 1,
      availableFromLevel: 6,
      fullRecoveryOn: RestType.long,
    ),
    ClassResource(
      id: 'natural_recovery_slots',
      name: 'Natural Recovery (recover slots)',
      maxUses: (level) => 1,
      availableFromLevel: 6,
      fullRecoveryOn: RestType.long,
    ),
    ClassResource(
      id: 'moonlight_step',
      name: 'Moonlight Step',
      maxUses: (level) => 0, // Wisdom modifier (min 1), see druid_section.dart
      availableFromLevel: 10,
      fullRecoveryOn: RestType.long,
    ),
    ClassResource(
      id: 'star_map_guiding_bolt',
      name: 'Star Map: free Guiding Bolt',
      maxUses: (level) => 0, // Wisdom modifier (min 1), see druid_section.dart
      availableFromLevel: 3,
      fullRecoveryOn: RestType.long,
    ),
    ClassResource(
      id: 'cosmic_omen',
      name: 'Cosmic Omen',
      maxUses: (level) => 0, // Wisdom modifier (min 1), see druid_section.dart
      availableFromLevel: 6,
      fullRecoveryOn: RestType.long,
    ),
  ],
};
