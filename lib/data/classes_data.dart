import '../models/character_class.dart';
import '../models/choice.dart';
import '../models/level_feature.dart';
import '../models/starting_equipment.dart';

final List<CharacterClass> allClasses = [
  const CharacterClass(
    id: 'barbarian',
    name: 'Barbarian',
    hitDie: 12,
    savingThrows: ['Strength', 'Constitution'],
    armorProficiencies: ['Light', 'Medium', 'Shields'],
    weaponProficiencies: ['Simple', 'Martial'],
    skillChoiceCount: 2,
    skillOptions: [
      'Animal Handling',
      'Athletics',
      'Intimidation',
      'Nature',
      'Perception',
      'Survival',
    ],
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'barbarian_a',
        label: 'Greataxe, 4 Handaxes, Explorer\'s Pack, 15 GP',
        items: [
          ItemGrant('greataxe'),
          ItemGrant('handaxe', quantity: 4),
          ItemGrant('explorers_pack'),
        ],
        goldPieces: 15,
      ),
      const StartingEquipmentOption(
        id: 'barbarian_b',
        label: '75 GP (buy your own equipment)',
        goldPieces: 75,
      ),
    ],
    levelFeatures: [
      LevelFeature(
        level: 1,
        fixedTraits: [
          'Rage (2 uses, Bonus Action, not while wearing Heavy armor): Resistance to Bludgeoning/Piercing/Slashing, bonus Rage Damage on Strength attacks, Advantage on Strength checks/saves, no Concentration/spells; lasts until end of next turn (extend by attacking, forcing a save, or Bonus Action), max 10 minutes',
          'Unarmored Defense: while wearing no armor, AC = 10 + Dex modifier + Con modifier (a Shield still works)',
        ],
        choices: [
          Choice(
            id: 'barbarian_weapon_mastery',
            title: 'Choose 2 weapon types for Weapon Mastery',
            minSelections: 2,
            maxSelections: 2,
            options: [
              ChoiceOption(id: 'greataxe', label: 'Greataxe (Cleave)'),
              ChoiceOption(id: 'greatsword', label: 'Greatsword (Graze)'),
              ChoiceOption(id: 'handaxe', label: 'Handaxe (Vex)'),
              ChoiceOption(id: 'javelin', label: 'Javelin (Slow)'),
              ChoiceOption(id: 'spear', label: 'Spear (Sap)'),
              ChoiceOption(id: 'maul', label: 'Maul (Topple)'),
              ChoiceOption(id: 'battleaxe', label: 'Battleaxe (Topple)'),
              ChoiceOption(id: 'flail', label: 'Flail (Sap)'),
              ChoiceOption(id: 'glaive', label: 'Glaive (Graze)'),
              ChoiceOption(id: 'halberd', label: 'Halberd (Cleave)'),
              ChoiceOption(id: 'warhammer', label: 'Warhammer (Push)'),
              ChoiceOption(id: 'war_pick', label: 'War Pick (Sap)'),
              ChoiceOption(id: 'morningstar', label: 'Morningstar (Sap)'),
              ChoiceOption(id: 'quarterstaff', label: 'Quarterstaff (Topple)'),
            ],
          ),
        ],
      ),
      const LevelFeature(
        level: 2,
        fixedTraits: [
          'Danger Sense: Advantage on Dexterity saving throws (unless Incapacitated)',
          'Reckless Attack: gain Advantage on Strength attack rolls until the start of your next turn, but attacks against you also have Advantage during that time',
        ],
      ),
      LevelFeature(
        level: 3,
        fixedTraits: [
          'Primal Knowledge: proficiency in another Barbarian skill; while raging, use Strength instead of the normal ability for Acrobatics/Intimidation/Perception/Stealth/Survival checks',
        ],
        choices: [
          Choice(
            id: 'barbarian_subclass',
            title: 'Choose your Primal Path (subclass)',
            options: [
              ChoiceOption(
                id: 'berserker',
                label: 'Path of the Berserker',
                description:
                    'Frenzy: extra damage on Reckless Attack hits while raging (Level 3).',
                levelFeatures: {
                  3: LevelFeature(
                    level: 3,
                    fixedTraits: [
                      'Frenzy: on your first Reckless Attack hit each turn while raging, deal extra damage (d6s = Rage Damage bonus)',
                    ],
                  ),
                  6: LevelFeature(
                    level: 6,
                    fixedTraits: [
                      'Mindless Rage: Immunity to Charmed and Frightened while raging (ends those conditions if already affected when you rage)',
                    ],
                  ),
                  10: LevelFeature(
                    level: 10,
                    fixedTraits: [
                      'Retaliation: Reaction to make a melee attack against a creature within 5 ft that just damaged you',
                    ],
                  ),
                  14: LevelFeature(
                    level: 14,
                    fixedTraits: [
                      'Intimidating Presence: Bonus Action, 30 ft emanation, Wisdom save (DC 8+Str mod+Prof) or Frightened 1 min (once per Long Rest, or spend a Rage use to restore)',
                    ],
                  ),
                },
              ),
              ChoiceOption(
                id: 'wild_heart',
                label: 'Path of the Wild Heart',
                description:
                    'Animal Speaker + Rage of the Wilds: kinship with animals (Level 3).',
                levelFeatures: {
                  3: LevelFeature(
                    level: 3,
                    fixedTraits: [
                      'Animal Speaker: cast Beast Sense and Speak with Animals as Rituals (Wisdom)',
                      'Rage of the Wilds: choose Bear (Resistance to almost all damage types while raging), Eagle (Disengage+Dash as part of Rage bonus action), or Wolf (allies get Advantage vs enemies within 5 ft of you)',
                    ],
                  ),
                  6: LevelFeature(
                    level: 6,
                    fixedTraits: [
                      'Aspect of the Wilds: choose Owl (Darkvision 60ft or +60ft), Panther (Climb Speed = Speed), or Salmon (Swim Speed = Speed); changeable on Long Rest',
                    ],
                  ),
                  10: LevelFeature(
                    level: 10,
                    fixedTraits: [
                      'Nature Speaker: cast Commune with Nature as a Ritual (Wisdom)',
                    ],
                  ),
                  14: LevelFeature(
                    level: 14,
                    fixedTraits: [
                      'Power of the Wilds: choose Falcon (Fly Speed while raging, unarmored), Lion (enemies near you have Disadvantage attacking others), or Ram (melee hits can Prone Large-or-smaller creatures)',
                    ],
                  ),
                },
              ),
              ChoiceOption(
                id: 'world_tree',
                label: 'Path of the World Tree',
                description:
                    'Vitality of the Tree: cosmic vitality from Yggdrasil (Level 3).',
                levelFeatures: {
                  3: LevelFeature(
                    level: 3,
                    fixedTraits: [
                      'Vitality Surge: gain Temp HP = Barbarian level when you activate Rage',
                      'Life-Giving Force: at the start of your turn while raging, give another creature within 10 ft Temp HP (d6s = Rage Damage bonus)',
                    ],
                  ),
                  6: LevelFeature(
                    level: 6,
                    fixedTraits: [
                      'Branches of the Tree: Reaction, teleport a creature that starts its turn within 30 ft to a nearby space (Strength save DC 8+Str mod+Prof) and reduce its Speed to 0',
                    ],
                  ),
                  10: LevelFeature(
                    level: 10,
                    fixedTraits: [
                      'Battering Roots: +10 ft reach with Heavy/Versatile Melee weapons; can add Push or Topple Mastery alongside another Mastery property on hit',
                    ],
                  ),
                  14: LevelFeature(
                    level: 14,
                    fixedTraits: [
                      'Travel Along the Tree: teleport up to 60 ft when activating Rage or as a Bonus Action while raging (once per Rage, extend to 150 ft and bring up to 6 allies)',
                    ],
                  ),
                },
              ),
              ChoiceOption(
                id: 'zealot',
                label: 'Path of the Zealot',
                description:
                    'Divine Fury + Warrior of the Gods: rage in union with a god (Level 3).',
                levelFeatures: {
                  3: LevelFeature(
                    level: 3,
                    fixedTraits: [
                      'Divine Fury: first creature hit each turn while raging takes extra 1d6 + half Barbarian level (round down) Necrotic or Radiant damage',
                      'Warrior of the Gods: pool of 4 d12s, Bonus Action to spend and heal yourself; pool refills on Long Rest, grows to 5 (level 6), 6 (level 12), 7 (level 17)',
                    ],
                  ),
                  6: LevelFeature(
                    level: 6,
                    fixedTraits: [
                      'Fanatical Focus: once per Rage, reroll a failed save with a bonus equal to your Rage Damage bonus',
                    ],
                  ),
                  10: LevelFeature(
                    level: 10,
                    fixedTraits: [
                      'Zealous Presence: Bonus Action, up to 10 creatures within 60 ft gain Advantage on attack rolls and saves until start of your next turn (once per Long Rest, or spend a Rage use to restore)',
                    ],
                  ),
                  14: LevelFeature(
                    level: 14,
                    fixedTraits: [
                      'Rage of the Gods: assume a divine warrior form for 1 minute when raging (once per Long Rest) — Flight, damage resistance to all but Force, and more',
                    ],
                  ),
                },
              ),
            ],
          ),
        ],
      ),
      const LevelFeature(
        level: 4,
        fixedTraits: [
          'Ability Score Improvement: increase one ability score by 2, or two ability scores by 1 each (max 20), or take a Feat',
        ],
        grantsAbilityScoreImprovement: true,
      ),
      const LevelFeature(
        level: 5,
        fixedTraits: [
          'Extra Attack: attack twice instead of once whenever you take the Attack action',
          'Fast Movement: Speed increases by 10 feet while not wearing Heavy armor',
        ],
      ),
      const LevelFeature(level: 6),
      const LevelFeature(
        level: 7,
        fixedTraits: [
          'Feral Instinct: Advantage on Initiative rolls',
          'Instinctive Pounce: as part of the Bonus Action to enter Rage, move up to half your Speed',
        ],
      ),
      const LevelFeature(
        level: 8,
        fixedTraits: [
          'Ability Score Improvement: increase one ability score by 2, or two ability scores by 1 each (max 20), or take a Feat',
        ],
        grantsAbilityScoreImprovement: true,
      ),
      const LevelFeature(
        level: 9,
        fixedTraits: [
          'Brutal Strike: forgo Reckless Attack\'s Advantage on one Strength attack (must not have Disadvantage); on hit, extra 1d10 damage plus a Brutal Strike effect (Forceful Blow: push 15 ft; Hamstring Blow: reduce Speed by 15 ft)',
        ],
      ),
      const LevelFeature(level: 10),
      const LevelFeature(
        level: 11,
        fixedTraits: [
          'Relentless Rage: if you drop to 0 HP while raging (and don\'t die outright), DC 10 Constitution save to instead drop to HP = 2× Barbarian level (DC +5 each further use, resets to 10 on a rest)',
        ],
      ),
      const LevelFeature(
        level: 12,
        fixedTraits: [
          'Ability Score Improvement: increase one ability score by 2, or two ability scores by 1 each (max 20), or take a Feat',
        ],
        grantsAbilityScoreImprovement: true,
      ),
      const LevelFeature(
        level: 13,
        fixedTraits: [
          'Improved Brutal Strike: new effect options — Staggering Blow (Disadvantage on next save, no Opportunity Attacks until your next turn) and Sundering Blow (+5 to the next attack roll against the target)',
        ],
      ),
      const LevelFeature(level: 14),
      const LevelFeature(
        level: 15,
        fixedTraits: [
          'Persistent Rage: on rolling Initiative, regain all Rage uses (once per Long Rest); Rage now lasts 10 minutes without needing to extend it each round',
        ],
      ),
      const LevelFeature(
        level: 16,
        fixedTraits: [
          'Ability Score Improvement: increase one ability score by 2, or two ability scores by 1 each (max 20), or take a Feat',
        ],
        grantsAbilityScoreImprovement: true,
      ),
      const LevelFeature(
        level: 17,
        fixedTraits: [
          'Improved Brutal Strike: extra damage increases to 2d10; you can use two different Brutal Strike effects at once',
        ],
      ),
      const LevelFeature(
        level: 18,
        fixedTraits: [
          'Indomitable Might: if your Strength check or save total is less than your Strength score, use that score instead',
        ],
      ),
      const LevelFeature(
        level: 19,
        fixedTraits: [
          'Epic Boon: gain an Epic Boon feat of your choice (requires level 19+); Boon of Irresistible Offense recommended',
        ],
        grantsAbilityScoreImprovement: true,
      ),
      const LevelFeature(
        level: 20,
        fixedTraits: [
          'Primal Champion: Strength and Constitution scores increase by 4, to a maximum of 25',
        ],
      ),
    ],
  ),
  const CharacterClass(
    id: 'bard',
    name: 'Bard',
    hitDie: 8,
    savingThrows: ['Dexterity', 'Charisma'],
    armorProficiencies: ['Light'],
    weaponProficiencies: ['Simple'],
    skillChoiceCount: 3,
    skillOptions: [
      'Acrobatics',
      'Animal Handling',
      'Arcana',
      'Athletics',
      'Stealth',
      'Deception',
      'Intimidation',
      'Insight',
      'Investigation',
      'Medicine',
      'Perception',
      'Persuasion',
      'Sleight of Hand',
      'Religion',
      'Survival',
      'History',
    ],

    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'bard_a',
        label:
            'Leather Armor, 2 Daggers, Musical Instrument, Entertainer\'s Pack, 19 GP',
        items: [
          ItemGrant('leather_armor'),
          ItemGrant('dagger', quantity: 2),
          ItemGrant('musical_instrument'),
          ItemGrant('entertainers_pack'),
        ],
        goldPieces: 19,
      ),
      const StartingEquipmentOption(
        id: 'bard_b',
        label: '90 GP (buy your own equipment)',
        goldPieces: 90,
      ),
    ],
    isSpellcaster: true,
    spellcastingAbility: 'Charisma',
    levelFeatures: [
      LevelFeature(
        level: 1,
        fixedTraits: [
          'Bardic Inspiration: Bonus Action, give a creature a Bardic Inspiration die',
        ],
        choices: [
          Choice(
            id: 'bard_cantrips',
            title: 'Choose 2 Bard cantrips',
            minSelections: 2,
            maxSelections: 2,
            options: [
              ChoiceOption(id: 'dancing_lights', label: 'Dancing Lights'),
              ChoiceOption(id: 'vicious_mockery', label: 'Vicious Mockery'),
              ChoiceOption(id: 'mage_hand', label: 'Mage Hand'),
              ChoiceOption(id: 'minor_illusion', label: 'Minor Illusion'),
            ],
          ),
          Choice(
            id: 'bard_prepared_spells',
            title: 'Choose 4 level 1 spells to prepare',
            minSelections: 4,
            maxSelections: 4,
            options: [
              ChoiceOption(id: 'charm_person', label: 'Charm Person'),
              ChoiceOption(id: 'color_spray', label: 'Color Spray'),
              ChoiceOption(
                id: 'dissonant_whispers',
                label: 'Dissonant Whispers',
              ),
              ChoiceOption(id: 'healing_word', label: 'Healing Word'),
              ChoiceOption(id: 'faerie_fire', label: 'Faerie Fire'),
              ChoiceOption(id: 'sleep', label: 'Sleep'),
            ],
          ),
        ],
      ),
    ],
  ),
  const CharacterClass(
    id: 'cleric',
    name: 'Cleric',
    hitDie: 8,
    savingThrows: ['Wisdom', 'Charisma'],
    armorProficiencies: ['Light', 'Medium', 'Shields'],
    weaponProficiencies: ['Simple'],
    skillChoiceCount: 2,
    skillOptions: ['History', 'Insight', 'Medicine', 'Persuasion', 'Religion'],
    isSpellcaster: true,
    spellcastingAbility: 'Wisdom',
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'cleric_a',
        label: 'Chain Shirt, Shield, Mace, Holy Symbol, Priest\'s Pack, 7 GP',
        items: [
          ItemGrant('chain_shirt'),
          ItemGrant('shield'),
          ItemGrant('mace'),
          ItemGrant('holy_symbol'),
          ItemGrant('priests_pack'),
        ],
        goldPieces: 7,
      ),
      const StartingEquipmentOption(
        id: 'cleric_b',
        label: '110 GP (buy your own equipment)',
        goldPieces: 110,
      ),
    ],
    levelFeatures: [
      LevelFeature(
        level: 1,
        fixedTraits: [
          'Spellcasting: Wisdom is your spellcasting ability; you can use a Holy Symbol as a Spellcasting Focus',
        ],
        choices: [
          Choice(
            id: 'cleric_divine_order',
            title: 'Choose your Divine Order',
            options: [
              ChoiceOption(
                id: 'protector',
                label: 'Protector',
                description:
                    'Proficiency with Martial weapons and training with Heavy armor.',
                extraWeaponProficiencies: ['Martial'],
                extraArmorProficiencies: ['Heavy'],
              ),
              ChoiceOption(
                id: 'thaumaturge',
                label: 'Thaumaturge',
                description:
                    'An extra cantrip from the Cleric spell list; bonus to Intelligence (Arcana or Religion) checks.',
                extraSelectionsForChoice: {'cleric_cantrips': 1},
              ),
            ],
          ),
          Choice(
            id: 'cleric_cantrips',
            title: 'Choose 3 Cleric cantrips',
            minSelections: 3,
            maxSelections: 3,
            options: [
              ChoiceOption(id: 'guidance', label: 'Guidance'),
              ChoiceOption(id: 'sacred_flame', label: 'Sacred Flame'),
              ChoiceOption(id: 'thaumaturgy', label: 'Thaumaturgy'),
              ChoiceOption(id: 'spare_the_dying', label: 'Spare the Dying'),
              ChoiceOption(id: 'light', label: 'Light'),
              ChoiceOption(id: 'resistance', label: 'Resistance'),
            ],
          ),
          Choice(
            id: 'cleric_prepared_spells',
            title: 'Choose 4 level 1 spells to prepare',
            minSelections: 4,
            maxSelections: 4,
            options: [
              ChoiceOption(id: 'bless', label: 'Bless'),
              ChoiceOption(id: 'cure_wounds', label: 'Cure Wounds'),
              ChoiceOption(id: 'guiding_bolt', label: 'Guiding Bolt'),
              ChoiceOption(id: 'shield_of_faith', label: 'Shield of Faith'),
              ChoiceOption(id: 'healing_word', label: 'Healing Word'),
              ChoiceOption(id: 'sanctuary', label: 'Sanctuary'),
              ChoiceOption(id: 'detect_magic', label: 'Detect Magic'),
              ChoiceOption(id: 'command', label: 'Command'),
            ],
          ),
        ],
      ),
      const LevelFeature(
        level: 2,
        fixedTraits: [
          'Channel Divinity (2 uses, regain 1 per Short Rest, all per Long Rest): Divine Spark or Turn Undead',
        ],
      ),
      LevelFeature(
        level: 3,
        choices: [
          Choice(
            id: 'cleric_subclass',
            title: 'Choose your Divine Domain (subclass)',
            options: [
              ChoiceOption(
                id: 'life',
                label: 'Life Domain',
                description:
                    'Disciple of Life + Preserve Life: focused on healing and vitality (Level 3).',
                levelFeatures: {
                  3: LevelFeature(
                    level: 3,
                    fixedTraits: [
                      'Disciple of Life: your healing spells restore extra Hit Points (2 + spell slot level)',
                      'Preserve Life (Channel Divinity): heal 5 × Cleric level HP, split among Bloodied creatures within 30 ft (max half their HP max each)',
                    ],
                  ),
                  6: LevelFeature(
                    level: 6,
                    fixedTraits: [
                      'Blessed Healer: when you heal others with a spell slot, you also regain HP equal to 2 + the slot\'s level',
                    ],
                  ),
                  17: LevelFeature(
                    level: 17,
                    fixedTraits: [
                      'Supreme Healing: healing dice from spells/Channel Divinity always roll their maximum value',
                    ],
                  ),
                },
              ),
              ChoiceOption(
                id: 'light',
                label: 'Light Domain',
                description:
                    'Radiance of the Dawn + Warding Flare: focused on radiant fire and revelation (Level 3).',
                levelFeatures: {
                  3: LevelFeature(
                    level: 3,
                    fixedTraits: [
                      'Light Domain Spells: always-prepared spells at Cleric levels 3/5/7/9',
                      'Radiance of the Dawn (Channel Divinity): 30 ft emanation, 2d10 + Cleric level Radiant damage (Con save for half), dispels magical Darkness',
                      'Warding Flare: Reaction to impose Disadvantage on an attack roll against a creature you see within 30 ft (uses = Wisdom mod, min 1, recharge on Long Rest)',
                    ],
                  ),
                  6: LevelFeature(
                    level: 6,
                    fixedTraits: [
                      'Improved Warding Flare: recharges on Short or Long Rest; also grants 2d6 + Wisdom mod Temporary Hit Points to the target when used',
                    ],
                  ),
                  17: LevelFeature(
                    level: 17,
                    fixedTraits: [
                      'Corona of Light: 1-minute aura of light; enemies in Bright Light have Disadvantage on saves vs your Radiant/Fire spells and Radiance of the Dawn',
                    ],
                  ),
                },
              ),
              ChoiceOption(
                id: 'trickery',
                label: 'Trickery Domain',
                description:
                    'Blessing of the Trickster + Invoke Duplicity: focused on illusion and misdirection (Level 3).',
                levelFeatures: {
                  3: LevelFeature(
                    level: 3,
                    fixedTraits: [
                      'Blessing of the Trickster: grant Advantage on Dexterity (Stealth) checks to yourself or a willing creature within 30 ft',
                      'Invoke Duplicity (Channel Divinity): create an illusory duplicate of yourself for 1 minute, with Cast Spells/Distract/Move benefits',
                      'Trickery Domain Spells: always-prepared spells at Cleric levels 3/5/7/9',
                    ],
                  ),
                  6: LevelFeature(
                    level: 6,
                    fixedTraits: [
                      'Trickster\'s Transposition: teleport to swap places with your illusion when you move/create it as a Bonus Action',
                    ],
                  ),
                  17: LevelFeature(
                    level: 17,
                    fixedTraits: [
                      'Improved Duplicity: your illusion grants Advantage to attacks near it (Shared Distraction) and heals when it ends (Healing Illusion)',
                    ],
                  ),
                },
              ),
              ChoiceOption(
                id: 'war',
                label: 'War Domain',
                description:
                    'Guided Strike + War Priest: focused on martial prowess in the god\'s name (Level 3).',
                levelFeatures: {
                  3: LevelFeature(
                    level: 3,
                    fixedTraits: [
                      'Guided Strike (Channel Divinity): give +10 to a missed attack roll (yours or an ally\'s within 30 ft, as a Reaction for the latter)',
                      'War Priest: Bonus Action weapon/Unarmed Strike attack, uses = Wisdom mod (min 1), recharge on Short or Long Rest',
                      'War Domain Spells: always-prepared spells at Cleric levels 3/5/7/9',
                    ],
                  ),
                  6: LevelFeature(
                    level: 6,
                    fixedTraits: [
                      'War God\'s Blessing: cast Shield of Faith or Spiritual Weapon via Channel Divinity, without Concentration (lasts 1 minute)',
                    ],
                  ),
                  17: LevelFeature(
                    level: 17,
                    fixedTraits: [
                      'Avatar of Battle: Resistance to Bludgeoning, Piercing, and Slashing damage',
                    ],
                  ),
                },
              ),
            ],
          ),
        ],
      ),
      const LevelFeature(
        level: 4,
        fixedTraits: [
          'Ability Score Improvement: increase one ability score by 2, or two ability scores by 1 each (max 20), or take a Feat',
        ],
        grantsAbilityScoreImprovement: true,
      ),
      const LevelFeature(
        level: 5,
        fixedTraits: [
          'Sear Undead: when you use Turn Undead, Undead that fail their save also take Radiant damage (d8s equal to your Wisdom modifier)',
        ],
      ),
      const LevelFeature(level: 6),
      LevelFeature(
        level: 7,
        choices: [
          Choice(
            id: 'cleric_blessed_strikes',
            title: 'Choose your Blessed Strikes benefit',
            options: [
              ChoiceOption(
                id: 'divine_strike',
                label: 'Divine Strike',
                description:
                    'Once per turn on a weapon hit, deal an extra 1d8 Necrotic or Radiant damage (your choice).',
                levelFeatures: {
                  14: LevelFeature(
                    level: 14,
                    fixedTraits: [
                      'Improved Divine Strike: the extra damage increases to 2d8',
                    ],
                  ),
                },
              ),
              ChoiceOption(
                id: 'potent_spellcasting',
                label: 'Potent Spellcasting',
                description:
                    'Add your Wisdom modifier to the damage of your Cleric cantrips.',
                levelFeatures: {
                  14: LevelFeature(
                    level: 14,
                    fixedTraits: [
                      'Improved Potent Spellcasting: when a damaging cantrip hits, you can grant Temporary Hit Points (2× Wisdom mod) to yourself or another creature within 60 ft',
                    ],
                  ),
                },
              ),
            ],
          ),
        ],
      ),
      const LevelFeature(
        level: 8,
        fixedTraits: [
          'Ability Score Improvement: increase one ability score by 2, or two ability scores by 1 each (max 20), or take a Feat',
        ],
        grantsAbilityScoreImprovement: true,
      ),
      const LevelFeature(level: 9),
      const LevelFeature(
        level: 10,
        fixedTraits: [
          'Divine Intervention: as a Magic action, cast any level 5-or-lower Cleric spell (no Reaction required) without a spell slot or Material components (once per Long Rest)',
        ],
      ),
      const LevelFeature(level: 11),
      const LevelFeature(
        level: 12,
        fixedTraits: [
          'Ability Score Improvement: increase one ability score by 2, or two ability scores by 1 each (max 20), or take a Feat',
        ],
        grantsAbilityScoreImprovement: true,
      ),
      const LevelFeature(level: 13),
      const LevelFeature(level: 14),
      const LevelFeature(level: 15),
      const LevelFeature(
        level: 16,
        fixedTraits: [
          'Ability Score Improvement: increase one ability score by 2, or two ability scores by 1 each (max 20), or take a Feat',
        ],
        grantsAbilityScoreImprovement: true,
      ),
      const LevelFeature(level: 17),
      const LevelFeature(level: 18),
      const LevelFeature(
        level: 19,
        fixedTraits: [
          'Epic Boon: gain an Epic Boon feat of your choice (requires level 19+)',
        ],
        grantsAbilityScoreImprovement: true,
      ),
      const LevelFeature(
        level: 20,
        fixedTraits: [
          'Greater Divine Intervention: your Divine Intervention can now cast Wish (then unusable again until 2d4 Long Rests)',
        ],
      ),
    ],
  ),
  const CharacterClass(
    id: 'druid',
    name: 'Druid',
    hitDie: 8,
    savingThrows: ['Intelligence', 'Wisdom'],
    armorProficiencies: ['Light', 'Shields'],
    weaponProficiencies: ['Simple'],
    skillChoiceCount: 2,
    skillOptions: [
      'Arcana',
      'Animal Handling',
      'Insight',
      'Medicine',
      'Nature',
      'Perception',
      'Religion',
      'Survival',
    ],
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'druid_a',
        label:
            'Leather Armor, Shield, Sickle, Druidic Focus, Explorer\'s Pack, Herbalism Kit, 9 GP',
        items: [
          ItemGrant('leather_armor'),
          ItemGrant('shield'),
          ItemGrant('sickle'),
          ItemGrant('druidic_focus'),
          ItemGrant('explorers_pack'),
          ItemGrant('herbalism_kit'),
        ],
        goldPieces: 9,
      ),
      const StartingEquipmentOption(
        id: 'druid_b',
        label: '50 GP (buy your own equipment)',
        goldPieces: 50,
      ),
    ],
    isSpellcaster: true,
    spellcastingAbility: 'Wisdom',
    levelFeatures: [
      LevelFeature(
        level: 1,
        fixedTraits: [
          'Druidic: you know the secret Druid language; you always have Speak with Animals prepared',
        ],
        choices: [
          Choice(
            id: 'druid_primal_order',
            title: 'Choose your Primal Order',
            options: [
              ChoiceOption(
                id: 'magician',
                label: 'Magician',
                description:
                    'An extra cantrip from the Druid spell list; bonus to Intelligence (Arcana or Nature) checks.',
                extraSelectionsForChoice: {'druid_cantrips': 1},
              ),
              ChoiceOption(
                id: 'warden',
                label: 'Warden',
                description:
                    'Proficiency with Martial weapons and Medium armor.',
                extraWeaponProficiencies: ['Martial'],
                extraArmorProficiencies: ['Medium'],
              ),
            ],
          ),
          Choice(
            id: 'druid_cantrips',
            title: 'Choose 2 Druid cantrips',
            minSelections: 2,
            maxSelections: 2,
            options: [
              ChoiceOption(id: 'druidcraft', label: 'Druidcraft'),
              ChoiceOption(id: 'produce_flame', label: 'Produce Flame'),
              ChoiceOption(id: 'guidance', label: 'Guidance'),
              ChoiceOption(id: 'thorn_whip', label: 'Thorn Whip'),
            ],
          ),
          Choice(
            id: 'druid_prepared_spells',
            title: 'Choose 4 level 1 spells to prepare',
            minSelections: 4,
            maxSelections: 4,
            options: [
              ChoiceOption(id: 'animal_friendship', label: 'Animal Friendship'),
              ChoiceOption(id: 'cure_wounds', label: 'Cure Wounds'),
              ChoiceOption(id: 'faerie_fire', label: 'Faerie Fire'),
              ChoiceOption(id: 'thunderwave', label: 'Thunderwave'),
              ChoiceOption(id: 'entangle', label: 'Entangle'),
              ChoiceOption(id: 'healing_word', label: 'Healing Word'),
            ],
          ),
        ],
      ),
    ],
  ),
  const CharacterClass(
    id: 'fighter',
    name: 'Fighter',
    hitDie: 10,
    savingThrows: ['Strength', 'Constitution'],
    armorProficiencies: ['Light', 'Medium', 'Heavy', 'Shields'],
    weaponProficiencies: ['Simple', 'Martial'],
    skillChoiceCount: 2,
    skillOptions: [
      'Acrobatics',
      'Animal Handling',
      'Athletics',
      'History',
      'Insight',
      'Intimidation',
      'Perception',
      'Survival',
    ],

    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'fighter_a',
        label:
            'Chain Mail, Greatsword, Flail, 8 Javelins, Dungeoneer\'s Pack, 4 GP',
        items: [
          ItemGrant('chain_mail'),
          ItemGrant('greatsword'),
          ItemGrant('flail'),
          ItemGrant('javelin', quantity: 8),
          ItemGrant('dungeoneers_pack'),
        ],
        goldPieces: 4,
      ),
      StartingEquipmentOption(
        id: 'fighter_b',
        label:
            'Studded Leather Armor, Scimitar, Shortsword, Longbow, 20 Arrows, Quiver, Dungeoneer\'s Pack, 11 GP',
        items: [
          ItemGrant('studded_leather_armor'),
          ItemGrant('scimitar'),
          ItemGrant('shortsword'),
          ItemGrant('longbow'),
          ItemGrant('arrow', quantity: 20),
          ItemGrant('quiver'),
          ItemGrant('dungeoneers_pack'),
        ],
        goldPieces: 11,
      ),
      const StartingEquipmentOption(
        id: 'fighter_c',
        label: '155 GP (buy your own equipment)',
        goldPieces: 155,
      ),
    ],
    levelFeatures: [
      LevelFeature(
        level: 1,
        fixedTraits: [
          'Second Wind: Bonus Action, regain 1d10 + Fighter level Hit Points (2 uses, regained on a Short or Long Rest)',
          'Weapon Mastery: use the mastery properties of 3 weapon types of your choice',
        ],
        choices: [
          Choice(
            id: 'fighter_weapon_mastery',
            title: 'Choose 3 weapon types for Weapon Mastery',
            minSelections: 3,
            maxSelections: 3,
            options: [
              ChoiceOption(id: 'club', label: 'Club (Sap)'),
              ChoiceOption(id: 'dagger', label: 'Dagger (Nick)'),
              ChoiceOption(id: 'greatclub', label: 'Greatclub (Push)'),
              ChoiceOption(id: 'handaxe', label: 'Handaxe (Vex)'),
              ChoiceOption(id: 'javelin', label: 'Javelin (Slow)'),
              ChoiceOption(id: 'light_hammer', label: 'Light Hammer (Nick)'),
              ChoiceOption(id: 'mace', label: 'Mace (Sap)'),
              ChoiceOption(id: 'quarterstaff', label: 'Quarterstaff (Topple)'),
              ChoiceOption(id: 'sickle', label: 'Sickle (Nick)'),
              ChoiceOption(id: 'spear', label: 'Spear (Sap)'),
              ChoiceOption(id: 'battleaxe', label: 'Battleaxe (Topple)'),
              ChoiceOption(id: 'flail', label: 'Flail (Sap)'),
              ChoiceOption(id: 'glaive', label: 'Glaive (Graze)'),
              ChoiceOption(id: 'greataxe', label: 'Greataxe (Cleave)'),
              ChoiceOption(id: 'greatsword', label: 'Greatsword (Graze)'),
              ChoiceOption(id: 'halberd', label: 'Halberd (Cleave)'),
              ChoiceOption(id: 'lance', label: 'Lance (Topple)'),
              ChoiceOption(id: 'longsword', label: 'Longsword (Sap)'),
              ChoiceOption(id: 'maul', label: 'Maul (Topple)'),
              ChoiceOption(id: 'morningstar', label: 'Morningstar (Sap)'),
              ChoiceOption(id: 'pike', label: 'Pike (Push)'),
              ChoiceOption(id: 'rapier', label: 'Rapier (Vex)'),
              ChoiceOption(id: 'scimitar', label: 'Scimitar (Nick)'),
              ChoiceOption(id: 'shortsword', label: 'Shortsword (Vex)'),
              ChoiceOption(id: 'trident', label: 'Trident (Topple)'),
              ChoiceOption(id: 'warhammer', label: 'Warhammer (Push)'),
              ChoiceOption(id: 'war_pick', label: 'War Pick (Sap)'),
              ChoiceOption(id: 'whip', label: 'Whip (Slow)'),
              ChoiceOption(id: 'dart', label: 'Dart (Vex)'),
              ChoiceOption(
                id: 'light_crossbow',
                label: 'Light Crossbow (Slow)',
              ),
              ChoiceOption(id: 'shortbow', label: 'Shortbow (Vex)'),
              ChoiceOption(id: 'sling', label: 'Sling (Slow)'),
              ChoiceOption(id: 'hand_crossbow', label: 'Hand Crossbow (Vex)'),
              ChoiceOption(
                id: 'heavy_crossbow',
                label: 'Heavy Crossbow (Push)',
              ),
              ChoiceOption(id: 'longbow', label: 'Longbow (Slow)'),
            ],
          ),
          Choice(
            id: 'fighter_fighting_style',
            title: 'Choose your Fighting Style',
            options: [
              ChoiceOption(
                id: 'archery',
                label: 'Archery',
                description: '+2 to attack rolls with ranged weapons.',
              ),
              ChoiceOption(
                id: 'defense',
                label: 'Defense',
                description: '+1 AC while wearing armor.',
              ),
              ChoiceOption(
                id: 'dueling',
                label: 'Dueling',
                description:
                    '+2 damage with a one-handed weapon and no other weapons.',
              ),
              ChoiceOption(
                id: 'great_weapon_fighting',
                label: 'Great Weapon Fighting',
                description:
                    'Reroll 1s and 2s on Two-Handed weapon damage dice.',
              ),
              ChoiceOption(
                id: 'two_weapon_fighting',
                label: 'Two-Weapon Fighting',
                description:
                    'Add your ability modifier to your second attack\'s damage.',
              ),
              ChoiceOption(
                id: 'unarmed_fighting',
                label: 'Unarmed Fighting',
                description: 'Your Unarmed Strikes deal more damage.',
              ),
            ],
          ),
        ],
      ),
      const LevelFeature(
        level: 2,
        fixedTraits: [
          'Action Surge (1 use): take one additional action on your turn (once per Short or Long Rest)',
          'Tactical Mind: spend a Second Wind use to add 1d10 to a failed ability check',
        ],
      ),
      LevelFeature(
        level: 3,
        choices: [
          Choice(
            id: 'fighter_subclass',
            title: 'Choose your Fighter subclass',
            options: [
              ChoiceOption(
                id: 'battle_master',
                label: 'Battle Master',
                description:
                    'Combat Superiority: superiority dice fuel maneuvers (Level 3).',
                levelFeatures: {
                  7: LevelFeature(
                    level: 7,
                    fixedTraits: [
                      'Know Your Enemy: study a creature to learn its capabilities',
                    ],
                  ),
                  10: LevelFeature(
                    level: 10,
                    fixedTraits: [
                      'Improved Combat Superiority: superiority die upgrades to d10',
                    ],
                  ),
                  15: LevelFeature(
                    level: 15,
                    fixedTraits: [
                      'Relentless: regain a superiority die if you have none left when you roll initiative',
                    ],
                  ),
                  18: LevelFeature(
                    level: 18,
                    fixedTraits: [
                      'Ultimate Combat Superiority: superiority die upgrades to d12',
                    ],
                  ),
                },
              ),
              ChoiceOption(
                id: 'champion',
                label: 'Champion',
                description:
                    'Improved Critical + Remarkable Athlete: wider crit range, added physical prowess (Level 3).',
                levelFeatures: {
                  7: LevelFeature(
                    level: 7,
                    choices: [
                      Choice(
                        id: 'champion_second_fighting_style',
                        title:
                            'Choose a second Fighting Style (Additional Fighting Style)',
                        options: [
                          ChoiceOption(
                            id: 'archery_2',
                            label: 'Archery',
                            description:
                                '+2 to attack rolls with ranged weapons.',
                          ),
                          ChoiceOption(
                            id: 'defense_2',
                            label: 'Defense',
                            description: '+1 AC while wearing armor.',
                          ),
                          ChoiceOption(
                            id: 'dueling_2',
                            label: 'Dueling',
                            description:
                                '+2 damage with a one-handed weapon and no other weapons.',
                          ),
                          ChoiceOption(
                            id: 'great_weapon_fighting_2',
                            label: 'Great Weapon Fighting',
                            description:
                                'Reroll 1s and 2s on Two-Handed weapon damage dice.',
                          ),
                          ChoiceOption(
                            id: 'two_weapon_fighting_2',
                            label: 'Two-Weapon Fighting',
                            description:
                                'Add your ability modifier to your second attack\'s damage.',
                          ),
                          ChoiceOption(
                            id: 'unarmed_fighting_2',
                            label: 'Unarmed Fighting',
                            description:
                                'Your Unarmed Strikes deal more damage.',
                          ),
                        ],
                      ),
                    ],
                  ),
                  10: LevelFeature(
                    level: 10,
                    fixedTraits: [
                      'Heroic Warrior: Advantage on Initiative rolls; gain Heroic Inspiration when you roll low Initiative',
                    ],
                  ),
                  15: LevelFeature(
                    level: 15,
                    fixedTraits: [
                      'Superior Critical: critical hit range widens further',
                    ],
                  ),
                  18: LevelFeature(
                    level: 18,
                    fixedTraits: [
                      'Survivor: regain Hit Points at the start of your turn if below half Hit Points',
                    ],
                  ),
                },
              ),
              ChoiceOption(
                id: 'eldritch_knight',
                label: 'Eldritch Knight',
                description:
                    'War Bond: bond with a weapon; gain Wizard spellcasting (Level 3).',
                levelFeatures: {
                  7: LevelFeature(
                    level: 7,
                    fixedTraits: [
                      'War Magic: replace an attack with a cantrip cast',
                    ],
                  ),
                  10: LevelFeature(
                    level: 10,
                    fixedTraits: [
                      'Eldritch Strike: your weapon hits give Disadvantage on the target\'s next save vs. your spells',
                    ],
                  ),
                  15: LevelFeature(
                    level: 15,
                    fixedTraits: [
                      'Arcane Charge: teleport 30 feet when you use Action Surge',
                    ],
                  ),
                  18: LevelFeature(
                    level: 18,
                    fixedTraits: [
                      'Improved War Magic: replace an attack with a leveled spell cast',
                    ],
                  ),
                },
              ),
              ChoiceOption(
                id: 'psi_warrior',
                label: 'Psi Warrior',
                description:
                    'Psionic Power: Psionic Energy dice fuel telekinetic combat tricks (Level 3).',
                levelFeatures: {
                  7: LevelFeature(
                    level: 7,
                    fixedTraits: [
                      'Telekinetic Adept: added telekinetic combat options',
                    ],
                  ),
                  10: LevelFeature(
                    level: 10,
                    fixedTraits: [
                      'Guarded Mind: resistance to Psychic damage, reduced effects of Charmed/Frightened',
                    ],
                  ),
                  15: LevelFeature(
                    level: 15,
                    fixedTraits: [
                      'Bulwark of Force: telekinetic shield grants resistance to a damage type',
                    ],
                  ),
                  18: LevelFeature(
                    level: 18,
                    fixedTraits: [
                      'Telekinetic Master: cast Telekinesis at will without a spell slot',
                    ],
                  ),
                },
              ),
            ],
          ),
        ],
      ),
      const LevelFeature(
        level: 4,
        fixedTraits: [
          'Ability Score Improvement: increase one ability score by 2, or two ability scores by 1 each (max 20), or take a Feat',
        ],
        grantsAbilityScoreImprovement: true,
      ),
      const LevelFeature(
        level: 5,
        fixedTraits: [
          'Extra Attack: attack twice instead of once whenever you take the Attack action',
          'Tactical Shift: when you activate Second Wind as a Bonus Action, move up to half your Speed without provoking Opportunity Attacks',
        ],
      ),
      const LevelFeature(
        level: 6,
        fixedTraits: [
          'Ability Score Improvement: increase one ability score by 2, or two ability scores by 1 each (max 20), or take a Feat',
        ],
        grantsAbilityScoreImprovement: true,
      ),
      const LevelFeature(level: 7),
      const LevelFeature(
        level: 8,
        fixedTraits: [
          'Ability Score Improvement: increase one ability score by 2, or two ability scores by 1 each (max 20), or take a Feat',
        ],
        grantsAbilityScoreImprovement: true,
      ),
      const LevelFeature(
        level: 9,
        fixedTraits: [
          'Indomitable (1 use): reroll a failed saving throw (once per Long Rest)',
          'Tactical Master: your Weapon Mastery properties can be swapped when you finish a Short or Long Rest',
        ],
      ),
      const LevelFeature(level: 10),
      const LevelFeature(
        level: 11,
        fixedTraits: [
          'Two Extra Attacks: attack three times whenever you take the Attack action',
        ],
      ),
      const LevelFeature(
        level: 12,
        fixedTraits: [
          'Ability Score Improvement: increase one ability score by 2, or two ability scores by 1 each (max 20), or take a Feat',
        ],
        grantsAbilityScoreImprovement: true,
      ),
      const LevelFeature(
        level: 13,
        fixedTraits: [
          'Indomitable (2 uses)',
          'Studied Attacks: Advantage on an attack roll against a creature if your last attack against it this turn missed',
        ],
      ),
      const LevelFeature(
        level: 14,
        fixedTraits: [
          'Ability Score Improvement: increase one ability score by 2, or two ability scores by 1 each (max 20), or take a Feat',
        ],
        grantsAbilityScoreImprovement: true,
      ),
      const LevelFeature(level: 15),
      const LevelFeature(
        level: 16,
        fixedTraits: [
          'Ability Score Improvement: increase one ability score by 2, or two ability scores by 1 each (max 20), or take a Feat',
        ],
        grantsAbilityScoreImprovement: true,
      ),
      const LevelFeature(
        level: 17,
        fixedTraits: ['Action Surge (2 uses)', 'Indomitable (3 uses)'],
      ),
      const LevelFeature(level: 18),
      const LevelFeature(
        level: 19,
        fixedTraits: [
          'Epic Boon: gain an Epic Boon feat of your choice (requires level 19+)',
        ],
        grantsAbilityScoreImprovement: true,
      ),
      const LevelFeature(
        level: 20,
        fixedTraits: [
          'Three Extra Attacks: attack four times whenever you take the Attack action',
        ],
      ),
    ],
  ),

  const CharacterClass(
    id: 'monk',
    name: 'Monk',
    hitDie: 8,
    savingThrows: ['Strength', 'Dexterity'],
    armorProficiencies: [],
    weaponProficiencies: ['Simple', 'Martial weapons with the Light property'],
    skillChoiceCount: 2,
    skillOptions: [
      'Acrobatics',
      'Athletics',
      'History',
      'Insight',
      'Religion',
      'Stealth',
    ],
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'monk_a',
        label: 'Spear, 5 Daggers, Musical Instrument, Explorer\'s Pack, 11 GP',
        items: [
          ItemGrant('spear'),
          ItemGrant('dagger', quantity: 5),
          ItemGrant('musical_instrument'),
          ItemGrant('explorers_pack'),
        ],
        goldPieces: 11,
      ),
      const StartingEquipmentOption(
        id: 'monk_b',
        label: '50 GP (buy your own equipment)',
        goldPieces: 50,
      ),
    ],
    levelFeatures: [
      LevelFeature(
        level: 1,
        fixedTraits: [
          'Martial Arts: mastery of combat styles using Unarmed Strikes and Monk weapons; Bonus Action Unarmed Strike after the Attack action',
          'Unarmored Defense: AC = 10 + Dexterity modifier + Wisdom modifier while not wearing armor or a Shield',
        ],
      ),
    ],
  ),
  const CharacterClass(
    id: 'paladin',
    name: 'Paladin',
    hitDie: 10,
    savingThrows: ['Wisdom', 'Charisma'],
    armorProficiencies: ['Light', 'Medium', 'Heavy', 'Shields'],
    weaponProficiencies: ['Simple', 'Martial'],
    skillChoiceCount: 2,
    skillOptions: [
      'Athletics',
      'Insight',
      'Intimidation',
      'Medicine',
      'Persuasion',
      'Religion',
    ],
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'paladin_a',
        label:
            'Chain Mail, Shield, Longsword, 6 Javelins, Holy Symbol, Priest\'s Pack, 9 GP',
        items: [
          ItemGrant('chain_mail'),
          ItemGrant('shield'),
          ItemGrant('longsword'),
          ItemGrant('javelin', quantity: 6),
          ItemGrant('holy_symbol'),
          ItemGrant('priests_pack'),
        ],
        goldPieces: 9,
      ),
      const StartingEquipmentOption(
        id: 'paladin_b',
        label: '150 GP (buy your own equipment)',
        goldPieces: 150,
      ),
    ],
    isSpellcaster: true,
    spellcastingAbility: 'Charisma',
    levelFeatures: [
      LevelFeature(
        level: 1,
        fixedTraits: [
          'Lay on Hands: healing pool equal to 5 × your Paladin level',
        ],
        choices: [
          Choice(
            id: 'paladin_prepared_spells',
            title: 'Choose 2 level 1 spells to prepare',
            minSelections: 2,
            maxSelections: 2,
            options: [
              ChoiceOption(id: 'heroism', label: 'Heroism'),
              ChoiceOption(id: 'searing_smite', label: 'Searing Smite'),
              ChoiceOption(id: 'bless', label: 'Bless'),
              ChoiceOption(id: 'shield_of_faith', label: 'Shield of Faith'),
            ],
          ),
        ],
      ),
    ],
  ),
  const CharacterClass(
    id: 'ranger',
    name: 'Ranger',
    hitDie: 10,
    savingThrows: ['Strength', 'Dexterity'],
    armorProficiencies: ['Light', 'Medium', 'Shields'],
    weaponProficiencies: ['Simple', 'Martial'],
    skillChoiceCount: 3,
    skillOptions: [
      'Animal Handling',
      'Athletics',
      'Insight',
      'Investigation',
      'Nature',
      'Perception',
      'Stealth',
      'Survival',
    ],
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'ranger_a',
        label:
            'Studded Leather Armor, Scimitar, Shortsword, Longbow, 20 Arrows, Quiver, Druidic Focus, Explorer\'s Pack, 7 GP',
        items: [
          ItemGrant('studded_leather_armor'),
          ItemGrant('scimitar'),
          ItemGrant('shortsword'),
          ItemGrant('longbow'),
          ItemGrant('arrow', quantity: 20),
          ItemGrant('quiver'),
          ItemGrant('druidic_focus'),
          ItemGrant('explorers_pack'),
        ],
        goldPieces: 7,
      ),
      const StartingEquipmentOption(
        id: 'ranger_b',
        label: '150 GP (buy your own equipment)',
        goldPieces: 150,
      ),
    ],
    isSpellcaster: true,
    spellcastingAbility: 'Wisdom',
    levelFeatures: [
      LevelFeature(
        level: 1,
        fixedTraits: [
          'Favored Enemy: you always have Hunter\'s Mark prepared, castable twice without a spell slot',
        ],
        choices: [
          Choice(
            id: 'ranger_prepared_spells',
            title: 'Choose 2 level 1 spells to prepare',
            minSelections: 2,
            maxSelections: 2,
            options: [
              ChoiceOption(id: 'cure_wounds', label: 'Cure Wounds'),
              ChoiceOption(id: 'ensnaring_strike', label: 'Ensnaring Strike'),
              ChoiceOption(id: 'hail_of_thorns', label: 'Hail of Thorns'),
              ChoiceOption(id: 'goodberry', label: 'Goodberry'),
            ],
          ),
        ],
      ),
    ],
  ),
  const CharacterClass(
    id: 'rogue',
    name: 'Rogue',
    hitDie: 8,
    savingThrows: ['Dexterity', 'Intelligence'],
    armorProficiencies: ['Light'],
    weaponProficiencies: [
      'Simple',
      'Martial weapons with the Finesse or Light property',
    ],
    skillChoiceCount: 4,
    skillOptions: [
      'Acrobatics',
      'Athletics',
      'Deception',
      'Insight',
      'Intimidation',
      'Investigation',
      'Perception',
      'Persuasion',
      'Sleight of Hand',
      'Stealth',
    ],
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'rogue_a',
        label:
            'Leather Armor, 2 Daggers, Shortsword, Shortbow, 20 Arrows, Quiver, Thieves\' Tools, Burglar\'s Pack, 8 GP',
        items: [
          ItemGrant('leather_armor'),
          ItemGrant('dagger', quantity: 2),
          ItemGrant('shortsword'),
          ItemGrant('shortbow'),
          ItemGrant('arrow', quantity: 20),
          ItemGrant('quiver'),
          ItemGrant('thieves_tools'),
          ItemGrant('burglars_pack'),
        ],
        goldPieces: 8,
      ),
      const StartingEquipmentOption(
        id: 'rogue_b',
        label: '100 GP (buy your own equipment)',
        goldPieces: 100,
      ),
    ],
    levelFeatures: [
      LevelFeature(
        level: 1,
        fixedTraits: [
          'Expertise: double your proficiency bonus for 2 of your skill (or Thieves\' Tools) proficiencies',
          'Sneak Attack: extra 1d6 damage once per turn with Advantage or an ally adjacent to the target',
          'Thieves\' Cant: a secret jargon for hiding messages',
        ],
      ),
    ],
  ),
  const CharacterClass(
    id: 'sorcerer',
    name: 'Sorcerer',
    hitDie: 6,
    savingThrows: ['Constitution', 'Charisma'],
    armorProficiencies: [],
    weaponProficiencies: ['Simple'],
    skillChoiceCount: 2,
    skillOptions: [
      'Arcana',
      'Deception',
      'Insight',
      'Intimidation',
      'Persuasion',
      'Religion',
    ],
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'sorcerer_a',
        label: 'Spear, 2 Daggers, Arcane Focus, Dungeoneer\'s Pack, 28 GP',
        items: [
          ItemGrant('spear'),
          ItemGrant('dagger', quantity: 2),
          ItemGrant('arcane_focus'),
          ItemGrant('dungeoneers_pack'),
        ],
        goldPieces: 28,
      ),
      const StartingEquipmentOption(
        id: 'sorcerer_b',
        label: '50 GP (buy your own equipment)',
        goldPieces: 50,
      ),
    ],
    isSpellcaster: true,
    spellcastingAbility: 'Charisma',
    levelFeatures: [
      LevelFeature(
        level: 1,
        choices: [
          Choice(
            id: 'sorcerer_cantrips',
            title: 'Choose 4 Sorcerer cantrips',
            minSelections: 4,
            maxSelections: 4,
            options: [
              ChoiceOption(id: 'light', label: 'Light'),
              ChoiceOption(id: 'prestidigitation', label: 'Prestidigitation'),
              ChoiceOption(id: 'shocking_grasp', label: 'Shocking Grasp'),
              ChoiceOption(id: 'sorcerous_burst', label: 'Sorcerous Burst'),
              ChoiceOption(id: 'mage_hand', label: 'Mage Hand'),
            ],
          ),
          Choice(
            id: 'sorcerer_known_spells',
            title: 'Choose 2 level 1 spells known',
            minSelections: 2,
            maxSelections: 2,
            options: [
              ChoiceOption(id: 'burning_hands', label: 'Burning Hands'),
              ChoiceOption(id: 'detect_magic', label: 'Detect Magic'),
              ChoiceOption(id: 'magic_missile', label: 'Magic Missile'),
              ChoiceOption(id: 'shield', label: 'Shield'),
            ],
          ),
        ],
      ),
    ],
  ),
  const CharacterClass(
    id: 'warlock',
    name: 'Warlock',
    hitDie: 8,
    savingThrows: ['Wisdom', 'Charisma'],
    armorProficiencies: ['Light'],
    weaponProficiencies: ['Simple'],
    skillChoiceCount: 2,
    skillOptions: [
      'Arcana',
      'Deception',
      'History',
      'Intimidation',
      'Investigation',
      'Nature',
      'Religion',
    ],
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'warlock_a',
        label:
            'Leather Armor, Sickle, 2 Daggers, Arcane Focus, Book, Scholar\'s Pack, 15 GP',
        items: [
          ItemGrant('leather_armor'),
          ItemGrant('sickle'),
          ItemGrant('dagger', quantity: 2),
          ItemGrant('arcane_focus'),
          ItemGrant('book'),
          ItemGrant('scholars_pack'),
        ],
        goldPieces: 15,
      ),
      const StartingEquipmentOption(
        id: 'warlock_b',
        label: '100 GP (buy your own equipment)',
        goldPieces: 100,
      ),
    ],
    isSpellcaster: true,
    spellcastingAbility: 'Charisma',
    levelFeatures: [
      LevelFeature(
        level: 1,
        fixedTraits: [
          'Eldritch Invocations: 1 invocation of your choice',
          'Pact Magic: spell slots are regained on a Short Rest, not a Long Rest',
        ],
        choices: [
          Choice(
            id: 'warlock_cantrips',
            title: 'Choose 2 Warlock cantrips',
            minSelections: 2,
            maxSelections: 2,
            options: [
              ChoiceOption(id: 'eldritch_blast', label: 'Eldritch Blast'),
              ChoiceOption(id: 'prestidigitation', label: 'Prestidigitation'),
              ChoiceOption(id: 'minor_illusion', label: 'Minor Illusion'),
              ChoiceOption(id: 'chill_touch', label: 'Chill Touch'),
            ],
          ),
          Choice(
            id: 'warlock_known_spells',
            title: 'Choose 2 level 1 spells known',
            minSelections: 2,
            maxSelections: 2,
            options: [
              ChoiceOption(id: 'hex', label: 'Hex'),
              ChoiceOption(id: 'armor_of_agathys', label: 'Armor of Agathys'),
              ChoiceOption(id: 'charm_person', label: 'Charm Person'),
              ChoiceOption(
                id: 'expeditious_retreat',
                label: 'Expeditious Retreat',
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  const CharacterClass(
    id: 'wizard',
    name: 'Wizard',
    hitDie: 6,
    savingThrows: ['Intelligence', 'Wisdom'],
    armorProficiencies: [],
    weaponProficiencies: ['Simple'],
    skillChoiceCount: 2,
    skillOptions: [
      'Arcana',
      'History',
      'Insight',
      'Investigation',
      'Medicine',
      'Nature',
      'Religion',
    ],
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'wizard_a',
        label:
            '2 Daggers, Arcane Focus, Robe, Spellbook, Scholar\'s Pack, 5 GP',
        items: [
          ItemGrant('dagger', quantity: 2),
          ItemGrant('arcane_focus'),
          ItemGrant('robe'),
          ItemGrant('spellbook'),
          ItemGrant('scholars_pack'),
        ],
        goldPieces: 5,
      ),
      const StartingEquipmentOption(
        id: 'wizard_b',
        label: '55 GP (buy your own equipment)',
        goldPieces: 55,
      ),
    ],
    isSpellcaster: true,
    spellcastingAbility: 'Intelligence',
    levelFeatures: [
      LevelFeature(
        level: 1,
        fixedTraits: [
          'Spellbook: contains the spells you know (starts with 6 level 1 spells)',
        ],
        choices: [
          Choice(
            id: 'wizard_cantrips',
            title: 'Choose 3 Wizard cantrips',
            minSelections: 3,
            maxSelections: 3,
            options: [
              ChoiceOption(id: 'light', label: 'Light'),
              ChoiceOption(id: 'mage_hand', label: 'Mage Hand'),
              ChoiceOption(id: 'ray_of_frost', label: 'Ray of Frost'),
              ChoiceOption(id: 'fire_bolt', label: 'Fire Bolt'),
              ChoiceOption(id: 'minor_illusion', label: 'Minor Illusion'),
            ],
          ),
          Choice(
            id: 'wizard_spellbook',
            title: 'Choose 6 level 1 spells for your Spellbook',
            minSelections: 6,
            maxSelections: 6,
            options: [
              ChoiceOption(id: 'detect_magic', label: 'Detect Magic'),
              ChoiceOption(id: 'feather_fall', label: 'Feather Fall'),
              ChoiceOption(id: 'mage_armor', label: 'Mage Armor'),
              ChoiceOption(id: 'magic_missile', label: 'Magic Missile'),
              ChoiceOption(id: 'sleep', label: 'Sleep'),
              ChoiceOption(id: 'thunderwave', label: 'Thunderwave'),
              ChoiceOption(id: 'shield', label: 'Shield'),
              ChoiceOption(id: 'burning_hands', label: 'Burning Hands'),
            ],
          ),
          Choice(
            id: 'wizard_prepared_spells',
            title: 'Choose 4 spells from your Spellbook to prepare',
            minSelections: 4,
            maxSelections: 4,
            options: [
              ChoiceOption(id: 'detect_magic', label: 'Detect Magic'),
              ChoiceOption(id: 'feather_fall', label: 'Feather Fall'),
              ChoiceOption(id: 'mage_armor', label: 'Mage Armor'),
              ChoiceOption(id: 'magic_missile', label: 'Magic Missile'),
              ChoiceOption(id: 'sleep', label: 'Sleep'),
              ChoiceOption(id: 'thunderwave', label: 'Thunderwave'),
              ChoiceOption(id: 'shield', label: 'Shield'),
              ChoiceOption(id: 'burning_hands', label: 'Burning Hands'),
            ],
          ),
        ],
      ),
    ],
  ),
];
