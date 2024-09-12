import 'package:firebase_database/firebase_database.dart';

import 'match_detail_queries.dart';

class DatabaseCalls {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  Future<bool> didTeamWinFirstRound(int teamNumber) async {
    try {
      final DataSnapshot snapshot = await databaseReference
          .child('results')
          .child('rounds')
          .child('0')
          .child('matches')
          .child((getDisciplineNumber(0, teamNumber) - 1).toString())
          .get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        if (isStartingTeam(0, teamNumber)) {
          return data['team1'] == 1;
        } else {
          return data['team2'] == 1;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
