import '../models/background.dart';
import '../models/ability_scores.dart';
import '../models/choice.dart';
import '../models/starting_equipment.dart';

final List<Background> allBackgrounds = [
  Background(
    id: 'acolyte',
    name: 'Acolyte',
    description:
        'You served in a temple, studying the sacred rites of a deity.',
    abilityScoreOptions: [
      Ability.intelligence,
      Ability.wisdom,
      Ability.charisma,
    ],
    originFeatName: 'Magic Initiate (Cleric)',
    originFeatDescription:
        'You learn 2 cantrips and one level 1 spell from the Cleric spell list; the level 1 spell is castable once per Long Rest without a spell slot.',
    skillProficiencies: const ['Insight', 'Religion'],
    toolProficiency: 'Calligrapher\'s Supplies',
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'acolyte_a',
        label:
            'Calligrapher\'s Supplies, Book, Holy Symbol, 10 Parchment, Robe, 8 GP',
        items: [
          ItemGrant('calligraphers_supplies'),
          ItemGrant('book'),
          ItemGrant('holy_symbol'),
          ItemGrant('parchment', quantity: 10),
          ItemGrant('robe'),
        ],
        goldPieces: 8,
      ),
      const StartingEquipmentOption(
        id: 'acolyte_b',
        label: '50 GP (buy your own equipment)',
        goldPieces: 50,
      ),
    ],
    choices: [
      Choice(
        id: 'acolyte_magic_initiate_cantrips',
        title: 'Choose 2 Cleric cantrips (Magic Initiate)',
        minSelections: 2,
        maxSelections: 2,
        options: const [
          ChoiceOption(id: 'guidance', label: 'Guidance'),
          ChoiceOption(id: 'sacred_flame', label: 'Sacred Flame'),
          ChoiceOption(id: 'thaumaturgy', label: 'Thaumaturgy'),
          ChoiceOption(id: 'spare_the_dying', label: 'Spare the Dying'),
          ChoiceOption(id: 'light', label: 'Light'),
        ],
      ),
      Choice(
        id: 'acolyte_magic_initiate_spell',
        title: 'Choose 1 level 1 Cleric spell (Magic Initiate)',
        options: const [
          ChoiceOption(id: 'bless', label: 'Bless'),
          ChoiceOption(id: 'cure_wounds', label: 'Cure Wounds'),
          ChoiceOption(id: 'healing_word', label: 'Healing Word'),
          ChoiceOption(id: 'detect_magic', label: 'Detect Magic'),
        ],
      ),
    ],
  ),
  Background(
    id: 'artisan',
    name: 'Artisan',
    description: 'You learned a craft, working in a workshop from a young age.',
    abilityScoreOptions: [
      Ability.strength,
      Ability.dexterity,
      Ability.intelligence,
    ],
    originFeatName: 'Crafter',
    originFeatDescription:
        'Proficiency with one kind of Artisan\'s Tools of your choice; you craft nonmagical items faster and at a discount on material costs.',
    skillProficiencies: const ['Investigation', 'Persuasion'],
    toolProficiency: 'One kind of Artisan\'s Tools of your choice',
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'artisan_a',
        label:
            'Artisan\'s Tools (your choice), 2 Pouches, Traveler\'s Clothes, 32 GP',
        items: [
          ItemGrant('smiths_tools'),
          ItemGrant('pouch', quantity: 2),
          ItemGrant('travelers_clothes'),
        ],
        goldPieces: 32,
      ),
      const StartingEquipmentOption(
        id: 'artisan_b',
        label: '50 GP (buy your own equipment)',
        goldPieces: 50,
      ),
    ],
  ),
  Background(
    id: 'charlatan',
    name: 'Charlatan',
    description:
        'You lived a life of deception, cons, and false identities across countless taverns.',
    abilityScoreOptions: [
      Ability.dexterity,
      Ability.constitution,
      Ability.charisma,
    ],
    originFeatName: 'Skilled',
    originFeatDescription:
        'You gain proficiency in 3 skills or tools of your choice.',
    skillProficiencies: const ['Deception', 'Sleight of Hand'],
    toolProficiency: 'Forgery Kit',
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'charlatan_a',
        label: 'Forgery Kit, Costume, Fine Clothes, 15 GP',
        items: [
          ItemGrant('forgery_kit'),
          ItemGrant('costume'),
          ItemGrant('fine_clothes'),
        ],
        goldPieces: 15,
      ),
      const StartingEquipmentOption(
        id: 'charlatan_b',
        label: '50 GP (buy your own equipment)',
        goldPieces: 50,
      ),
    ],
    choices: [
      Choice(
        id: 'charlatan_skilled',
        title: 'Choose 3 skills or tools (Skilled feat)',
        minSelections: 3,
        maxSelections: 3,
        options: const [
          ChoiceOption(id: 'acrobatics', label: 'Acrobatics'),
          ChoiceOption(id: 'animal_handling', label: 'Animal Handling'),
          ChoiceOption(id: 'arcana', label: 'Arcana'),
          ChoiceOption(id: 'athletics', label: 'Athletics'),
          ChoiceOption(id: 'history', label: 'History'),
          ChoiceOption(id: 'insight', label: 'Insight'),
          ChoiceOption(id: 'intimidation', label: 'Intimidation'),
          ChoiceOption(id: 'investigation', label: 'Investigation'),
          ChoiceOption(id: 'medicine', label: 'Medicine'),
          ChoiceOption(id: 'nature', label: 'Nature'),
          ChoiceOption(id: 'perception', label: 'Perception'),
          ChoiceOption(id: 'performance', label: 'Performance'),
          ChoiceOption(id: 'religion', label: 'Religion'),
          ChoiceOption(id: 'stealth', label: 'Stealth'),
          ChoiceOption(id: 'survival', label: 'Survival'),
        ],
      ),
    ],
  ),
  Background(
    id: 'criminal',
    name: 'Criminal',
    description:
        'You lived on the margins of society, often engaged in illegal activity.',
    abilityScoreOptions: [
      Ability.dexterity,
      Ability.constitution,
      Ability.intelligence,
    ],
    originFeatName: 'Alert',
    originFeatDescription:
        'You add your Proficiency Bonus to Initiative rolls; you can swap your Initiative with a willing ally.',
    skillProficiencies: const ['Sleight of Hand', 'Stealth'],
    toolProficiency: 'Thieves\' Tools',
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'criminal_a',
        label:
            '2 Daggers, Thieves\' Tools, Crowbar, 2 Pouches, Traveler\'s Clothes, 16 GP',
        items: [
          ItemGrant('dagger', quantity: 2),
          ItemGrant('thieves_tools'),
          ItemGrant('crowbar'),
          ItemGrant('pouch', quantity: 2),
          ItemGrant('travelers_clothes'),
        ],
        goldPieces: 16,
      ),
      const StartingEquipmentOption(
        id: 'criminal_b',
        label: '50 GP (buy your own equipment)',
        goldPieces: 50,
      ),
    ],
  ),
  Background(
    id: 'entertainer',
    name: 'Entertainer',
    description:
        'You traveled between fairs and carnivals, performing for the public.',
    abilityScoreOptions: [
      Ability.strength,
      Ability.dexterity,
      Ability.charisma,
    ],
    originFeatName: 'Musician',
    originFeatDescription:
        'Proficiency with 3 Musical Instruments of your choice; you can inspire allies by performing during a Short or Long Rest.',
    skillProficiencies: const ['Acrobatics', 'Performance'],
    toolProficiency: 'One Musical Instrument of your choice',
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'entertainer_a',
        label:
            'Musical Instrument, 2 Costumes, Mirror, Perfume, Traveler\'s Clothes, 11 GP',
        items: [
          ItemGrant('musical_instrument'),
          ItemGrant('costume', quantity: 2),
          ItemGrant('mirror'),
          ItemGrant('perfume'),
          ItemGrant('travelers_clothes'),
        ],
        goldPieces: 11,
      ),
      const StartingEquipmentOption(
        id: 'entertainer_b',
        label: '50 GP (buy your own equipment)',
        goldPieces: 50,
      ),
    ],
  ),
  Background(
    id: 'farmer',
    name: 'Farmer',
    description:
        'You grew up close to the land, tending animals and cultivating the earth.',
    abilityScoreOptions: [
      Ability.strength,
      Ability.constitution,
      Ability.wisdom,
    ],
    originFeatName: 'Tough',
    originFeatDescription:
        'Your Hit Point maximum increases by 2 for every level you have.',
    skillProficiencies: const ['Animal Handling', 'Nature'],
    toolProficiency: 'Carpenter\'s Tools',
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'farmer_a',
        label:
            'Sickle, Carpenter\'s Tools, Healer\'s Kit, Iron Pot, Shovel, Traveler\'s Clothes, 30 GP',
        items: [
          ItemGrant('sickle'),
          ItemGrant('carpenters_tools'),
          ItemGrant('healers_kit'),
          ItemGrant('pot_iron'),
          ItemGrant('shovel'),
          ItemGrant('travelers_clothes'),
        ],
        goldPieces: 30,
      ),
      const StartingEquipmentOption(
        id: 'farmer_b',
        label: '50 GP (buy your own equipment)',
        goldPieces: 50,
      ),
    ],
  ),
  Background(
    id: 'guard',
    name: 'Guard',
    description: 'You watched over walls, gates, or prisons, keeping order.',
    abilityScoreOptions: [
      Ability.strength,
      Ability.intelligence,
      Ability.wisdom,
    ],
    originFeatName: 'Alert',
    originFeatDescription:
        'You add your Proficiency Bonus to Initiative rolls; you can swap your Initiative with a willing ally.',
    skillProficiencies: const ['Athletics', 'Perception'],
    toolProficiency: 'One kind of Gaming Set of your choice',
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'guard_a',
        label:
            'Spear, Light Crossbow, 20 Bolts, Gaming Set, Hooded Lantern, Manacles, Quiver, Traveler\'s Clothes, 12 GP',
        items: [
          ItemGrant('spear'),
          ItemGrant('light_crossbow'),
          ItemGrant('crossbow_bolt', quantity: 20),
          ItemGrant('gaming_set'),
          ItemGrant('hooded_lantern'),
          ItemGrant('manacles'),
          ItemGrant('quiver'),
          ItemGrant('travelers_clothes'),
        ],
        goldPieces: 12,
      ),
      const StartingEquipmentOption(
        id: 'guard_b',
        label: '50 GP (buy your own equipment)',
        goldPieces: 50,
      ),
    ],
  ),
  Background(
    id: 'guide',
    name: 'Guide',
    description:
        'You grew up outdoors, far from settled lands, learning to fend for yourself.',
    abilityScoreOptions: [
      Ability.dexterity,
      Ability.constitution,
      Ability.wisdom,
    ],
    originFeatName: 'Magic Initiate (Druid)',
    originFeatDescription:
        'You learn 2 cantrips and one level 1 spell from the Druid spell list; the level 1 spell is castable once per Long Rest without a spell slot.',
    skillProficiencies: const ['Stealth', 'Survival'],
    toolProficiency: 'Cartographer\'s Tools',
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'guide_a',
        label:
            'Shortbow, 20 Arrows, Cartographer\'s Tools, Bedroll, Quiver, Tent, Traveler\'s Clothes, 3 GP',
        items: [
          ItemGrant('shortbow'),
          ItemGrant('arrow', quantity: 20),
          ItemGrant('cartographers_tools'),
          ItemGrant('bedroll'),
          ItemGrant('quiver'),
          ItemGrant('tent'),
          ItemGrant('travelers_clothes'),
        ],
        goldPieces: 3,
      ),
      const StartingEquipmentOption(
        id: 'guide_b',
        label: '50 GP (buy your own equipment)',
        goldPieces: 50,
      ),
    ],
    choices: [
      Choice(
        id: 'guide_magic_initiate_cantrips',
        title: 'Choose 2 Druid cantrips (Magic Initiate)',
        minSelections: 2,
        maxSelections: 2,
        options: const [
          ChoiceOption(id: 'druidcraft', label: 'Druidcraft'),
          ChoiceOption(id: 'produce_flame', label: 'Produce Flame'),
          ChoiceOption(id: 'guidance', label: 'Guidance'),
          ChoiceOption(id: 'thorn_whip', label: 'Thorn Whip'),
        ],
      ),
      Choice(
        id: 'guide_magic_initiate_spell',
        title: 'Choose 1 level 1 Druid spell (Magic Initiate)',
        options: const [
          ChoiceOption(id: 'animal_friendship', label: 'Animal Friendship'),
          ChoiceOption(id: 'entangle', label: 'Entangle'),
          ChoiceOption(id: 'thunderwave', label: 'Thunderwave'),
          ChoiceOption(id: 'cure_wounds', label: 'Cure Wounds'),
        ],
      ),
    ],
  ),
  Background(
    id: 'hermit',
    name: 'Hermit',
    description:
        'You lived in seclusion, in a hut or monastery far from the nearest settlement.',
    abilityScoreOptions: [
      Ability.constitution,
      Ability.wisdom,
      Ability.charisma,
    ],
    originFeatName: 'Healer',
    originFeatDescription:
        'Using a Healer\'s Kit, you can restore Hit Points to a creature with an action (1d6 plus twice your Proficiency Bonus).',
    skillProficiencies: const ['Medicine', 'Religion'],
    toolProficiency: 'Herbalism Kit',
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'hermit_a',
        label:
            'Quarterstaff, Herbalism Kit, Bedroll, Book, Lamp, 3 Oil, Traveler\'s Clothes, 16 GP',
        items: [
          ItemGrant('quarterstaff'),
          ItemGrant('herbalism_kit'),
          ItemGrant('bedroll'),
          ItemGrant('book'),
          ItemGrant('lamp'),
          ItemGrant('oil_flask', quantity: 3),
          ItemGrant('travelers_clothes'),
        ],
        goldPieces: 16,
      ),
      const StartingEquipmentOption(
        id: 'hermit_b',
        label: '50 GP (buy your own equipment)',
        goldPieces: 50,
      ),
    ],
  ),
  Background(
    id: 'merchant',
    name: 'Merchant',
    description:
        'You apprenticed to a trader or caravan master, learning the fundamentals of commerce.',
    abilityScoreOptions: [
      Ability.constitution,
      Ability.intelligence,
      Ability.charisma,
    ],
    originFeatName: 'Lucky',
    originFeatDescription:
        'You have Luck Points equal to your Proficiency Bonus (regained on a Long Rest). Spend 1 to give yourself Advantage on a d20 Test, or to impose Disadvantage on an attack roll made against you.',
    skillProficiencies: const ['Animal Handling', 'Persuasion'],
    toolProficiency: 'Navigator\'s Tools',
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'merchant_a',
        label: 'Navigator\'s Tools, 2 Pouches, Traveler\'s Clothes, 22 GP',
        items: [
          ItemGrant('navigators_tools'),
          ItemGrant('pouch', quantity: 2),
          ItemGrant('travelers_clothes'),
        ],
        goldPieces: 22,
      ),
      const StartingEquipmentOption(
        id: 'merchant_b',
        label: '50 GP (buy your own equipment)',
        goldPieces: 50,
      ),
    ],
  ),
  Background(
    id: 'noble',
    name: 'Noble',
    description:
        'You were raised in a castle, surrounded by wealth, power, and privilege.',
    abilityScoreOptions: [
      Ability.strength,
      Ability.intelligence,
      Ability.charisma,
    ],
    originFeatName: 'Skilled',
    originFeatDescription:
        'You gain proficiency in 3 skills or tools of your choice.',
    skillProficiencies: const ['History', 'Persuasion'],
    toolProficiency: 'One kind of Gaming Set of your choice',
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'noble_a',
        label: 'Gaming Set, Fine Clothes, Perfume, 29 GP',
        items: [
          ItemGrant('gaming_set'),
          ItemGrant('fine_clothes'),
          ItemGrant('perfume'),
        ],
        goldPieces: 29,
      ),
      const StartingEquipmentOption(
        id: 'noble_b',
        label: '50 GP (buy your own equipment)',
        goldPieces: 50,
      ),
    ],
    choices: [
      Choice(
        id: 'noble_skilled',
        title: 'Choose 3 skills or tools (Skilled feat)',
        minSelections: 3,
        maxSelections: 3,
        options: const [
          ChoiceOption(id: 'acrobatics', label: 'Acrobatics'),
          ChoiceOption(id: 'animal_handling', label: 'Animal Handling'),
          ChoiceOption(id: 'arcana', label: 'Arcana'),
          ChoiceOption(id: 'athletics', label: 'Athletics'),
          ChoiceOption(id: 'deception', label: 'Deception'),
          ChoiceOption(id: 'insight', label: 'Insight'),
          ChoiceOption(id: 'intimidation', label: 'Intimidation'),
          ChoiceOption(id: 'investigation', label: 'Investigation'),
          ChoiceOption(id: 'medicine', label: 'Medicine'),
          ChoiceOption(id: 'nature', label: 'Nature'),
          ChoiceOption(id: 'perception', label: 'Perception'),
          ChoiceOption(id: 'performance', label: 'Performance'),
          ChoiceOption(id: 'religion', label: 'Religion'),
          ChoiceOption(id: 'stealth', label: 'Stealth'),
          ChoiceOption(id: 'survival', label: 'Survival'),
        ],
      ),
    ],
  ),
  Background(
    id: 'sage',
    name: 'Sage',
    description:
        'You spent your formative years traveling between manors and monasteries, studying ancient texts.',
    abilityScoreOptions: [
      Ability.constitution,
      Ability.intelligence,
      Ability.wisdom,
    ],
    originFeatName: 'Magic Initiate (Wizard)',
    originFeatDescription:
        'You learn 2 cantrips and one level 1 spell from the Wizard spell list; the level 1 spell is castable once per Long Rest without a spell slot.',
    skillProficiencies: const ['Arcana', 'History'],
    toolProficiency: 'Calligrapher\'s Supplies',
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'sage_a',
        label:
            'Quarterstaff, Calligrapher\'s Supplies, Book, 8 Parchment, Robe, 8 GP',
        items: [
          ItemGrant('quarterstaff'),
          ItemGrant('calligraphers_supplies'),
          ItemGrant('book'),
          ItemGrant('parchment', quantity: 8),
          ItemGrant('robe'),
        ],
        goldPieces: 8,
      ),
      const StartingEquipmentOption(
        id: 'sage_b',
        label: '50 GP (buy your own equipment)',
        goldPieces: 50,
      ),
    ],
    choices: [
      Choice(
        id: 'sage_magic_initiate_cantrips',
        title: 'Choose 2 Wizard cantrips (Magic Initiate)',
        minSelections: 2,
        maxSelections: 2,
        options: const [
          ChoiceOption(id: 'light', label: 'Light'),
          ChoiceOption(id: 'mage_hand', label: 'Mage Hand'),
          ChoiceOption(id: 'ray_of_frost', label: 'Ray of Frost'),
          ChoiceOption(id: 'fire_bolt', label: 'Fire Bolt'),
          ChoiceOption(id: 'minor_illusion', label: 'Minor Illusion'),
        ],
      ),
      Choice(
        id: 'sage_magic_initiate_spell',
        title: 'Choose 1 level 1 Wizard spell (Magic Initiate)',
        options: const [
          ChoiceOption(id: 'detect_magic', label: 'Detect Magic'),
          ChoiceOption(id: 'magic_missile', label: 'Magic Missile'),
          ChoiceOption(id: 'shield', label: 'Shield'),
          ChoiceOption(id: 'sleep', label: 'Sleep'),
        ],
      ),
    ],
  ),
  Background(
    id: 'sailor',
    name: 'Sailor',
    description:
        'You lived as a seafarer, wind at your back and decks swaying beneath your feet.',
    abilityScoreOptions: [Ability.strength, Ability.dexterity, Ability.wisdom],
    originFeatName: 'Tavern Brawler',
    originFeatDescription:
        'Proficiency with improvised weapons and Unarmed Strikes (1d6 Bludgeoning damage); Advantage on checks to avoid being shoved, grappled, or knocked Prone.',
    skillProficiencies: const ['Acrobatics', 'Perception'],
    toolProficiency: 'Navigator\'s Tools',
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'sailor_a',
        label: 'Dagger, Navigator\'s Tools, Rope, Traveler\'s Clothes, 20 GP',
        items: [
          ItemGrant('dagger'),
          ItemGrant('navigators_tools'),
          ItemGrant('rope'),
          ItemGrant('travelers_clothes'),
        ],
        goldPieces: 20,
      ),
      const StartingEquipmentOption(
        id: 'sailor_b',
        label: '50 GP (buy your own equipment)',
        goldPieces: 50,
      ),
    ],
  ),
  Background(
    id: 'scribe',
    name: 'Scribe',
    description:
        'You worked in a scriptorium or government office, carefully transcribing texts.',
    abilityScoreOptions: [
      Ability.dexterity,
      Ability.intelligence,
      Ability.wisdom,
    ],
    originFeatName: 'Skilled',
    originFeatDescription:
        'You gain proficiency in 3 skills or tools of your choice.',
    skillProficiencies: const ['Investigation', 'Perception'],
    toolProficiency: 'Calligrapher\'s Supplies',
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'scribe_a',
        label:
            'Calligrapher\'s Supplies, Fine Clothes, Lamp, 3 Oil, 12 Parchment, 23 GP',
        items: [
          ItemGrant('calligraphers_supplies'),
          ItemGrant('fine_clothes'),
          ItemGrant('lamp'),
          ItemGrant('oil_flask', quantity: 3),
          ItemGrant('parchment', quantity: 12),
        ],
        goldPieces: 23,
      ),
      const StartingEquipmentOption(
        id: 'scribe_b',
        label: '50 GP (buy your own equipment)',
        goldPieces: 50,
      ),
    ],
    choices: [
      Choice(
        id: 'scribe_skilled',
        title: 'Choose 3 skills or tools (Skilled feat)',
        minSelections: 3,
        maxSelections: 3,
        options: const [
          ChoiceOption(id: 'acrobatics', label: 'Acrobatics'),
          ChoiceOption(id: 'animal_handling', label: 'Animal Handling'),
          ChoiceOption(id: 'arcana', label: 'Arcana'),
          ChoiceOption(id: 'athletics', label: 'Athletics'),
          ChoiceOption(id: 'deception', label: 'Deception'),
          ChoiceOption(id: 'history', label: 'History'),
          ChoiceOption(id: 'insight', label: 'Insight'),
          ChoiceOption(id: 'medicine', label: 'Medicine'),
          ChoiceOption(id: 'nature', label: 'Nature'),
          ChoiceOption(id: 'persuasion', label: 'Persuasion'),
          ChoiceOption(id: 'religion', label: 'Religion'),
          ChoiceOption(id: 'stealth', label: 'Stealth'),
          ChoiceOption(id: 'survival', label: 'Survival'),
        ],
      ),
    ],
  ),
  Background(
    id: 'soldier',
    name: 'Soldier',
    description:
        'You served in an army, learning discipline and battlefield tactics.',
    abilityScoreOptions: [
      Ability.strength,
      Ability.dexterity,
      Ability.constitution,
    ],
    originFeatName: 'Savage Attacker',
    originFeatDescription:
        'Once per turn, when you roll damage for a weapon, you can roll the damage dice twice and use either total.',
    skillProficiencies: const ['Athletics', 'Intimidation'],
    toolProficiency: 'One kind of Gaming Set of your choice',
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'soldier_a',
        label:
            'Spear, Shortbow, 20 Arrows, Gaming Set, Healer\'s Kit, Quiver, Traveler\'s Clothes, 14 GP',
        items: [
          ItemGrant('spear'),
          ItemGrant('shortbow'),
          ItemGrant('arrow', quantity: 20),
          ItemGrant('gaming_set'),
          ItemGrant('healers_kit'),
          ItemGrant('quiver'),
          ItemGrant('travelers_clothes'),
        ],
        goldPieces: 14,
      ),
      const StartingEquipmentOption(
        id: 'soldier_b',
        label: '50 GP (buy your own equipment)',
        goldPieces: 50,
      ),
    ],
  ),
  Background(
    id: 'wayfarer',
    name: 'Wayfarer',
    description:
        'You grew up on the streets, getting by on odd jobs and, at times, petty theft.',
    abilityScoreOptions: [Ability.dexterity, Ability.wisdom, Ability.charisma],
    originFeatName: 'Lucky',
    originFeatDescription:
        'You have Luck Points equal to your Proficiency Bonus (regained on a Long Rest). Spend 1 to give yourself Advantage on a d20 Test, or to impose Disadvantage on an attack roll made against you.',
    skillProficiencies: const ['Insight', 'Stealth'],
    toolProficiency: 'Thieves\' Tools',
    startingEquipmentOptions: [
      StartingEquipmentOption(
        id: 'wayfarer_a',
        label:
            '2 Daggers, Thieves\' Tools, Gaming Set, Bedroll, 2 Pouches, Traveler\'s Clothes, 16 GP',
        items: [
          ItemGrant('dagger', quantity: 2),
          ItemGrant('thieves_tools'),
          ItemGrant('gaming_set'),
          ItemGrant('bedroll'),
          ItemGrant('pouch', quantity: 2),
          ItemGrant('travelers_clothes'),
        ],
        goldPieces: 16,
      ),
      const StartingEquipmentOption(
        id: 'wayfarer_b',
        label: '50 GP (buy your own equipment)',
        goldPieces: 50,
      ),
    ],
  ),
];
