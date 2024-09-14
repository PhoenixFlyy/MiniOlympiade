import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:olympiade/utils/match_detail_queries.dart';
import 'package:provider/provider.dart';

import '../infos/achievements/achievement_provider.dart';

final DatabaseReference _databaseMatches = FirebaseDatabase.instance.ref('/results/rounds');

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
      context.read<AchievementProvider>().completeAchievementByTitle('First Blood!');
    }
  }
}

void checkFirstRoundWLoss(BuildContext context, int teamNumber) async {
  final snapshot = await _databaseMatches
      .child("0")
      .child("matches")
      .child(getDisciplineNumber(0, teamNumber).toString())
      .child(getTeamStringNameInDb(0, teamNumber))
      .get();
  if (snapshot.exists) {
    if (snapshot.value.toString() == "0" && context.mounted) {
      context.read<AchievementProvider>().completeAchievementByTitle('Oh no, the perfect score!');
    }
  }
}