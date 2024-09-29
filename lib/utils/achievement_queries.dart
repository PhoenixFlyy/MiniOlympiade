import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:olympiade/utils/match_detail_queries.dart';
import 'package:provider/provider.dart';

import '../infos/achievements/achievement_provider.dart';
import 'match_data.dart';

final DatabaseReference _databaseMatches =
    FirebaseDatabase.instance.ref('/results/rounds');

String getTeamStringNameInDb(int round, int teamNumber) =>
    isStartingTeam(round, teamNumber) ? "team1" : "team2";

void checkFirstRoundWin(BuildContext context, int teamNumber) async {
  final snapshot = await _databaseMatches
      .child("0")
      .child("matches")
      .child(getDisciplineNumber(0, teamNumber).toString())
      .child(getTeamStringNameInDb(0, teamNumber))
      .get();
  if (snapshot.exists) {
    if (snapshot.value.toString() == "1" && context.mounted) {
      context
          .read<AchievementProvider>()
          .completeAchievementByTitle('First Blood!');
    }
  }
}

//This should be checked every round
void checkFirstRoundWLoss(
    BuildContext context, int teamNumber, int roundNumber) async {
  final snapshot = await _databaseMatches
      .child(roundNumber.toString())
      .child("matches")
      .child(getDisciplineNumber(0, teamNumber).toString())
      .child(getTeamStringNameInDb(0, teamNumber))
      .get();
  if (snapshot.exists) {
    if (snapshot.value.toString() == "0" && context.mounted) {
      context
          .read<AchievementProvider>()
          .completeAchievementByTitle('Oh no, the perfect score!');
    }
  }
}

//This should be checked every round
void checkFirstWin(
    BuildContext context, int teamNumber, int roundNumber) async {
  final snapshot = await _databaseMatches
      .child(roundNumber.toString())
      .child("matches")
      .child(getDisciplineNumber(0, teamNumber).toString())
      .child(getTeamStringNameInDb(0, teamNumber))
      .get();
  if (snapshot.exists) {
    if (snapshot.value.toString() == "1" && context.mounted) {
      context
          .read<AchievementProvider>()
          .completeAchievementByTitle('Ein erster Schritt zum Sieg');
    }
  }
}

//Gewinne drei Disziplinen hintereinander
void checkThreeConsecutiveWins(BuildContext context, int teamNumber) async {
  int consecutiveWins = 0;

  // Durchlaufen aller Runden
  for (int round = 0; round < pairings.length; round++) {
    final snapshot = await _databaseMatches
        .child(round.toString())
        .child("matches")
        .child(getDisciplineNumber(round, teamNumber).toString())
        .child(getTeamStringNameInDb(round, teamNumber))
        .get();

    if (snapshot.exists) {
      // Überprüfen, ob das Team in dieser Runde gewonnen hat
      if (snapshot.value.toString() == "1") {
        consecutiveWins++; // Wenn gewonnen, die Anzahl der aufeinanderfolgenden Siege erhöhen

        // Wenn drei Siege hintereinander erreicht wurden, Achievement freischalten
        if (consecutiveWins == 3 && context.mounted) {
          context
              .read<AchievementProvider>()
              .completeAchievementByTitle('Win Streak!');
          break; // Achievement wurde freigeschaltet, weitere Überprüfungen nicht nötig
        }
      } else {
        consecutiveWins = 0; // Wenn das Team verliert, den Zähler zurücksetzen
      }
    }
  }
}

