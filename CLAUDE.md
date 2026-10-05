# D&D Copilot (`dnd_prova`)

App companion per D&D 5e **2024** (PHB 2024): creazione personaggio, scheda,
inventario, incantesimi, combattimento. Flutter 3.44.8 / Dart 3.12.2,
Riverpod (stato), Drift/SQLite (persistenza). Target: Linux desktop e Android.

## Comandi

```bash
flutter pub get
flutter analyze            # deve restare a 0 errori
flutter test               # include il test di regressione della Combat screen
flutter build linux --debug
dart run build_runner build  # dopo modifiche a tabelle Drift o provider @riverpod
```

Nelle sessioni cloud di Claude Code l'ambiente (Flutter, toolchain Linux,
workaround SQLite) viene installato da `.claude/hooks/session-start.sh`.
Il web non è supportato (SQLite nativo via `dart:ffi`).

## Struttura

- `lib/data/` – dati statici (classi, razze, background, oggetti, risorse) + `database.dart` (Drift).
- `lib/models/` – modelli e logica di regole (`combat_stats.dart`, `*_features.dart`).
- `lib/state/` – provider Riverpod.
- `lib/ui/screens/`, `lib/ui/widgets/` – UI.

### Combat screen

`lib/ui/screens/combat_screen.dart` contiene solo stato, `build()` e il
calcolo dei dati condivisi (`_CombatData`). Ogni sezione vive in un file
`part` sotto `lib/ui/screens/combat/` come extension su `_CombatScreenState`
che restituisce `List<Widget>`:

| File | Contenuto |
|---|---|
| `combat_core_sections.dart` | AC/Iniziativa/Velocità, HP, dadi, tiri salvezza e prove di abilità (richiudibili), bersaglio |
| `combat_helpers.dart` | Helper condivisi: risorse, slot, card, danno al bersaglio, cura |
| `spellcasting_section.dart` | Incantatori: slot, Concentrazione, trucchetti, preparati, Cast (scala lo slot, upcast) |
| `fighter_section.dart` | Guerriero (Tactical Mind) |
| `barbarian_section.dart` | Barbaro e sottoclassi |
| `weapons_section.dart` | Armi equipaggiate, Weapon Mastery, Unarmed Strike |
| `cleric_section.dart` | Chierico e domini |
| `druid_section.dart` | Druido: slot incantesimo, Wild Shape, Elemental Fury, cerchi |
| `class_resources_section.dart` | Tracker generico risorse di classe |

Regole:
- Nuova classe → nuovo file `combat/<classe>_section.dart` + `part` + chiamata in `build()`.
- Nelle extension usare `_update(...)` al posto di `setState(...)` (protected).
- Un errore di parentesi resta confinato al metodo della sua sezione.
- `test/combat_screen_sections_test.dart` apre la Combat screen per ogni
  classe/sottoclasse (liv. 1 e 20) e verifica che tutte le sezioni compaiano
  senza errori di layout. Aggiornare `_expectedSections` quando si aggiunge
  una sezione di classe.
- Test di interazione per classe (es. `test/druid_combat_test.dart`) premono i
  pulsanti e verificano risorse/PF; setup comune in `test/helpers/combat_harness.dart`.
- Slot incantesimo: `lib/data/spell_slots_data.dart` (tabella full caster) espone
  risorse `spell_slot_N`; il Druido le usa, gli altri incantatori potranno riusarle.
- Incantesimi: catalogo in `lib/data/spells_data.dart` (livello, scuola, C/R/M dalle
  liste del cap. 3 PHB). Per abilitare una classe: aggiungere la sua lista a
  `classSpellLists` e le sue regole (trucchetti, preparati, CD) in `_casterRules`.
  Gli effetti (danni/cure) richiedono il cap. 7 del PHB: non ancora modellati.

## Convenzioni di lavoro

- Dati sempre verificati contro il PHB 2024 ufficiale, mai a memoria. L'utente
  fornisce estratti PDF dei capitoli: non vanno mai committati (`*.pdf` è in `.gitignore`).
- Una classe alla volta, portata **completamente** fino al livello 20 prima della successiva.
- Feature implementate **meccanicamente** (bottoni funzionanti) ovunque fattibile;
  testuali solo se dipendono da sistemi non ancora costruiti o sono puramente narrative.
- Testing iterativo: i bug trovati in test si sistemano nella stessa sessione.
- Commit piccoli e descrittivi; prima del push: `flutter analyze` + `flutter test`.

## Stato classi

- **Guerriero**: 1–20, tutte le sottoclassi (meccaniche solo Champion/Battle Master;
  Eldritch Knight/Psi Warrior parzialmente testuali), 6 Fighting Style, Weapon Mastery, Studied Attacks.
- **Chierico**: 1–20, Life/Light/Trickery/War con meccaniche in Combat.
- **Barbaro**: 1–20, Berserker/Wild Heart/World Tree/Zealot con meccaniche in Combat.
- **Druido**: 1–20, Land/Moon/Sea/Stars con meccaniche in Combat; slot incantesimo
  tracciati; Wild Shape a contatore (forme solo come nomi: le statistiche delle
  bestie richiedono l'Appendice B del PHB). Scelta incantesimi oltre il livello 1
  in attesa del sistema Incantesimi.
- **Bardo, Monaco, Paladino, Ranger, Ladro, Stregone, Warlock, Mago**: solo livello 1.

Altro: 16 background con equipaggiamento, ~160 oggetti, combattimento con nemici,
bersaglio, colpito/mancato vs CA, critici, 8 proprietà Weapon Mastery, party per curare alleati.

## Backlog (priorità)

1. ~~Refactor `combat_screen.dart`~~ (fatto: sezioni in `combat/`).
2. Estendere le 8 classi rimanenti al livello 20 (fatto: Druido).
3. Specializzare strumenti/set generici nei background (Artisan, Entertainer, Guard, Noble, Soldier).
4. Sistema Incantesimi: fatti slot, preparati, lancio e Concentrazione (Druido). Mancano
   effetti dei singoli incantesimi (cap. 7 PHB) e le liste delle altre classi.
5. Epic Boon Feats al 19° (categoria a sé, alcuni alzano fino a 30).
6. Convertire le ultime scelte testuali in vere `Choice`.
7. Crafting/oggetti custom.
8. Passaggio di stile grafico.
9. Tracciamento turni/round (durate automatiche, es. Rage).
10. Pubblicazione: Linux (Snap/Flathub), Android (Google Play).
