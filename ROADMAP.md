# Roadmap D&D Copilot

Stato: ✅ fatto · 🟡 in parte · ⬜ da fare · 📖 serve un estratto del PHB 2024
I numeri tra parentesi sono quelli della lista originale.

## Fase A – Correzioni veloci (nessuna pagina necessaria)

- ⬜ (5) Mostrare la Velocità dei nemici nella schermata Enemies (Slow, Hamstring Blow, Branches of the Tree).
- 🟡 (15) Pulizia tecnica:
  - ✅ import inutilizzato `currency.dart` in `character_sheet_body.dart`
  - ⬜ `RadioListTile` → `RadioGroup` (10 usi deprecati)
  - ⬜ rimuovere `macos/test/` (test fuori posto: i test veri sono in `test/`)
  - ⬜ `devtools_options.yaml` nel `.gitignore`
  - ⬜ decidere sui `*.g.dart` (oggi 16 versionati: consiglio di tenerli, così l'app compila senza `build_runner`)
  - ⬜ aggiornare le dipendenze (riverpod 2→3, drift…): da fare in un passo dedicato, con test
- ✅ (4) Relentless Rage: ora usa il tiro salvezza su Costituzione reale.

## Fase B – Completare ciò che esiste (📖 pagine per classe/capitolo)

- ⬜📖 (2)+(7) **Talenti** – capitolo 5 (Feats): Origin Feats e Epic Boons insieme.
  - Tough (+2 PF/livello nei PF totali), Tavern Brawler sull'Unarmed Strike,
    Lucky (punti fortuna = bonus di competenza), Healer (1d6 + 2×competenza col
    Kit del Guaritore), Savage Attacker (tira due volte il danno, tieni il migliore).
  - Umano/Versatile: applicare davvero il talento scelto.
  - Epic Boon al 19°: 10 talenti dedicati, alcuni portano una caratteristica a 30.
- ⬜📖 (6) **Chierico** – capitolo 3 (Cleric): usi di Channel Divinity per livello,
  trucchetti/preparati per livello, incantesimi di dominio, conferma della tabella slot.
- ⬜📖 (8) **Guerriero** – capitolo 3 (Fighter): Battle Master (dadi di superiorità +
  manovre), Psi Warrior (dadi psionici), Eldritch Knight (ora sbloccabile: il sistema
  incantesimi c'è).
- ⬜📖 (8) **Barbaro Wild Heart** – capitolo 3 (Barbarian): Bear/Eagle/Wolf, Aspect,
  Falcon/Lion meccanici.
- ⬜📖 (3) **Specie** – capitolo 4 (Origins): audit dei tratti delle 10 specie
  (oggi agganciati solo i PF del Nano e il trucchetto dell'Elfo).

## Fase C – Struttura prima di aggiungere 7 classi

- ⬜ (13) CombatScreen a schede (Stats, Skills, Attacks, Spells, Class Features),
  decidere il nome della pagina, indicatore munizioni, tooltip sulle risorse.
- ⬜ (14) Turni/round: durate automatiche (Rage, Concentrazione, Studied Attacks,
  Starry Form, Wild Shape…).
- 🟡 (10) Sistema incantesimi: ✅ dati dal cap. 7, slot, Cast con upcast,
  Concentrazione, effetti su nemici/party, Potent Spellcasting. ⬜ tooltip sui chip,
  ⬜ Divine Intervention (+ versione maggiore), ⬜ War God's Blessing,
  ⬜ Animal/Nature Speaker (rituali), ⬜ tabelle slot di mezzi incantatori e Warlock.

## Fase D – Classi fino al 20° (una alla volta, audit riga per riga)

- ✅ Druido (9)
- Ordine consigliato (riusa al massimo ciò che esiste):
  1. ⬜📖 Paladino – mezzo incantatore, Smite, aure (usa incantesimi + Channel Divinity)
  2. ⬜📖 Ranger – mezzo incantatore, Hunter's Mark
  3. ⬜📖 Mago, Stregone, Bardo – incantatori pieni (motore già pronto)
  4. ⬜📖 Warlock – Pact Magic (slot diversi), Invocazioni
  5. ⬜📖 Ladro, Monaco – nessun incantesimo, meccaniche proprie

## Fase E – Equipaggiamento (📖 capitolo 6, Equipment)

- ⬜ (11) Varianti di strumenti, set da gioco e strumenti musicali nei background
  (Artisan, Entertainer, Guard, Noble, Soldier), poi scelte testuali → `Choice`.
- ⬜ (12) Oggetti offensivi (Holy Water, veleni) sul bersaglio.

## Fase F – Futuro

- ⬜ (16) Crafting e oggetti custom.
- ⬜ (17) Assistente AI (regole, PNG, loot, riassunti, tattica), a basi solide.
- ⬜ (18) Pubblicazione: Linux (Snap/Flathub) e Android (Play Store) prima;
  versione da `pubspec.yaml` (`1.0.0+1`).

## Repository

- ⬜ (19) Rendere la repo di nuovo privata (lo fa l'utente da GitHub → Settings →
  General → Danger Zone → Change visibility). La Claude GitHub App continua a
  funzionare anche su repo private.
