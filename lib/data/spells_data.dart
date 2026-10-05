import '../models/spell.dart';

// Spell list entries (level, school, Concentration/Ritual/Material) from the
// class spell lists of the 2024 Player's Handbook, chapter 3. Spells are
// added as each class's chapter is verified; combat effects (damage, saves,
// healing) live in spell_effects_data.dart.

const _abj = 'Abjuration';
const _conj = 'Conjuration';
const _div = 'Divination';
const _ench = 'Enchantment';
const _evo = 'Evocation';
const _ill = 'Illusion';
const _necro = 'Necromancy';
const _trans = 'Transmutation';

const List<Spell> _druidList = [
  // Cantrips
  Spell('druidcraft', 'Druidcraft', 0, _trans),
  Spell('elementalism', 'Elementalism', 0, _trans),
  Spell('guidance', 'Guidance', 0, _div, concentration: true),
  Spell('mending', 'Mending', 0, _trans),
  Spell('message', 'Message', 0, _trans),
  Spell('poison_spray', 'Poison Spray', 0, _necro),
  Spell('produce_flame', 'Produce Flame', 0, _conj),
  Spell('resistance', 'Resistance', 0, _abj, concentration: true),
  Spell('shillelagh', 'Shillelagh', 0, _trans),
  Spell('spare_the_dying', 'Spare the Dying', 0, _necro),
  Spell('starry_wisp', 'Starry Wisp', 0, _evo),
  Spell('thorn_whip', 'Thorn Whip', 0, _trans),
  Spell('thunderclap', 'Thunderclap', 0, _evo),
  // Level 1
  Spell('animal_friendship', 'Animal Friendship', 1, _ench),
  Spell('charm_person', 'Charm Person', 1, _ench),
  Spell('create_or_destroy_water', 'Create or Destroy Water', 1, _trans),
  Spell('cure_wounds', 'Cure Wounds', 1, _abj),
  Spell(
    'detect_magic',
    'Detect Magic',
    1,
    _div,
    concentration: true,
    ritual: true,
  ),
  Spell(
    'detect_poison_and_disease',
    'Detect Poison and Disease',
    1,
    _div,
    concentration: true,
    ritual: true,
  ),
  Spell('entangle', 'Entangle', 1, _conj, concentration: true),
  Spell('faerie_fire', 'Faerie Fire', 1, _evo, concentration: true),
  Spell('fog_cloud', 'Fog Cloud', 1, _conj, concentration: true),
  Spell('goodberry', 'Goodberry', 1, _conj),
  Spell('healing_word', 'Healing Word', 1, _abj),
  Spell('ice_knife', 'Ice Knife', 1, _conj),
  Spell('jump', 'Jump', 1, _trans),
  Spell('longstrider', 'Longstrider', 1, _trans),
  Spell(
    'protection_from_evil_and_good',
    'Protection from Evil and Good',
    1,
    _abj,
    concentration: true,
    material: true,
  ),
  Spell(
    'purify_food_and_drink',
    'Purify Food and Drink',
    1,
    _trans,
    ritual: true,
  ),
  Spell('speak_with_animals', 'Speak with Animals', 1, _div, ritual: true),
  Spell('thunderwave', 'Thunderwave', 1, _evo),
  // Level 2
  Spell('aid', 'Aid', 2, _abj),
  Spell('animal_messenger', 'Animal Messenger', 2, _ench, ritual: true),
  Spell('augury', 'Augury', 2, _div, ritual: true, material: true),
  Spell('barkskin', 'Barkskin', 2, _trans),
  Spell(
    'beast_sense',
    'Beast Sense',
    2,
    _div,
    concentration: true,
    ritual: true,
  ),
  Spell('continual_flame', 'Continual Flame', 2, _evo, material: true),
  Spell('darkvision', 'Darkvision', 2, _trans),
  Spell('enhance_ability', 'Enhance Ability', 2, _trans, concentration: true),
  Spell('enlarge_reduce', 'Enlarge/Reduce', 2, _trans, concentration: true),
  Spell('find_traps', 'Find Traps', 2, _div),
  Spell('flame_blade', 'Flame Blade', 2, _evo, concentration: true),
  Spell('flaming_sphere', 'Flaming Sphere', 2, _evo, concentration: true),
  Spell('gust_of_wind', 'Gust of Wind', 2, _evo, concentration: true),
  Spell('heat_metal', 'Heat Metal', 2, _trans, concentration: true),
  Spell('hold_person', 'Hold Person', 2, _ench, concentration: true),
  Spell('lesser_restoration', 'Lesser Restoration', 2, _abj),
  Spell(
    'locate_animals_or_plants',
    'Locate Animals or Plants',
    2,
    _div,
    ritual: true,
  ),
  Spell('locate_object', 'Locate Object', 2, _div, concentration: true),
  Spell('moonbeam', 'Moonbeam', 2, _evo, concentration: true),
  Spell(
    'pass_without_trace',
    'Pass without Trace',
    2,
    _abj,
    concentration: true,
  ),
  Spell('protection_from_poison', 'Protection from Poison', 2, _abj),
  Spell('spike_growth', 'Spike Growth', 2, _trans, concentration: true),
  Spell(
    'summon_beast',
    'Summon Beast',
    2,
    _conj,
    concentration: true,
    material: true,
  ),
  // Level 3
  Spell('aura_of_vitality', 'Aura of Vitality', 3, _abj, concentration: true),
  Spell('call_lightning', 'Call Lightning', 3, _conj, concentration: true),
  Spell('conjure_animals', 'Conjure Animals', 3, _conj, concentration: true),
  Spell('daylight', 'Daylight', 3, _evo),
  Spell('dispel_magic', 'Dispel Magic', 3, _abj),
  Spell('elemental_weapon', 'Elemental Weapon', 3, _trans, concentration: true),
  Spell('feign_death', 'Feign Death', 3, _necro, ritual: true),
  Spell('meld_into_stone', 'Meld into Stone', 3, _trans, ritual: true),
  Spell('plant_growth', 'Plant Growth', 3, _trans),
  Spell(
    'protection_from_energy',
    'Protection from Energy',
    3,
    _abj,
    concentration: true,
  ),
  Spell('revivify', 'Revivify', 3, _necro, material: true),
  Spell('sleet_storm', 'Sleet Storm', 3, _conj, concentration: true),
  Spell('speak_with_plants', 'Speak with Plants', 3, _trans),
  Spell(
    'summon_fey',
    'Summon Fey',
    3,
    _conj,
    concentration: true,
    material: true,
  ),
  Spell('water_breathing', 'Water Breathing', 3, _trans, ritual: true),
  Spell('water_walk', 'Water Walk', 3, _trans, ritual: true),
  Spell('wind_wall', 'Wind Wall', 3, _evo, concentration: true),
  // Level 4
  Spell('blight', 'Blight', 4, _necro),
  Spell('charm_monster', 'Charm Monster', 4, _ench),
  Spell('confusion', 'Confusion', 4, _ench, concentration: true),
  Spell(
    'conjure_minor_elementals',
    'Conjure Minor Elementals',
    4,
    _conj,
    concentration: true,
  ),
  Spell(
    'conjure_woodland_beings',
    'Conjure Woodland Beings',
    4,
    _conj,
    concentration: true,
  ),
  Spell('control_water', 'Control Water', 4, _trans, concentration: true),
  Spell('divination', 'Divination', 4, _div, ritual: true, material: true),
  Spell('dominate_beast', 'Dominate Beast', 4, _ench, concentration: true),
  Spell('fire_shield', 'Fire Shield', 4, _evo),
  Spell(
    'fount_of_moonlight',
    'Fount of Moonlight',
    4,
    _evo,
    concentration: true,
  ),
  Spell('freedom_of_movement', 'Freedom of Movement', 4, _abj),
  Spell('giant_insect', 'Giant Insect', 4, _conj, concentration: true),
  Spell('grasping_vine', 'Grasping Vine', 4, _conj, concentration: true),
  Spell('hallucinatory_terrain', 'Hallucinatory Terrain', 4, _ill),
  Spell('ice_storm', 'Ice Storm', 4, _evo),
  Spell('locate_creature', 'Locate Creature', 4, _div, concentration: true),
  Spell('polymorph', 'Polymorph', 4, _trans, concentration: true),
  Spell('stone_shape', 'Stone Shape', 4, _trans),
  Spell(
    'stoneskin',
    'Stoneskin',
    4,
    _trans,
    concentration: true,
    material: true,
  ),
  Spell(
    'summon_elemental',
    'Summon Elemental',
    4,
    _conj,
    concentration: true,
    material: true,
  ),
  Spell('wall_of_fire', 'Wall of Fire', 4, _evo, concentration: true),
  // Level 5
  Spell('antilife_shell', 'Antilife Shell', 5, _abj, concentration: true),
  Spell('awaken', 'Awaken', 5, _trans, material: true),
  Spell('commune_with_nature', 'Commune with Nature', 5, _div, ritual: true),
  Spell('cone_of_cold', 'Cone of Cold', 5, _evo),
  Spell(
    'conjure_elemental',
    'Conjure Elemental',
    5,
    _conj,
    concentration: true,
  ),
  Spell('contagion', 'Contagion', 5, _necro),
  Spell('geas', 'Geas', 5, _ench),
  Spell('greater_restoration', 'Greater Restoration', 5, _abj, material: true),
  Spell('insect_plague', 'Insect Plague', 5, _conj, concentration: true),
  Spell('mass_cure_wounds', 'Mass Cure Wounds', 5, _abj),
  Spell('planar_binding', 'Planar Binding', 5, _abj, material: true),
  Spell('reincarnate', 'Reincarnate', 5, _necro, material: true),
  Spell('scrying', 'Scrying', 5, _div, concentration: true, material: true),
  Spell('tree_stride', 'Tree Stride', 5, _conj, concentration: true),
  Spell('wall_of_stone', 'Wall of Stone', 5, _evo, concentration: true),
  // Level 6
  Spell('conjure_fey', 'Conjure Fey', 6, _conj, concentration: true),
  Spell(
    'find_the_path',
    'Find the Path',
    6,
    _div,
    concentration: true,
    material: true,
  ),
  Spell('flesh_to_stone', 'Flesh to Stone', 6, _trans, concentration: true),
  Spell('heal', 'Heal', 6, _abj),
  Spell('heroes_feast', 'Heroes\' Feast', 6, _conj, material: true),
  Spell('move_earth', 'Move Earth', 6, _trans, concentration: true),
  Spell('sunbeam', 'Sunbeam', 6, _evo, concentration: true),
  Spell('transport_via_plants', 'Transport via Plants', 6, _conj),
  Spell('wall_of_thorns', 'Wall of Thorns', 6, _conj, concentration: true),
  Spell('wind_walk', 'Wind Walk', 6, _trans),
  // Level 7
  Spell('fire_storm', 'Fire Storm', 7, _evo),
  Spell('mirage_arcane', 'Mirage Arcane', 7, _ill),
  Spell('plane_shift', 'Plane Shift', 7, _conj, material: true),
  Spell('regenerate', 'Regenerate', 7, _trans),
  Spell('reverse_gravity', 'Reverse Gravity', 7, _trans, concentration: true),
  Spell('symbol', 'Symbol', 7, _abj, material: true),
  // Level 8
  Spell('animal_shapes', 'Animal Shapes', 8, _trans),
  Spell('antipathy_sympathy', 'Antipathy/Sympathy', 8, _ench),
  Spell('befuddlement', 'Befuddlement', 8, _ench),
  Spell('control_weather', 'Control Weather', 8, _trans, concentration: true),
  Spell('earthquake', 'Earthquake', 8, _trans, concentration: true),
  Spell('incendiary_cloud', 'Incendiary Cloud', 8, _conj, concentration: true),
  Spell('sunburst', 'Sunburst', 8, _evo),
  Spell('tsunami', 'Tsunami', 8, _conj, concentration: true),
  // Level 9
  Spell('foresight', 'Foresight', 9, _div),
  Spell(
    'shapechange',
    'Shapechange',
    9,
    _trans,
    concentration: true,
    material: true,
  ),
  Spell(
    'storm_of_vengeance',
    'Storm of Vengeance',
    9,
    _conj,
    concentration: true,
  ),
  Spell('true_resurrection', 'True Resurrection', 9, _necro, material: true),
];

