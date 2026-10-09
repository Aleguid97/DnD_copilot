import '../models/spell_effect.dart';

// Combat effects verified against chapter 7 (Spell Descriptions) of the 2024
// Player's Handbook. Spells not listed here are cast as reminders only.
// Notes paraphrase what the dice don't capture.

const _dex = 'Dexterity';
const _con = 'Constitution';
const _str = 'Strength';
const _wis = 'Wisdom';
const _int = 'Intelligence';
const _cha = 'Charisma';

SpellEffect _attack(
  String dice,
  String type, {
  bool melee = false,
  bool mod = false,
  String? upcast,
  bool cantrip = false,
  String? condition,
  bool repeat = false,
  SpellEffect? secondary,
  String note = '',
}) => SpellEffect(
  kind: SpellEffectKind.attack,
  dice: dice,
  damageType: type,
  melee: melee,
  addModifier: mod,
  upcastDice: upcast,
  cantripScaling: cantrip,
  condition: condition,
  repeatable: repeat,
  secondary: secondary,
  note: note,
);

SpellEffect _save(
  String ability, {
  String? dice,
  String? type,
  bool half = true,
  String? upcast,
  int? upcastAbove,
  bool cantrip = false,
  String? condition,
  bool multi = true,
  bool repeat = false,
  String? extraDice,
  String? extraType,
  String? extraUpcast,
  String? wounded,
  int flat = 0,
  String note = '',
}) => SpellEffect(
  kind: SpellEffectKind.save,
  extraUpcastDice: extraUpcast,
  woundedDice: wounded,
  flat: flat,
  saveAbility: ability,
  dice: dice,
  damageType: type,
  halfOnSave: half,
  upcastDice: upcast,
  upcastAbove: upcastAbove,
  cantripScaling: cantrip,
  condition: condition,
  multiTarget: multi,
  repeatable: repeat,
  extraDice: extraDice,
  extraDamageType: extraType,
  note: note,
);

SpellEffect _auto(
  String dice,
  String type, {
  String? upcast,
  bool repeat = true,
  int flat = 0,
  int upcastFlat = 0,
  String note = '',
}) => SpellEffect(
  kind: SpellEffectKind.automatic,
  dice: dice,
  damageType: type,
  upcastDice: upcast,
  flat: flat,
  upcastFlat: upcastFlat,
  repeatable: repeat,
  note: note,
);

SpellEffect _heal(
  String? dice, {
  bool mod = false,
  String? upcast,
  int flat = 0,
  int upcastFlat = 0,
  bool repeat = false,
  String note = '',
}) => SpellEffect(
  kind: SpellEffectKind.heal,
  dice: dice,
  addModifier: mod,
  upcastDice: upcast,
  flat: flat,
  upcastFlat: upcastFlat,
  repeatable: repeat,
  note: note,
);

