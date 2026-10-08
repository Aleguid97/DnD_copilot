# Roadmap D&D Copilot

Stato: ✅ fatto · 🟡 in parte · ⬜ da fare · 📖 serve un estratto del PHB 2024
I numeri tra parentesi sono quelli della lista originale.

## Fase A – Correzioni veloci (nessuna pagina necessaria)

- ✅ (5) Velocità dei nemici nella schermata Enemies (in rosso se ridotta, reset a 30 ft).
- 🟡 (15) Pulizia tecnica:
  - ✅ import inutilizzato `currency.dart` in `character_sheet_body.dart`
  - ✅ `RadioListTile` → `RadioGroup`
  - ✅ rimosso `macos/test/` (il test dei punteggi è stato spostato in `test/` e ora gira)
  - ✅ `devtools_options.yaml` nel `.gitignore`
  - ✅ codice morto in `combat_stats.dart`
  - ⬜ decidere sui `*.g.dart` (oggi 16 versionati: consiglio di tenerli, così l'app compila senza `build_runner`)
  - ⬜ aggiornare le dipendenze (riverpod 2→3, drift…): da fare in un passo dedicato, con test
- ✅ (4) Relentless Rage: ora usa il tiro salvezza su Costituzione reale.

## Fase B – Completare ciò che esiste (📖 pagine per classe/capitolo)

- 🟡 (2) **Talenti Origine** (fatti dall'altra chat sul testo ufficiale, verificati e uniti):
  - ✅ Tough, Tavern Brawler, Lucky, Healer (Battle Medic + rilancio degli 1),
    Savage Attacker, Alert; valgono sia dal background sia da Versatile (Umano).
  - ⬜📖 Magic Initiate, Skilled, Crafter, Musician: effetti ancora da collegare.
- ⬜📖 (7) **Epic Boon** al 19° – capitolo 5 (Feats): 10 talenti dedicati, alcuni
  portano una caratteristica a 30.
- ✅ (6) **Chierico** – capitolo 3 verificato: ✅ trucchetti/preparati per livello,
  ✅ Channel Divinity 2/3/4 e consumo degli usi per ogni opzione, ✅ incantesimi di dominio
  (Life, Light, Trickery, War), ✅ Power Word Fortify in lista (117), ✅ Divine Intervention
  e Greater Divine Intervention, ✅ War God's Blessing, ✅ Warding Flare/Improved/Corona of
  Light a contatore, ✅ Preserve Life con divisione fra Bloodied, ✅ bonus Thaumaturge,
  ✅ Divine Strike una volta per turno.
  ✅ War Domain verificato (pag. 77); Avatar of Battle, Rage e Full of Stars dimezzano
  i danni B/P/S inseriti nel riquadro PF.
- ⬜📖 (8) **Guerriero** – capitolo 3 (Fighter): Battle Master (dadi di superiorità +
  manovre), Psi Warrior (dadi psionici), Eldritch Knight (ora sbloccabile: il sistema
  incantesimi c'è).
- ⬜📖 (8) **Barbaro Wild Heart** – capitolo 3 (Barbarian): Bear/Eagle/Wolf, Aspect,
  Falcon/Lion meccanici.
- ⬜📖 (3) **Specie** – capitolo 4 (Origins): audit dei tratti delle 10 specie
  (oggi agganciati solo i PF del Nano e il trucchetto dell'Elfo).

## Fase C – Struttura prima di aggiungere 7 classi

- 🟡 (13) ✅ CombatScreen a schede: Overview · Checks · Attacks · Spells (solo
  incantatori) · Class; il bersaglio resta sempre visibile sopra le schede.
  ⬜ nome della pagina (per ora "Combat"), ✅ indicatore munizioni (già presente:
  quantità sotto l'arma, scala a ogni tiro; ⬜📖 recupero a fine combattimento dal cap. 6),
  ✅ risorse con il momento del recupero, ⬜ CharacterSheetBody.
- 🟡 (14) Turni/round: ✅ contatore round (parte da solo col tiro di Iniziativa),
  "Next round" fa scadere Concentrazione (durate dal cap. 7), Rage (chiede se l'hai
  prolungata, max 10 min), Starry Form, Wrath of the Sea; azzera Savage Attacker.
  ⬜ Studied Attacks e altri effetti "fino alla fine del prossimo turno".
- 🟡 (10) Sistema incantesimi: ✅ dati dal cap. 7, slot, Cast con upcast,
  Concentrazione, effetti su nemici/party, Potent Spellcasting, ✅ tooltip su trucchetti
  e preparati (livello, scuola, effetto, durata della Concentrazione),
  ✅ Divine Intervention (+ versione maggiore), ✅ War God's Blessing,
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
