import '../models/character.dart';
import '../models/class_resource.dart';
import '../models/barbarian_features.dart';
import '../models/cleric_features.dart';
import '../models/druid_features.dart';
import '../models/fighter_features.dart';
import 'spell_slots_data.dart';
import 'xp_table.dart';

final Map<String, List<ClassResource>> classResources = {
  'fighter': [
    ClassResource(
      id: 'second_wind',
      name: 'Second Wind',
      maxUses: secondWindUses,
      availableFromLevel: 1,
      fullRecoveryOn: RestType.long,
      shortRestPartialRecovery: 1,
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
      maxUses: channelDivinityUses,
      availableFromLevel: 2,
      fullRecoveryOn: RestType.long,
      shortRestPartialRecovery: 1,
    ),
    ClassResource(
      id: 'divine_intervention',
      name: 'Divine Intervention',
      maxUses: (level) => 1,
      availableFromLevel: 10,
      fullRecoveryOn: RestType.long,
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

/// Resources granted by feats (keyed by feat id); they are added to the class
/// resources so Short/Long Rests recharge them too.
final Map<String, List<ClassResource>> featResources = {
  'lucky': [
    ClassResource(
      id: 'luck_points',
      name: 'Luck Points (Lucky)',
      maxUses: proficiencyBonusForLevel,
      availableFromLevel: 1,
      fullRecoveryOn: RestType.long,
    ),
  ],
};

/// Subclass resources whose limits depend on the character (e.g. the Wisdom
/// modifier), keyed by `class:subclass`.
final Map<String, List<ClassResource> Function(Character)> _subclassResources =
    {
      'cleric:light': (c) => [
        ClassResource(
          id: 'warding_flare',
          name: 'Warding Flare',
          maxUses: (_) => wardingFlareUses(c),
          availableFromLevel: 3,
          // Improved Warding Flare (level 6): also back on a Short Rest.
          fullRecoveryOn: c.level >= 6 ? RestType.short : RestType.long,
        ),
        ClassResource(
          id: 'corona_of_light',
          name: 'Corona of Light',
          maxUses: (_) => wardingFlareUses(c),
          availableFromLevel: 17,
          fullRecoveryOn: RestType.long,
        ),
      ],
      'fighter:battle_master': (c) => [
        ClassResource(
          id: 'superiority_dice',
          name: 'Superiority Dice',
          maxUses: superiorityDiceCount,
          availableFromLevel: 3,
          fullRecoveryOn: RestType.short,
        ),
        ClassResource(
          id: 'know_your_enemy',
          name: 'Know Your Enemy',
          maxUses: (_) => 1,
          availableFromLevel: 7,
          fullRecoveryOn: RestType.long,
        ),
      ],
      'fighter:psi_warrior': (c) => [
        ClassResource(
          id: 'psionic_energy',
          name: 'Psionic Energy Dice',
          maxUses: (level) => psionicEnergyDice(level).$2,
          availableFromLevel: 3,
          fullRecoveryOn: RestType.long,
          shortRestPartialRecovery: 1,
        ),
        ClassResource(
          id: 'telekinetic_movement',
          name: 'Telekinetic Movement',
          maxUses: (_) => 1,
          availableFromLevel: 3,
          fullRecoveryOn: RestType.short,
        ),
        ClassResource(
          id: 'psi_powered_leap',
          name: 'Psi-Powered Leap',
          maxUses: (_) => 1,
          availableFromLevel: 7,
          fullRecoveryOn: RestType.short,
        ),
        ClassResource(
          id: 'bulwark_of_force',
          name: 'Bulwark of Force',
          maxUses: (_) => 1,
          availableFromLevel: 15,
          fullRecoveryOn: RestType.long,
        ),
        ClassResource(
          id: 'telekinetic_master',
          name: 'Telekinetic Master',
          maxUses: (_) => 1,
          availableFromLevel: 18,
          fullRecoveryOn: RestType.long,
        ),
      ],
      'cleric:war': (c) => [
        ClassResource(
          id: 'war_priest',
          name: 'War Priest (bonus action attack)',
          maxUses: (_) => wardingFlareUses(c),
          availableFromLevel: 3,
          fullRecoveryOn: RestType.short,
        ),
      ],
    };

List<ClassResource> subclassResourcesFor(Character c) {
  final classId = c.characterClass.id;
  final subclass = c.classSelections['${classId}_subclass']?.firstOrNull;
  return _subclassResources['$classId:$subclass']?.call(c) ?? const [];
}
