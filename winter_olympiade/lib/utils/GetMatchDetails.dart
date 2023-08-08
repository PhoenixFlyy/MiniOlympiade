import 'MatchDetails.dart';

bool isStartingTeam(int round, int teamNumber) {
  if (round >= 0 && round < pairings.length) {
    String pairing = pairings[round][teamNumber - 1];
    if (pairing.isNotEmpty) {
      List<String> teams = pairing.split('-');
      if (teams.length == 2) {
        int team1 = int.tryParse(teams[0]) ?? 0;
        return team1 == teamNumber;
      }
    }
  }
  return false;
}

String getDisciplineName(int round, int teamNumber) {
  if (round > 0 && round < pairings.length) {
    var pairing = pairings[round - 1];
    for (int index = 0; index < pairing.length; index++) {
      var match = pairing[index];
      if (match.contains(teamNumber.toString())) {
        return disciplines[(index + 1).toString()] ?? "Unknown Discipline";
      }
    }
  }
  return "Failed";
}

int getDisciplineNumber(int round, int teamNumber) {
  if (round > 0 && round < pairings.length) {
    var pairing = pairings[round - 1];
    for (int index = 0; index < pairing.length; index++) {
      var match = pairing[index];
      if (match.contains(teamNumber.toString())) {
        return index + 1;
      }
    }
  }
  return 0;
}