//Gewinne fünf Disziplinen hintereinander
void checkFiveConsecutiveWins(BuildContext context, int teamNumber) async {
  int consecutiveWins = 0;

  // Durchlaufen aller Runden
  for (int round = 0; round < pairings.length; round++) {
    final snapshot = await _databaseMatches
        .child(round.toString())
        .child("matches")
        .child(getDisciplineNumber(round, teamNumber).toString())
        .child(getTeamStringNameInDb(round, teamNumber))
        .get();

    if (snapshot.exists) {
      // Überprüfen, ob das Team in dieser Runde gewonnen hat
      if (snapshot.value.toString() == "1") {
        consecutiveWins++; // Wenn gewonnen, die Anzahl der aufeinanderfolgenden Siege erhöhen

        // Wenn drei Siege hintereinander erreicht wurden, Achievement freischalten
        if (consecutiveWins == 5 && context.mounted) {
          context
              .read<AchievementProvider>()
              .completeAchievementByTitle('Ungespielt Moment');
          break; // Achievement wurde freigeschaltet, weitere Überprüfungen nicht nötig
        }
      } else {
        consecutiveWins = 0; // Wenn das Team verliert, den Zähler zurücksetzen
      }
    }
  }
}

//Gewinne in jeder Disziplin mindestens einmal
void checkWinInEveryDiscipline(BuildContext context, int teamNumber) async {
  Set<int> wonDisciplines = {};

  // Durchlaufen aller Runden
  for (int round = 0; round < pairings.length; round++) {
    final disciplineNumber = getDisciplineNumber(round, teamNumber);
    final snapshot = await _databaseMatches
        .child(round.toString())
        .child("matches")
        .child(disciplineNumber.toString())
        .child(getTeamStringNameInDb(round, teamNumber))
        .get();

    if (snapshot.exists) {
      // Wenn das Team in dieser Disziplin gewonnen hat
      if (snapshot.value.toString() == "1") {
        wonDisciplines
            .add(disciplineNumber); // Disziplin als gewonnen markieren
      }
    }
  }

  // Prüfen, ob das Team in jeder Disziplin mindestens einmal gewonnen hat
  if (wonDisciplines.length == disciplines.length && context.mounted) {
    context
        .read<AchievementProvider>()
        .completeAchievementByTitle('Gotta Catch \'Em All');
  }
}

//Verliere in jeder Disziplin mindestens einmal
void checkLoseInEveryDiscipline(BuildContext context, int teamNumber) async {
  Set<int> loseDisciplines = {};

  // Durchlaufen aller Runden
  for (int round = 0; round < pairings.length; round++) {
    final disciplineNumber = getDisciplineNumber(round, teamNumber);
    final snapshot = await _databaseMatches
        .child(round.toString())
        .child("matches")
        .child(disciplineNumber.toString())
        .child(getTeamStringNameInDb(round, teamNumber))
        .get();

    if (snapshot.exists) {
      // Wenn das Team in dieser Disziplin verloren hat
    }
    if (snapshot.value.toString() == "0" ||
        snapshot.value.toString() == "0.5") {
      loseDisciplines.add(disciplineNumber); // Disziplin als verloren markieren
    }
  }

  // Prüfen, ob das Team in jeder Disziplin mindestens einmal verloren hat
  if (loseDisciplines.length == disciplines.length && context.mounted) {
    context
        .read<AchievementProvider>()
        .completeAchievementByTitle('Mein Teampartner ist schuld!');
  }
}

//Gewinne nachdem du mind. 3 mal verloren hast
void checkWinAfterThreeOrMoreLosses(
    BuildContext context, int teamNumber) async {
  int consecutiveLosses = 0;
  bool hasWonAfterLosses = false;

  // Durchlaufen aller Runden
  for (int round = 0; round < pairings.length; round++) {
    final snapshot = await _databaseMatches
        .child(round.toString())
        .child("matches")
        .child(getDisciplineNumber(round, teamNumber).toString())
        .child(getTeamStringNameInDb(round, teamNumber))
        .get();

    if (snapshot.exists) {
      if (snapshot.value.toString() == "0") {
        // Wenn das Team in dieser Runde verloren hat
        consecutiveLosses++; // Zähle die Niederlage
      } else if (snapshot.value.toString() == "1" && consecutiveLosses >= 3) {
        // Wenn das Team nach mindestens 3 Niederlagen gewinnt
        hasWonAfterLosses = true;
        break; // Abbrechen, da die Bedingung erfüllt ist
      } else {
        consecutiveLosses =
            0; // Zurücksetzen, wenn das Team vor Erreichen der 3 Niederlagen gewinnt
      }
    }
  }

  // Achievement freischalten, wenn das Team nach mindestens 3 Niederlagen gewonnen hat
  if (hasWonAfterLosses && context.mounted) {
    context.read<AchievementProvider>().completeAchievementByTitle('Comeback?');
  }
}

