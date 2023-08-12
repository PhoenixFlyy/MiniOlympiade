import 'package:firebase_database/firebase_database.dart';

import 'DateTimeUtils.dart';
import 'MatchDetails.dart';

bool isNumberInString(String input, int number) {
  List<String> parts = input.split("-");
  for (String part in parts) {
    if (int.tryParse(part) == number) {
      return true;
    }
  }
  return false;
}

bool isStartingTeam(int round, int teamNumber) {
  if (round > 0 && round <= pairings.length) {
    var pairing = pairings[round - 1];
    for (String match in pairing) {
      if (isNumberInString(match, teamNumber)) {
        var teams = match.split('-');
        return teams[0].contains(teamNumber.toString());
      }
    }
  }
  return false;
}

String getDisciplineName(int round, int teamNumber) {
  if (round > 0 && round <= pairings.length) {
    var pairing = pairings[round - 1];
    for (int index = 0; index < pairing.length; index++) {
      var match = pairing[index];
      if (isNumberInString(match, teamNumber)) {
        return disciplines[(index + 1).toString()] ?? "Unknown Discipline";
      }
    }
  }
  return "Failed";
}

int getDisciplineNumber(int round, int teamNumber) {
  if (round > 0 && round <= pairings.length) {
    var pairing = pairings[round - 1];
    for (int index = 0; index < pairing.length; index++) {
      var match = pairing[index];
      if (isNumberInString(match, teamNumber)) {
        return index + 1;
      }
    }
  }
  return 0;
}

int getOpponentTeamNumberByRound(int round, int teamNumber) {
  if (round > 0 && round <= pairings.length) {
    var pairing = pairings[round - 1];
    for (int index = 0; index < pairing.length; index++) {
      var match = pairing[index];
      if (isNumberInString(match, teamNumber)) {
        var teams = match.split('-');
        if (int.tryParse(teams[0]) == teamNumber) {
          return int.tryParse(teams[1]) ?? -1;
        } else {
          return int.tryParse(teams[0]) ?? -1;
        }
      }
    }
  }
  return -2;
}

List<int> getOpponentListByDisciplines(int disciplineNumber, int teamNumber) {
  List<int> opponentsInDiscipline = [];
  for (int index = 0; index < pairings.length; index++) {
    var match = pairings[index][disciplineNumber - 1];
    if (isNumberInString(match, teamNumber)) {
      var teams = match.split('-');
      if (int.tryParse(teams[0]) == teamNumber) {
        opponentsInDiscipline.add(int.tryParse(teams[1]) ?? -1);
      } else {
        opponentsInDiscipline.add(int.tryParse(teams[0]) ?? -1);
      }
    }
  }
  return opponentsInDiscipline;
}

Future<double> getTeamPointsInRound(int round, int teamNumber) async {
  if (round > 0 && round <= pairings.length && teamNumber > 0) {
    var teamOrderString = isStartingTeam(round, teamNumber) ? "team1" : "team2";
    var databaseRound = (round - 1).toString();
    var disciplineNumber =
        (getDisciplineNumber(round, teamNumber) - 1).toString();

    DatabaseReference databaseParent = FirebaseDatabase.instance.ref(
        '/results/rounds/$databaseRound/matches/$disciplineNumber/$teamOrderString');
    DatabaseEvent event = await databaseParent.once();
    return double.tryParse(event.snapshot.value.toString()) ?? -1.0;
  }
  return -2;
}

Future<List<double>> getAllTeamPointsInDisciplineSortedByMatch(
    int disciplineNumber, int teamNumber) async {
  List<double> summarizedPointList = [];
  for (int index = 0; index < pairings.length; index++) {
    var pairing = pairings[index];
    var match = pairing[disciplineNumber - 1];
    if (isNumberInString(match, teamNumber)) {
      var teams = match.split('-');
      var teamOrderString =
          teams[0].contains(teamNumber.toString()) ? "team1" : "team2";

      DatabaseReference databaseMatch = FirebaseDatabase.instance.ref(
          '/results/rounds/$index/matches/${disciplineNumber - 1}/$teamOrderString');
      DatabaseEvent event = await databaseMatch.once();
      summarizedPointList
          .add(double.tryParse(event.snapshot.value.toString()) ?? 0.0);
    }
  }
  return summarizedPointList;
}

List<double> sortValuesByOrder(List<double> values, List<int> order) {
  List<MapEntry<int, double>> indexedValues = [];

  for (int i = 0; i < values.length; i++) {
    indexedValues.add(MapEntry(order[i] - 1, values[i]));
  }

  indexedValues.sort((a, b) => a.key.compareTo(b.key));

  return indexedValues.map((entry) => entry.value).toList();
}

Future<DateTime> getOlympiadeStartDateTime() async {
  DatabaseReference databaseParent =
      FirebaseDatabase.instance.ref('/time/startTime');
  DatabaseEvent event = await databaseParent.once();
  return stringToDateTime(event.snapshot.value.toString());
}

Future<DateTime> getPauseStartTime() async {
  DatabaseReference databaseParent =
      FirebaseDatabase.instance.ref('/time/pauseStartTime');
  DatabaseEvent event = await databaseParent.once();
  return stringToDateTime(event.snapshot.value.toString());
}

Future<int> getPauseTime() async {
  DatabaseReference databaseParent =
      FirebaseDatabase.instance.ref('/time/pauseTime');
  DatabaseEvent event = await databaseParent.once();
  return int.tryParse(event.snapshot.value.toString()) ?? 0;
}

double getPointsInList(List<double> pointsList) =>
    pointsList.fold(0.0, (previousValue, element) => previousValue + element);

List<double> getPointsForDiscipline(List<double> disciplineList) {
  List<double> initialList = List.from(disciplineList);
  disciplineList.sort((a, b) => b.compareTo(a));

  var ranks = assignInitialRanks(disciplineList);
  ranks = adjustRanksForDuplicates(disciplineList, ranks);
  var points = rankToPoints(ranks);

  List<double> result = [];

  for (int i = 0; i < initialList.length; i++) {
    int index = disciplineList.indexOf(initialList[i]);
    result.add(points[index]);
  }

  return result;
}

List<double> assignInitialRanks(List<double> numbers) {
  return List<double>.generate(numbers.length, (index) => index + 1.0);
}

List<double> adjustRanksForDuplicates(
    List<double> numbers, List<double> ranks) {
  int i = 0;
  while (i < numbers.length) {
    int count = 1;
    while (i + count < numbers.length && numbers[i] == numbers[i + count]) {
      count++;
    }
    if (count > 1) {
      double averageRank = (2 * ranks[i] + count - 1) / 2.0;
      for (int j = 0; j < count; j++) {
        ranks[i + j] = averageRank;
      }
      i += count;
    } else {
      i++;
    }
  }
  return ranks;
}

List<double> rankToPoints(List<double> ranks) {
  int maxPoints = ranks.length;
  return ranks.map((rank) => maxPoints + 1.0 - rank).toList();
}
