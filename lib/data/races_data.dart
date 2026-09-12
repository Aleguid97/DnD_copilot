import '../models/race.dart';
import '../models/choice.dart';

final List<Race> allRaces = [
  Race(
    id: 'human',
    name: 'Human',
    speed: 30,
    description:
        'Versatile and ambitious, humans are found throughout the multiverse.',
    fixedTraits: const [
      'Resourceful: you gain Heroic Inspiration whenever you finish a Long Rest',
    ],
    choices: [
      Choice(
        id: 'human_skillful',
        title: 'Skillful: choose 1 skill proficiency',
        options: const [
          ChoiceOption(id: 'acrobatics', label: 'Acrobatics'),
          ChoiceOption(id: 'animal_handling', label: 'Animal Handling'),
          ChoiceOption(id: 'arcana', label: 'Arcana'),
          ChoiceOption(id: 'athletics', label: 'Athletics'),
          ChoiceOption(id: 'deception', label: 'Deception'),
          ChoiceOption(id: 'history', label: 'History'),
          ChoiceOption(id: 'insight', label: 'Insight'),
          ChoiceOption(id: 'intimidation', label: 'Intimidation'),
          ChoiceOption(id: 'investigation', label: 'Investigation'),
          ChoiceOption(id: 'medicine', label: 'Medicine'),
          ChoiceOption(id: 'nature', label: 'Nature'),
          ChoiceOption(id: 'perception', label: 'Perception'),
          ChoiceOption(id: 'performance', label: 'Performance'),
          ChoiceOption(id: 'persuasion', label: 'Persuasion'),
          ChoiceOption(id: 'religion', label: 'Religion'),
          ChoiceOption(id: 'sleight_of_hand', label: 'Sleight of Hand'),
          ChoiceOption(id: 'stealth', label: 'Stealth'),
          ChoiceOption(id: 'survival', label: 'Survival'),
        ],
      ),
      Choice(
        id: 'human_versatile',
        title: 'Versatile: choose 1 additional Origin feat',
        options: const [
          ChoiceOption(id: 'alert', label: 'Alert'),
          ChoiceOption(id: 'crafter', label: 'Crafter'),
          ChoiceOption(id: 'healer', label: 'Healer'),
          ChoiceOption(id: 'lucky', label: 'Lucky'),
          ChoiceOption(
            id: 'magic_initiate_cleric',
            label: 'Magic Initiate (Cleric)',
          ),
          ChoiceOption(
            id: 'magic_initiate_druid',
            label: 'Magic Initiate (Druid)',
          ),
          ChoiceOption(
            id: 'magic_initiate_wizard',
            label: 'Magic Initiate (Wizard)',
          ),
          ChoiceOption(id: 'musician', label: 'Musician'),
          ChoiceOption(id: 'savage_attacker', label: 'Savage Attacker'),
          ChoiceOption(id: 'skilled', label: 'Skilled'),
          ChoiceOption(id: 'tavern_brawler', label: 'Tavern Brawler'),
          ChoiceOption(id: 'tough', label: 'Tough'),
        ],
      ),
    ],
  ),
  const Race(
    id: 'elf',
    name: 'Elf',
    speed: 30,
    description:
        'Agile and attuned to magic, elves do not sleep; they meditate in a Trance instead.',
    fixedTraits: [
      'Darkvision 60 feet',
      'Fey Ancestry: Advantage on saving throws you make to avoid or end the Charmed condition',
      'Trance: you don\'t need to sleep, and magic can\'t put you to sleep (4 hours of meditation instead of 8 hours of sleep)',
    ],
    choices: [
      Choice(
        id: 'elf_keen_senses',
        title: 'Keen Senses: choose 1 skill proficiency',
        options: const [
          ChoiceOption(id: 'perception', label: 'Perception'),
          ChoiceOption(id: 'insight', label: 'Insight'),
          ChoiceOption(id: 'survival', label: 'Survival'),
        ],
      ),
      Choice(
        id: 'elf_lineage',
        title: 'Choose your Elven Lineage',
        options: [
          ChoiceOption(
            id: 'high_elf',
            label: 'High Elf',
            description:
                'You know Prestidigitation (replaceable with a Wizard cantrip after a Long Rest); additional spells at levels 3 and 5.',
            unlockedChoices: [
              Choice(
                id: 'elf_spellcasting_ability_high',
                title: 'Choose your spellcasting ability',
                options: [
                  ChoiceOption(id: 'intelligence', label: 'Intelligence'),
                  ChoiceOption(id: 'wisdom', label: 'Wisdom'),
                  ChoiceOption(id: 'charisma', label: 'Charisma'),
                ],
              ),
            ],
          ),
          ChoiceOption(
            id: 'wood_elf',
            label: 'Wood Elf',
            description:
                'Speed 35 feet; you know Druidcraft (replaceable with a Druid cantrip after a Long Rest); additional spells at levels 3 and 5.',
            unlockedChoices: [
              Choice(
                id: 'elf_spellcasting_ability_wood',
                title: 'Choose your spellcasting ability',
                options: [
                  ChoiceOption(id: 'intelligence', label: 'Intelligence'),
                  ChoiceOption(id: 'wisdom', label: 'Wisdom'),
                  ChoiceOption(id: 'charisma', label: 'Charisma'),
                ],
              ),
            ],
          ),
          ChoiceOption(
            id: 'drow',
            label: 'Drow',
            description:
                'Superior Darkvision, 120 feet; you know Dancing Lights; additional spells (Faerie Fire, Darkness) at levels 3 and 5. No sunlight sensitivity.',
            unlockedChoices: [
              Choice(
                id: 'elf_spellcasting_ability_drow',
                title: 'Choose your spellcasting ability',
                options: [
                  ChoiceOption(id: 'intelligence', label: 'Intelligence'),
                  ChoiceOption(id: 'wisdom', label: 'Wisdom'),
                  ChoiceOption(id: 'charisma', label: 'Charisma'),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  const Race(
    id: 'dwarf',
    name: 'Dwarf',
    speed: 30,
    description:
        'Sturdy and resilient, dwarves are masters of stone and the deep earth.',
    fixedTraits: [
      'Darkvision 120 feet (the highest among base species)',
      'Dwarven Resilience: resistance to Poison damage, Advantage on saving throws against Poisoned',
      'Stonecunning: Bonus Action to gain Tremorsense 60 feet for 10 minutes (while in contact with stone); uses equal to Proficiency Bonus',
    ],
    hpBonusPerLevel: 1,
  ),
  const Race(
    id: 'halfling',
    name: 'Halfling',
    speed: 30,
    description: 'Small, curious, and surprisingly lucky.',
    fixedTraits: [
      'Brave: Advantage on saving throws you make to avoid or end the Frightened condition',
      'Halfling Nimbleness: you can move through the space of any creature that is Large or bigger',
      'Luck: when you roll a 1 on a d20 Test, you can reroll it (you must use the new roll)',
      'Naturally Stealthy: you can Hide even when obscured only by a creature at least one size larger than you',
    ],
  ),
  const Race(
    id: 'gnome',
    name: 'Gnome',
    speed: 30,
    description:
        'Curious and inventive, gnomes have minds that are hard to manipulate.',
    fixedTraits: [
      'Darkvision 60 feet',
      'Gnomish Cunning: Advantage on Intelligence, Wisdom, and Charisma saving throws',
    ],
    choices: [
      Choice(
        id: 'gnome_lineage',
        title: 'Choose your Gnomish Lineage',
        options: [
          ChoiceOption(
            id: 'forest_gnome',
            label: 'Forest Gnome',
            description:
                'You know Minor Illusion; you always have Speak with Animals prepared, castable without a spell slot a number of times equal to your Proficiency Bonus.',
            unlockedChoices: [
              Choice(
                id: 'gnome_spellcasting_ability_forest',
                title: 'Choose your spellcasting ability',
                options: [
                  ChoiceOption(id: 'intelligence', label: 'Intelligence'),
                  ChoiceOption(id: 'wisdom', label: 'Wisdom'),
                  ChoiceOption(id: 'charisma', label: 'Charisma'),
                ],
              ),
            ],
          ),
          ChoiceOption(
            id: 'rock_gnome',
            label: 'Rock Gnome',
            description:
                'You know Mending and Prestidigitation; you can use Prestidigitation to create small clockwork devices.',
            unlockedChoices: [
              Choice(
                id: 'gnome_spellcasting_ability_rock',
                title: 'Choose your spellcasting ability',
                options: [
                  ChoiceOption(id: 'intelligence', label: 'Intelligence'),
                  ChoiceOption(id: 'wisdom', label: 'Wisdom'),
                  ChoiceOption(id: 'charisma', label: 'Charisma'),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  const Race(
    id: 'tiefling',
    name: 'Tiefling',
    speed: 30,
    description:
        'Tieflings carry an infernal or abyssal heritage in their blood.',
    fixedTraits: [
      'Darkvision 60 feet',
      'Otherworldly Presence: you know the Thaumaturgy cantrip (uses the same spellcasting ability as your Fiendish Legacy)',
    ],
    choices: [
      Choice(
        id: 'tiefling_legacy',
        title: 'Choose your Fiendish Legacy',
        options: [
          ChoiceOption(
            id: 'abyssal',
            label: 'Abyssal Legacy',
            description:
                'Resistance to Poison damage; you know Poison Spray; additional spells (Ray of Sickness, Hold Person) at levels 3 and 5.',
            unlockedChoices: [
              Choice(
                id: 'tiefling_spellcasting_ability_abyssal',
                title: 'Choose your spellcasting ability',
                options: [
                  ChoiceOption(id: 'intelligence', label: 'Intelligence'),
                  ChoiceOption(id: 'wisdom', label: 'Wisdom'),
                  ChoiceOption(id: 'charisma', label: 'Charisma'),
                ],
              ),
            ],
          ),
          ChoiceOption(
            id: 'chthonic',
            label: 'Chthonic Legacy',
            description:
                'Resistance to Necrotic damage; you know Chill Touch; additional spells (False Life, Ray of Sickness) at levels 3 and 5.',
            unlockedChoices: [
              Choice(
                id: 'tiefling_spellcasting_ability_chthonic',
                title: 'Choose your spellcasting ability',
                options: [
                  ChoiceOption(id: 'intelligence', label: 'Intelligence'),
                  ChoiceOption(id: 'wisdom', label: 'Wisdom'),
                  ChoiceOption(id: 'charisma', label: 'Charisma'),
                ],
              ),
            ],
          ),
          ChoiceOption(
            id: 'infernal',
            label: 'Infernal Legacy',
            description:
                'Resistance to Fire damage; you know Fire Bolt; additional spells (Hellish Rebuke, Darkness) at levels 3 and 5.',
            unlockedChoices: [
              Choice(
                id: 'tiefling_spellcasting_ability_infernal',
                title: 'Choose your spellcasting ability',
                options: [
                  ChoiceOption(id: 'intelligence', label: 'Intelligence'),
                  ChoiceOption(id: 'wisdom', label: 'Wisdom'),
                  ChoiceOption(id: 'charisma', label: 'Charisma'),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  const Race(
    id: 'dragonborn',
    name: 'Dragonborn',
    speed: 30,
    description:
        'Humanoid descendants of dragons, with an elemental Breath Weapon and resilient scales.',
    fixedTraits: [
      'Darkvision 60 feet',
      'Breath Weapon: replaces one attack; 15-foot cone or 30-foot line; Dexterity saving throw; 1d10 damage (scales with level); uses equal to Proficiency Bonus',
      'Draconic Flight (from level 5): Bonus Action to sprout spectral wings, gaining a Fly Speed equal to your Speed for 10 minutes',
    ],
    choices: [
      Choice(
        id: 'draconic_ancestry',
        title: 'Choose your Draconic Ancestry',
        options: [
          ChoiceOption(
            id: 'red',
            label: 'Red',
            description: 'Damage type and resistance: Fire.',
          ),
          ChoiceOption(
            id: 'blue',
            label: 'Blue',
            description: 'Damage type and resistance: Lightning.',
          ),
          ChoiceOption(
            id: 'white',
            label: 'White',
            description: 'Damage type and resistance: Cold.',
          ),
          ChoiceOption(
            id: 'black',
            label: 'Black',
            description: 'Damage type and resistance: Acid.',
          ),
          ChoiceOption(
            id: 'green',
            label: 'Green',
            description: 'Damage type and resistance: Poison.',
          ),
        ],
      ),
    ],
  ),
  const Race(
    id: 'goliath',
    name: 'Goliath',
    speed: 35,
    description: 'Distant descendants of giants, tall and powerfully built.',
    fixedTraits: [
      'Powerful Build: Advantage on checks you make to escape the Grappled condition',
      'Large Form (from level 5): Bonus Action to become Large for 10 minutes, +10 feet Speed, Advantage on Strength checks',
    ],
    choices: [
      Choice(
        id: 'giant_ancestry',
        title: 'Choose your Giant Ancestry',
        options: [
          ChoiceOption(
            id: 'cloud_giant',
            label: 'Cloud Giant',
            description: 'Cloud\'s Jaunt: Bonus Action, teleport 30 feet.',
          ),
          ChoiceOption(
            id: 'fire_giant',
            label: 'Fire Giant',
            description: 'Fire\'s Burn: extra 1d10 Fire damage when you hit.',
          ),
          ChoiceOption(
            id: 'frost_giant',
            label: 'Frost Giant',
            description:
                'Frost\'s Chill: extra 1d6 Cold damage and reduces the target\'s Speed.',
          ),
          ChoiceOption(
            id: 'hill_giant',
            label: 'Hill Giant',
            description:
                'Hill\'s Tumble: you can knock a Large or smaller target Prone when you hit it.',
          ),
          ChoiceOption(
            id: 'stone_giant',
            label: 'Stone Giant',
            description: 'Stone\'s Endurance: Reaction to reduce damage taken.',
          ),
          ChoiceOption(
            id: 'storm_giant',
            label: 'Storm Giant',
            description:
                'Storm\'s Thunder: Reaction, 1d8 Thunder damage to a creature that hits you in melee.',
          ),
        ],
      ),
    ],
  ),
  const Race(
    id: 'orc',
    name: 'Orc',
    speed: 30,
    description: 'Tireless and resilient, orcs excel in the frenzy of battle.',
    fixedTraits: [
      'Adrenaline Rush: Bonus Action to Dash, gaining Temporary Hit Points equal to your Proficiency Bonus; uses equal to Proficiency Bonus, regained on a Short or Long Rest',
      'Darkvision 120 feet',
      'Relentless Endurance: if reduced to 0 Hit Points but not killed outright, you can drop to 1 Hit Point instead (once per Long Rest)',
    ],
  ),
  const Race(
    id: 'aasimar',
    name: 'Aasimar',
    speed: 30,
    description: 'Mortals who carry a spark of celestial energy within them.',
    fixedTraits: [
      'Darkvision 60 feet',
      'Celestial Resistance: resistance to Necrotic and Radiant damage',
      'Healing Hands: Magic Action, touch a creature and roll a d4 per Proficiency Bonus to restore that many Hit Points (once per Long Rest)',
      'Light Bearer: you know the Light cantrip (Charisma)',
      'Celestial Revelation (from level 3): Bonus Action, 1-minute transformation; choose each time between Radiant Wings, Necrotic Shroud, or Inner Light — a runtime choice, not made at character creation',
    ],
  ),
];