//Dieses Achievement könnte man erst ab der 20. Runde (oder so) abfragen, da es vorher nicht erreicht werden kann.
//außerdem glaube ich, dass jede Diszipli einzeln durchgegangen wird. Es würde aber reichen, immer nur die Diszplin der aktuellen Runde abzufragen. Dann müsste man es aber wohl auch in der aktuellen Runde abfragen, was keine Verzögerung beim Eintragen erlauben würde.
//Gewinne in einer Disziplin gegen alle anderen
void checkWinAgainstAllInAnyDiscipline(
    BuildContext context, int teamNumber) async {
  int totalTeams = pairings.length; // Anzahl der Teams

  // Durchlaufen aller Disziplinen
  for (int disciplineNumber = 1;
      disciplineNumber <= disciplines.length;
      disciplineNumber++) {
    Set<int> defeatedTeams = {};

    // Durchlaufen aller Runden für jede Disziplin
    for (int round = 0; round < pairings.length; round++) {
      final currentDiscipline = getDisciplineNumber(round, teamNumber);

      // Überspringen, wenn die Disziplin nicht übereinstimmt
      if (currentDiscipline != disciplineNumber) {
        continue;
      }

      // Prüfen, ob das Team in dieser Runde gewonnen hat
      final snapshot = await _databaseMatches
          .child(round.toString())
          .child("matches")
          .child(currentDiscipline.toString())
          .child(getTeamStringNameInDb(round, teamNumber))
          .get();

      if (snapshot.exists) {
        // Nur fortfahren, wenn das Ergebnis ein Sieg ist (nicht Unentschieden)
        if (snapshot.value.toString() == "1") {
          // Gegner zur Liste der besiegten Teams hinzufügen
          int opponent = getOpponentTeamNumberByRound(round, teamNumber);
          if (opponent != -1) {
            defeatedTeams.add(opponent);
          }
        }
      }
    }

    // Überprüfen, ob das Team gegen alle anderen Teams in dieser Disziplin gewonnen hat
    if (defeatedTeams.length == totalTeams - 1) {
      // Achievement nur einmal freischalten
      if (context.mounted) {
        context
            .read<AchievementProvider>()
            .completeAchievementByTitle('Nicht aufzuhalten!');
      }
      break; // Abbrechen, sobald das Achievement freigeschaltet wurde
    }
  }
}

//der folgende Code sollte eigentlich nur der von obendrüber sein, aber umgekehrt. Keine Ahnung, welcher bessern ist.
//Verliere in einer Disziplin gegen alle anderen
void checkLossAgainstAllInAnyDiscipline(
    BuildContext context, int teamNumber) async {
  int totalTeams = pairings.length; // Anzahl der Teams

  // Durchlaufen aller Disziplinen
  for (int disciplineNumber = 1;
      disciplineNumber <= disciplines.length;
      disciplineNumber++) {
    Set<int> defeatingTeams = {};

    // Durchlaufen aller Runden für jede Disziplin
    for (int round = 0; round < pairings.length; round++) {
      final currentDiscipline = getDisciplineNumber(round, teamNumber);

      // Überspringen, wenn die Disziplin nicht übereinstimmt
      if (currentDiscipline != disciplineNumber) {
        continue;
      }

      // Prüfen, ob das Team in dieser Runde verloren hat oder unentschieden gespielt hat
      final snapshot = await _databaseMatches
          .child(round.toString())
          .child("matches")
          .child(currentDiscipline.toString())
          .child(getTeamStringNameInDb(round, teamNumber))
          .get();

      if (snapshot.exists) {
        // Fortfahren, wenn das Ergebnis eine Niederlage oder ein Unentschieden ist
        if (snapshot.value.toString() == "0" ||
            snapshot.value.toString() == "0.5") {
          // Gewinner-Team zur Liste der siegreichen Teams hinzufügen
          int opponent = getOpponentTeamNumberByRound(round, teamNumber);
          if (opponent != -1) {
            defeatingTeams.add(opponent);
          }
        }
      }
    }

    // Überprüfen, ob das Team gegen alle anderen Teams in dieser Disziplin verloren hat
    if (defeatingTeams.length == totalTeams - 1) {
      // Achievement nur einmal freischalten
      if (context.mounted) {
        context
            .read<AchievementProvider>()
            .completeAchievementByTitle('Kanonenfutter');
      }
      break; // Abbrechen, sobald das Achievement freigeschaltet wurde
    }
  }
}