/// Spells outside the Druid list, taken from other verified class lists
/// (Ranger, chapter 3) because Druid circles grant them.
const List<Spell> _otherVerified = [
  Spell('misty_step', 'Misty Step', 2, _conj),
  // From chapter 7 headers (Sorcerer/Wizard/Cleric spells granted by circles).
  Spell('acid_splash', 'Acid Splash', 0, _evo),
  Spell('fire_bolt', 'Fire Bolt', 0, _evo),
  Spell('ray_of_frost', 'Ray of Frost', 0, _evo),
  Spell('shocking_grasp', 'Shocking Grasp', 0, _evo),
  Spell('burning_hands', 'Burning Hands', 1, _evo),
  Spell('guiding_bolt', 'Guiding Bolt', 1, _evo),
  Spell('ray_of_sickness', 'Ray of Sickness', 1, _necro),
  Spell('sleep', 'Sleep', 1, _ench, concentration: true),
  Spell('blur', 'Blur', 2, _ill, concentration: true),
  Spell('shatter', 'Shatter', 2, _evo),
  Spell('web', 'Web', 2, _conj, concentration: true),
  Spell('fireball', 'Fireball', 3, _evo),
  Spell('lightning_bolt', 'Lightning Bolt', 3, _evo),
  Spell('stinking_cloud', 'Stinking Cloud', 3, _conj, concentration: true),
  Spell('hold_monster', 'Hold Monster', 5, _ench, concentration: true),
];

final Map<String, Spell> allSpells = {
  for (final s in [..._druidList, ..._otherVerified]) s.id: s,
};

final Map<String, Spell> _spellsByName = {
  for (final s in allSpells.values) s.name.toLowerCase(): s,
};

Spell? spellByName(String name) => _spellsByName[name.toLowerCase()];

/// Class spell lists (spell ids), per verified class chapter.
final Map<String, List<String>> classSpellLists = {
  'druid': [for (final s in _druidList) s.id],
};

bool hasSpellcastingSupport(String classId) =>
    classSpellLists.containsKey(classId);
