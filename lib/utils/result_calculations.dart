import 'match_data.dart';
import 'match_detail_queries.dart';

double getPointsInList(List<double> pointsList) =>
    pointsList.fold(0.0, (previousValue, element) => previousValue + element);

List<double> assignInitialRanks(List<double> numbers) {
  return List<double>.generate(numbers.length, (index) => index + 1.0);
}

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

List<double> sortValuesByOrder(List<double> values, List<int> order) {
  List<MapEntry<int, double>> indexedValues = [];

  for (int i = 0; i < values.length; i++) {
    indexedValues.add(MapEntry(order[i] - 1, values[i]));
  }

  indexedValues.sort((a, b) => a.key.compareTo(b.key));

  return indexedValues.map((entry) => entry.value).toList();
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

Future<List<double>> getListOfPointsForDiscipline(int disciplineNumber) async {
  List<double> resultList = [];

  for (int i = 1; i <= pairings[0].length; i++) {
    var value =
    await getAllTeamPointsInDisciplineSortedByMatch(disciplineNumber, i);
    resultList.add(getPointsInList(value));
  }

  return resultList;
}

Future<List<double>> getWinner() async {
  List<double> resultList = [];

  for (int j = 1; j <= pairings[0].length; j++) {
    var getListsOfReachedPoints = await getListOfPointsForDiscipline(j);
    var getAveragePointsLists = getPointsForDiscipline(getListsOfReachedPoints);
    resultList.addAll(getAveragePointsLists);
  }

  List<double> summedList = [];
  for (int i = 0; i < pairings[0].length; i++) {
    double sum = 0.0;
    for (int j = i; j < resultList.length; j += pairings[0].length) {
      sum += resultList[j];
    }
    summedList.add(sum);
  }

  return summedList;
}