//Gewinne in Kicker
void checkWinInKicker(BuildContext context, int teamNumber) async {
  // Durchlaufen aller Runden
  for (int round = 0; round < pairings.length; round++) {
    final disciplineNumber = getDisciplineNumber(round, teamNumber);

    // Prüfen, ob die aktuelle Disziplin "Kicker" (Nummer 1) ist
    if (disciplineNumber == 1) {
      // Prüfen, ob das Team in dieser Runde gewonnen hat
      final snapshot = await _databaseMatches
          .child(round.toString())
          .child("matches")
          .child(disciplineNumber.toString())
          .child(getTeamStringNameInDb(round, teamNumber))
          .get();

      if (snapshot.exists) {
        // Nur fortfahren, wenn das Ergebnis ein Sieg ist (nicht Unentschieden)
        if (snapshot.value.toString() == "1" && context.mounted) {
          // Achievement für Kicker freischalten
          context
              .read<AchievementProvider>()
              .completeAchievementByTitle('Meeessssiiii!');
          break; // Abbrechen, sobald das Achievement freigeschaltet wurde
        }
      }
    }
  }
}

//Gewinne in Darts
void checkWinInDarts(BuildContext context, int teamNumber) async {
  // Durchlaufen aller Runden
  for (int round = 0; round < pairings.length; round++) {
    final disciplineNumber = getDisciplineNumber(round, teamNumber);

    // Prüfen, ob die aktuelle Disziplin "Darts" (Nummer 2) ist
    if (disciplineNumber == 2) {
      // Prüfen, ob das Team in dieser Runde gewonnen hat
      final snapshot = await _databaseMatches
          .child(round.toString())
          .child("matches")
          .child(disciplineNumber.toString())
          .child(getTeamStringNameInDb(round, teamNumber))
          .get();

      if (snapshot.exists) {
        // Nur fortfahren, wenn das Ergebnis ein Sieg ist (nicht Unentschieden)
        if (snapshot.value.toString() == "1" && context.mounted) {
          // Achievement für Darts freischalten
          context
              .read<AchievementProvider>()
              .completeAchievementByTitle('Ab in den Ally Pally!');
          break; // Abbrechen, sobald das Achievement freigeschaltet wurde
        }
      }
    }
  }
}

//Gewinne in Billard
void checkWinInBillard(BuildContext context, int teamNumber) async {
  // Durchlaufen aller Runden
  for (int round = 0; round < pairings.length; round++) {
    final disciplineNumber = getDisciplineNumber(round, teamNumber);

    // Prüfen, ob die aktuelle Disziplin "Billard" (Nummer 3) ist
    if (disciplineNumber == 3) {
      // Prüfen, ob das Team in dieser Runde gewonnen hat
      final snapshot = await _databaseMatches
          .child(round.toString())
          .child("matches")
          .child(disciplineNumber.toString())
          .child(getTeamStringNameInDb(round, teamNumber))
          .get();

      if (snapshot.exists) {
        // Nur fortfahren, wenn das Ergebnis ein Sieg ist (nicht Unentschieden)
        if (snapshot.value.toString() == "1" && context.mounted) {
          // Achievement für Billard freischalten
          context
              .read<AchievementProvider>()
              .completeAchievementByTitle('Einloch-Experte');
          break; // Abbrechen, sobald das Achievement freigeschaltet wurde
        }
      }
    }
  }
}