final Map<String, SpellEffect> spellEffects = {
  // ------------------------------------------------------------- cantrips
  'acid_splash': _save(
    _dex,
    dice: '1d6',
    type: 'Acid',
    half: false,
    cantrip: true,
  ),
  'fire_bolt': _attack('1d10', 'Fire', cantrip: true),
  'poison_spray': _attack('1d12', 'Poison', cantrip: true),
  'produce_flame': _attack(
    '1d8',
    'Fire',
    cantrip: true,
    note:
        'The flame lights 20 ft for 10 minutes; hurl it again with a Magic action.',
  ),
  'ray_of_frost': _attack(
    '1d8',
    'Cold',
    cantrip: true,
    note: 'Target\'s Speed −10 ft until the start of your next turn.',
  ),
  'shocking_grasp': _attack(
    '1d8',
    'Lightning',
    melee: true,
    cantrip: true,
    note: 'Target can\'t make Opportunity Attacks until its next turn.',
  ),
  'starry_wisp': _attack(
    '1d8',
    'Radiant',
    cantrip: true,
    note:
        'Target sheds Dim Light and can\'t be Invisible until the end of your next turn.',
  ),
  'thorn_whip': _attack(
    '1d6',
    'Piercing',
    melee: true,
    cantrip: true,
    note: 'Pull a Large or smaller target up to 10 ft toward you.',
  ),
  'thunderclap': _save(
    _con,
    dice: '1d6',
    type: 'Thunder',
    half: false,
    cantrip: true,
  ),

  // -------------------------------------------------------------- level 1
  'animal_friendship': _save(_wis, condition: 'Charmed', multi: false),
  'burning_hands': _save(_dex, dice: '3d6', type: 'Fire', upcast: '1d6'),
  'charm_person': _save(
    _wis,
    condition: 'Charmed',
    multi: false,
    note: 'Advantage on the save if you or allies are fighting it.',
  ),
  'cure_wounds': _heal('2d8', mod: true, upcast: '2d8'),
  'entangle': _save(
    _str,
    condition: 'Restrained',
    note:
        'Area is Difficult Terrain; Strength (Athletics) vs your DC to escape.',
  ),
  'faerie_fire': _save(
    _dex,
    condition: 'Outlined',
    note: 'Attacks against outlined creatures have Advantage.',
  ),
  'guiding_bolt': _attack(
    '4d6',
    'Radiant',
    upcast: '1d6',
    condition: 'Guiding Bolt',
    note: 'The next attack roll against the target has Advantage.',
  ),
  'healing_word': _heal('2d4', mod: true, upcast: '2d4'),
  'ice_knife': _attack(
    '1d10',
    'Piercing',
    secondary: _save(
      _dex,
      dice: '2d6',
      type: 'Cold',
      half: false,
      upcast: '1d6',
      note:
          'The shard explodes on the target and creatures within 5 ft, hit or miss.',
    ),
  ),
  'ray_of_sickness': _attack(
    '2d8',
    'Poison',
    upcast: '1d8',
    condition: 'Poisoned',
    note: 'Poisoned until the end of your next turn.',
  ),
  'sleep': _save(
    _wis,
    condition: 'Incapacitated',
    note: 'Repeat the save at the end of its next turn: fail = Unconscious.',
  ),
  'thunderwave': _save(
    _con,
    dice: '2d8',
    type: 'Thunder',
    upcast: '1d8',
    note: 'Failed save: pushed 10 ft away.',
  ),

  // -------------------------------------------------------------- level 2
  'flame_blade': _attack(
    '3d6',
    'Fire',
    melee: true,
    mod: true,
    upcast: '1d6',
    repeat: true,
  ),
  'flaming_sphere': _save(
    _dex,
    dice: '2d6',
    type: 'Fire',
    upcast: '1d6',
    repeat: true,
    note: 'Creatures ending their turn within 5 ft of the sphere save again.',
  ),
  'heat_metal': _auto(
    '2d8',
    'Fire',
    upcast: '1d8',
    note:
        'Holder makes a Con save or drops the object; if it keeps it, Disadvantage on attacks and checks.',
  ),
  'hold_person': _save(
    _wis,
    condition: 'Paralyzed',
    note:
        'Repeats the save at the end of each of its turns. +1 Humanoid per slot above 2.',
  ),
  'moonbeam': _save(
    _con,
    dice: '2d10',
    type: 'Radiant',
    upcast: '1d10',
    repeat: true,
    note: 'Shape-shifted creatures revert to true form.',
  ),
  'shatter': _save(_con, dice: '3d8', type: 'Thunder', upcast: '1d8'),
  'spike_growth': _auto(
    '2d4',
    'Piercing',
    note: 'Damage for every 5 ft a creature moves in the area.',
  ),
  'web': _save(_dex, condition: 'Restrained', repeat: true),

  // -------------------------------------------------------------- level 3
  'aura_of_vitality': _heal(
    '2d6',
    repeat: true,
    note: 'Heal one creature in the aura at the start of each of your turns.',
  ),
  'call_lightning': _save(
    _dex,
    dice: '3d10',
    type: 'Lightning',
    upcast: '1d10',
    repeat: true,
    note: 'Outdoors in a storm the damage increases by 1d10.',
  ),
  'conjure_animals': _save(
    _dex,
    dice: '3d10',
    type: 'Slashing',
    half: false,
    upcast: '1d10',
    repeat: true,
  ),
  'fireball': _save(_dex, dice: '8d6', type: 'Fire', upcast: '1d6'),
  'lightning_bolt': _save(_dex, dice: '8d6', type: 'Lightning', upcast: '1d6'),
  'sleet_storm': _save(
    _dex,
    condition: 'Prone',
    repeat: true,
    note: 'Failed save also breaks Concentration.',
  ),
  'stinking_cloud': _save(
    _con,
    condition: 'Poisoned',
    repeat: true,
    note: 'Poisoned until the end of the current turn.',
  ),
  'wind_wall': _save(_str, dice: '4d8', type: 'Bludgeoning'),

  // -------------------------------------------------------------- level 4
  'blight': _save(
    _con,
    dice: '8d8',
    type: 'Necrotic',
    upcast: '1d8',
    multi: false,
  ),
  'charm_monster': _save(_wis, condition: 'Charmed', multi: false),
  'confusion': _save(_wis, condition: 'Confused'),
  'conjure_minor_elementals': _auto(
    '2d8',
    'Acid/Cold/Fire/Lightning',
    upcast: '2d8',
    note:
        'Extra damage when your attacks hit a creature in the 15-ft Emanation.',
  ),
  'conjure_woodland_beings': _save(
    _wis,
    dice: '5d8',
    type: 'Force',
    upcast: '1d8',
    upcastAbove: 5,
    repeat: true,
  ),
  'dominate_beast': _save(_wis, condition: 'Charmed', multi: false),
  'fount_of_moonlight': _auto(
    '2d6',
    'Radiant',
    note: 'Extra damage on your melee hits; you resist Radiant damage.',
  ),
  'grasping_vine': _attack(
    '4d8',
    'Bludgeoning',
    melee: true,
    condition: 'Grappled',
    repeat: true,
    note: 'Pulled up to 30 ft toward the vine.',
  ),
  'ice_storm': _save(
    _dex,
    dice: '2d10',
    type: 'Bludgeoning',
    upcast: '1d10',
    extraDice: '4d6',
    extraType: 'Cold',
  ),
  'polymorph': _save(_wis, condition: 'Polymorphed', multi: false),
  'wall_of_fire': _save(
    _dex,
    dice: '5d8',
    type: 'Fire',
    upcast: '1d8',
    repeat: true,
  ),

  // -------------------------------------------------------------- level 5
  'cone_of_cold': _save(_con, dice: '8d8', type: 'Cold', upcast: '1d8'),
  'conjure_elemental': _save(
    _dex,
    dice: '8d8',
    type: 'elemental',
    half: false,
    upcast: '2d8',
    condition: 'Restrained',
    repeat: true,
    note: 'Restrained target repeats the save each turn: fail = 4d8 more.',
  ),
  'contagion': _save(
    _con,
    dice: '11d8',
    type: 'Necrotic',
    half: false,
    condition: 'Poisoned',
    multi: false,
  ),
  'geas': _save(_wis, condition: 'Charmed', multi: false),
  'hold_monster': _save(_wis, condition: 'Paralyzed'),
  'insect_plague': _save(
    _con,
    dice: '4d10',
    type: 'Piercing',
    upcast: '1d10',
    repeat: true,
  ),
  'mass_cure_wounds': _heal(
    '5d8',
    mod: true,
    upcast: '1d8',
    note: 'Up to six creatures in a 30-ft Sphere each regain this amount.',
  ),

  // ------------------------------------------------------------ level 6-9
  'befuddlement': _save(_int, dice: '10d12', type: 'Psychic', multi: false),
  'conjure_fey': _attack(
    '3d12',
    'Psychic',
    melee: true,
    mod: true,
    upcast: '2d12',
    condition: 'Frightened',
    repeat: true,
  ),
  'earthquake': _save(
    _dex,
    condition: 'Prone',
    repeat: true,
    note: 'Failed save also breaks Concentration.',
  ),
  'fire_storm': _save(_dex, dice: '7d10', type: 'Fire'),
  'flesh_to_stone': _save(_con, condition: 'Restrained', multi: false),
  'heal': _heal(
    null,
    flat: 70,
    upcastFlat: 10,
    note: 'Also ends Blinded, Deafened and Poisoned.',
  ),
  'incendiary_cloud': _save(_dex, dice: '10d8', type: 'Fire', repeat: true),
  'regenerate': _heal(
    '4d8',
    flat: 15,
    note: 'Then 1 HP at the start of each of its turns for 1 hour.',
  ),
  'sunbeam': _save(
    _con,
    dice: '6d8',
    type: 'Radiant',
    condition: 'Blinded',
    repeat: true,
  ),
  'sunburst': _save(_con, dice: '12d6', type: 'Radiant', condition: 'Blinded'),
  'tsunami': _save(_str, dice: '6d10', type: 'Bludgeoning'),
  'wall_of_thorns': _save(_dex, dice: '7d8', type: 'Piercing', upcast: '1d8'),

  // ------------------------------------------------------- Cleric spells
  'sacred_flame': _save(
    _dex,
    dice: '1d8',
    type: 'Radiant',
    half: false,
    cantrip: true,
    multi: false,
    note: 'The target gains no benefit from Half or Three-Quarters Cover.',
  ),
  'toll_the_dead': _save(
    _wis,
    dice: '1d8',
    wounded: '1d12',
    type: 'Necrotic',
    half: false,
    cantrip: true,
    multi: false,
    note: 'd12s instead if the target is missing any Hit Points.',
  ),
  'word_of_radiance': _save(
    _con,
    dice: '1d6',
    type: 'Radiant',
    half: false,
    cantrip: true,
  ),
  'bane': _save(
    _cha,
    condition: 'Baned',
    note:
        'Failed targets subtract 1d4 from attack rolls and saves. +1 target per slot above 1.',
  ),
  'blindness_deafness': _save(
    _con,
    condition: 'Blinded',
    multi: false,
    note:
        'Or Deafened (your choice); repeats the save at the end of each of its turns.',
  ),
  'bestow_curse': _save(_wis, condition: 'Cursed', multi: false),
  'banishment': _save(
    _cha,
    condition: 'Banished',
    note: 'Incapacitated in a demiplane. +1 target per slot above 4.',
  ),
  'blade_barrier': _save(
    _dex,
    dice: '6d10',
    type: 'Force',
    repeat: true,
    note: 'Also when a creature enters the wall or ends its turn there.',
  ),
  'calm_emotions': _save('Charisma', condition: 'Calmed'),
  'command': _save(
    _wis,
    condition: 'Commanded',
    note: 'Approach, Drop, Flee, Grovel (Prone) or Halt on its next turn.',
  ),
  'conjure_celestial': _save(
    _dex,
    dice: '6d12',
    type: 'Radiant',
    upcast: '1d12',
    repeat: true,
    note:
        'Searing Light. Healing Light instead: 4d12 + mod (+1d12 per slot above 7).',
  ),
  'flame_strike': _save(
    _dex,
    dice: '5d6',
    type: 'Fire',
    upcast: '1d6',
    extraDice: '5d6',
    extraType: 'Radiant',
    extraUpcast: '1d6',
  ),
  'guardian_of_faith': _save(
    _dex,
    flat: 20,
    type: 'Radiant',
    note:
        'Enemies moving within 10 ft of the guardian; it vanishes after dealing 60 damage.',
  ),
  'harm': _save(
    _con,
    dice: '14d6',
    type: 'Necrotic',
    multi: false,
    note: 'Failed save also lowers its Hit Point maximum by the damage taken.',
  ),
  'inflict_wounds': _save(
    _con,
    dice: '2d10',
    type: 'Necrotic',
    upcast: '1d10',
    multi: false,
  ),
  'spirit_guardians': _save(
    _wis,
    dice: '3d8',
    type: 'Radiant',
    upcast: '1d8',
    repeat: true,
    note:
        'Necrotic if you are evil. Enemies\' Speed is halved in the Emanation.',
  ),
  'steel_wind_strike': _attack(
    '6d10',
    'Force',
    melee: true,
    note:
        'One melee spell attack against each of up to five creatures; '
        'then teleport within 5 feet of one of them.',
  ),
  'spiritual_weapon': _attack(
    '1d8',
    'Force',
    melee: true,
    mod: true,
    upcast: '1d8',
    repeat: true,
    note: 'Bonus Action on later turns: move it 20 ft and attack again.',
  ),
  'mass_healing_word': _heal(
    '2d4',
    mod: true,
    upcast: '1d4',
    note: 'Up to six creatures each regain this amount.',
  ),
  'prayer_of_healing': _heal(
    '2d8',
    upcast: '1d8',
    note: 'Up to five creatures also gain the benefits of a Short Rest.',
  ),
  'mass_heal': _heal(
    null,
    flat: 700,
    note:
        'Divided among any number of creatures; also ends Blinded, Deafened and Poisoned.',
  ),
  'power_word_heal': _heal(
    null,
    flat: 1000,
    note:
        'Regains all its Hit Points and ends Charmed, Frightened, Paralyzed, Poisoned, Stunned.',
  ),

  // ----------------------------------------- Wizard list (Eldritch Knight)
  'chill_touch': _attack(
    '1d10',
    'Necrotic',
    melee: true,
    cantrip: true,
    note:
        'The target can\'t regain Hit Points until the end of your next turn.',
  ),
  'mind_sliver': _save(
    _int,
    dice: '1d6',
    type: 'Psychic',
    half: false,
    cantrip: true,
    multi: false,
    note:
        'On a failed save, subtract 1d4 from its next save before the end of your next turn.',
  ),
  'chromatic_orb': _attack(
    '3d8',
    'Acid, Cold, Fire, Lightning, Poison or Thunder (your choice)',
    upcast: '1d8',
    note:
        'Doubles on the d8s: the orb leaps to another target within 30 ft (with a level 2+ slot).',
  ),
  'color_spray': _save(
    _con,
    condition: 'Blinded',
    note: '15-ft Cone; Blinded until the end of your next turn.',
  ),
  'magic_missile': _auto(
    '3d4',
    'Force',
    flat: 3,
    upcast: '1d4',
    upcastFlat: 1,
    repeat: false,
    note:
        'Three darts of 1d4 + 1 (one more per slot level above 1), all on one creature or spread out.',
  ),
  'witch_bolt': _attack(
    '2d12',
    'Lightning',
    upcast: '1d12',
    note: 'Later turns: Bonus Action for 1d12 Lightning automatically.',
  ),
  'cloud_of_daggers': _auto(
    '4d4',
    'Slashing',
    upcast: '2d4',
    note:
        '5-ft Cube; also on entering or ending a turn there. Magic action: move it 30 ft.',
  ),
  'dragons_breath': _save(
    _dex,
    dice: '3d6',
    type: 'Acid, Cold, Fire, Lightning or Poison (chosen)',
    upcast: '1d6',
    repeat: true,
    note: 'The touched creature exhales a 15-ft Cone as a Magic action.',
  ),
  'melfs_acid_arrow': _attack(
    '4d4',
    'Acid',
    upcast: '1d4',
    note:
        'Another 2d4 Acid (+1d4 per slot level above 2) at the end of its next turn; half the initial damage on a miss.',
  ),
  'mind_spike': _save(
    _wis,
    dice: '3d8',
    type: 'Psychic',
    upcast: '1d8',
    multi: false,
    note: 'On a failed save you always know where the target is.',
  ),
  'scorching_ray': _attack(
    '2d6',
    'Fire',
    note: 'Three rays (one more per slot level above 2): attack once per ray.',
  ),
  'vampiric_touch': _attack(
    '3d6',
    'Necrotic',
    melee: true,
    upcast: '1d6',
    repeat: true,
    note: 'You regain HP equal to half the Necrotic damage dealt.',
  ),
  'vitriolic_sphere': _save(
    _dex,
    dice: '10d4',
    type: 'Acid',
    upcast: '2d4',
    note:
        '20-ft Sphere; on a failed save another 5d4 Acid at the end of its next turn.',
  ),
  'phantasmal_killer': _save(
    _wis,
    dice: '4d10',
    type: 'Psychic',
    upcast: '1d10',
    multi: false,
    repeat: true,
    condition: 'Phantasmal Killer: Disadvantage on checks and attacks',
    note:
        'Save again at the end of each of its turns: fail = damage again, success = spell ends.',
  ),
};
