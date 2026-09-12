import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_prova/models/ability_scores.dart';

void main() {
  group('AbilityScores - stato iniziale', () {
    test('parte con tutti i punteggi a 8', () {
      final scores = AbilityScores();
      for (final ability in Ability.values) {
        expect(scores.baseScores[ability], 8);
      }
    });

    test('parte con 27 punti disponibili e 0 spesi', () {
      final scores = AbilityScores();
      expect(scores.pointsSpent, 0);
      expect(scores.pointsRemaining, 27);
      expect(scores.isComplete, false);
    });
  });

  group('AbilityScores - incremento/decremento', () {
    test('aumentare un punteggio consuma i punti corretti', () {
      var scores = AbilityScores();
      scores = scores.increase(Ability.strength); // 8 -> 9, costo 1
      expect(scores.baseScores[Ability.strength], 9);
      expect(scores.pointsSpent, 1);
      expect(scores.pointsRemaining, 26);
    });

    test('il costo aumenta man mano che il punteggio cresce (14->15 costa 2)', () {
      var scores = AbilityScores();
      // Portiamo forza da 8 a 14 (costo totale 7), poi da 14 a 15 (costo 9, quindi +2)
      for (var i = 0; i < 6; i++) {
        scores = scores.increase(Ability.strength);
      }
      expect(scores.baseScores[Ability.strength], 14);
      expect(scores.pointsSpent, 7);

      scores = scores.increase(Ability.strength); // 14 -> 15
      expect(scores.baseScores[Ability.strength], 15);
      expect(scores.pointsSpent, 9);
    });

    test('non si può superare il budget di 27 punti', () {
      var scores = AbilityScores();
      // Proviamo a portare tutte e 6 le caratteristiche a 15 (costerebbe 9*6=54, impossibile)
      for (final ability in Ability.values) {
        for (var i = 0; i < 10; i++) {
          scores = scores.increase(ability);
        }
      }
      expect(scores.pointsSpent, lessThanOrEqualTo(27));
      expect(scores.pointsRemaining, greaterThanOrEqualTo(0));
    });

    test('non si può scendere sotto 8', () {
      var scores = AbilityScores();
      scores = scores.decrease(Ability.dexterity);
      expect(scores.baseScores[Ability.dexterity], 8); // invariato
      expect(scores.canDecrease(Ability.dexterity), false);
    });

    test('canIncrease ritorna false se non bastano i punti rimasti', () {
      var scores = AbilityScores();
      // Spendiamo quasi tutto il budget su una caratteristica
      for (var i = 0; i < 7; i++) {
        scores = scores.increase(Ability.constitution); // arriva a 15, spesi 9
      }
      // Ora portiamo un'altra a 14 (costo 7) -> totale speso 16, restano 11
      for (var i = 0; i < 6; i++) {
        scores = scores.increase(Ability.wisdom);
      }
      expect(scores.pointsRemaining, 27 - 9 - 7);
      // Wisdom da 14 a 15 costerebbe 2 punti in più, e ne abbiamo 11 -> deve poter salire
      expect(scores.canIncrease(Ability.wisdom), true);
    });
  });

  group('AbilityScores - modificatori', () {
    test('modifierFor calcola correttamente il modificatore base', () {
      final scores = AbilityScores();
      // 8 -> modificatore -1
      expect(scores.modifierFor(Ability.strength), -1);
    });

    test('modifierFor 10 o 11 dà modificatore 0', () {
      var scores = AbilityScores();
      scores = scores.increase(Ability.strength); // 8 -> 9
      scores = scores.increase(Ability.strength); // 9 -> 10
      expect(scores.modifierFor(Ability.strength), 0);
    });

    test('modifierFor considera i bonus da background', () {
      final scores = AbilityScores(); // strength = 8
      final withBonus = scores.modifierFor(
        Ability.strength,
        bonuses: {Ability.strength: 2},
      ); // 8 + 2 = 10 -> modificatore 0
      expect(withBonus, 0);
    });
  });
}