//Gewinne in Bierpong
void checkWinInBierpong(BuildContext context, int teamNumber) async {
  // Durchlaufen aller Runden
  for (int round = 0; round < pairings.length; round++) {
    final disciplineNumber = getDisciplineNumber(round, teamNumber);

    // Prüfen, ob die aktuelle Disziplin "Bierpong" (Nummer 4) ist
    if (disciplineNumber == 4) {
      // Prüfen, ob das Team in dieser Runde gewonnen hat
      final snapshot = await _databaseMatches
          .child(round.toString())
          .child("matches")
          .child(disciplineNumber.toString())
          .child(getTeamStringNameInDb(round, teamNumber))
          .get();

      if (snapshot.exists) {
        // Nur fortfahren, wenn das Ergebnis ein Sieg ist (nicht Unentschieden)
        if (snapshot.value.toString() == "1" && context.mounted) {
          // Achievement für Bierpong freischalten
          context.read<AchievementProvider>().completeAchievementByTitle(
              'Noch nüchtern? Die Gegner nicht mehr!');
          break; // Abbrechen, sobald das Achievement freigeschaltet wurde
        }
      }
    }
  }
}

//Gewinne in Kubb
void checkWinInKubb(BuildContext context, int teamNumber) async {
  // Durchlaufen aller Runden
  for (int round = 0; round < pairings.length; round++) {
    final disciplineNumber = getDisciplineNumber(round, teamNumber);

    // Prüfen, ob die aktuelle Disziplin "Kubb" (Nummer 5) ist
    if (disciplineNumber == 5) {
      // Prüfen, ob das Team in dieser Runde gewonnen hat
      final snapshot = await _databaseMatches
          .child(round.toString())
          .child("matches")
          .child(disciplineNumber.toString())
          .child(getTeamStringNameInDb(round, teamNumber))
          .get();

      if (snapshot.exists) {
        // Nur fortfahren, wenn das Ergebnis ein Sieg ist (nicht Unentschieden)
        if (snapshot.value.toString() == "1" && context.mounted) {
          // Achievement für Kubb freischalten
          context
              .read<AchievementProvider>()
              .completeAchievementByTitle('Holzfäller!');
          break; // Abbrechen, sobald das Achievement freigeschaltet wurde
        }
      }
    }
  }
}

//Die Schleife ist eig. unnötig, wenn man sofort einträgt und nicht erst eine Runde später
//Gewinne in Jenga
void checkWinInJenga(BuildContext context, int teamNumber) async {
  // Durchlaufen aller Runden
  for (int round = 0; round < pairings.length; round++) {
    final disciplineNumber = getDisciplineNumber(round, teamNumber);

    // Prüfen, ob die aktuelle Disziplin "Jenga" (Nummer 6) ist
    if (disciplineNumber == 6) {
      // Prüfen, ob das Team in dieser Runde gewonnen hat
      final snapshot = await _databaseMatches
          .child(round.toString())
          .child("matches")
          .child(disciplineNumber.toString())
          .child(getTeamStringNameInDb(round, teamNumber))
          .get();

      if (snapshot.exists) {
        // Nur fortfahren, wenn das Ergebnis ein Sieg ist (nicht Unentschieden)
        if (snapshot.value.toString() == "1" && context.mounted) {
          // Achievement für Jenga freischalten
          context
              .read<AchievementProvider>()
              .completeAchievementByTitle('Ruhige Hände');
          break; // Abbrechen, sobald das Achievement freigeschaltet wurde
        }
      }
    }
  }
}


