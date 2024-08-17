import 'package:flutter/material.dart';
import 'package:olympiade/games/Dart/DartsKeyboard.dart';
import 'DartConstants.dart';

class DartPlayScreen extends StatefulWidget {
  final GameEndRule gameEndRule;
  final int gameType;
  final List<Player> playerList;

  const DartPlayScreen({
    super.key,
    required this.gameEndRule,
    required this.gameType,
    required this.playerList,
  });

  @override
  State<DartPlayScreen> createState() => _DartPlayScreenState();
}

class _DartPlayScreenState extends State<DartPlayScreen> {
  int currentPlayerIndex = 0;
  List<PlayerTurn> turnHistory = [];

  void nextPlayer() {
    setState(() {
      currentPlayerIndex = (currentPlayerIndex + 1) % widget.playerList.length;
      turnHistory.add(PlayerTurn(player: widget.playerList[currentPlayerIndex], throws: []));
    });
  }

  int calculatePlayerScore(Player player) {
    int score = widget.gameType;

    for (var turn in turnHistory.where((t) => t.player == player)) {
      score -= turn.turnSum;
    }

    return score >= 0 ? score : 0;
  }

  void onScoreSelected(int score, Multiplier multiplier) {
    setState(() {
      if (turnHistory.isEmpty || turnHistory.last.player != widget.playerList[currentPlayerIndex]) {
        turnHistory.add(PlayerTurn(player: widget.playerList[currentPlayerIndex], throws: [Throw(score: score, multiplier: multiplier)]));
      } else {
        turnHistory.last.throws.add(Throw(score: score, multiplier: multiplier));
      }
      if (turnHistory.last.throws.length == 3 || turnHistory.last.overthrown) {
        nextPlayer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dart Game'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.playerList.map((player) => playerCard(player)).toList(),
              ),
            ),
          ),
          // DartsKeyboard at the bottom
          DartsKeyboard(onScoreSelected: onScoreSelected),
        ],
      ),
    );
  }

  Widget currentScore(Player playerInCard) {
    return Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${calculatePlayerScore(playerInCard)}",
            style: const TextStyle(fontSize: 40, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          Text(
            playerInCard.name,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget currentThrowScores(List<PlayerTurn> playerTurns) {
    List<Throw> lastThrows = playerTurns.isNotEmpty ? playerTurns.last.throws : [];

    return Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 35,
            child: Row(
              children: List.generate(
                3,
                    (index) {
                  if (index < lastThrows.length) {
                    String displayValue;
                    if (lastThrows[index].multiplier == Multiplier.single && lastThrows[index].score == 25) {
                      displayValue = 'SB';
                    } else if (lastThrows[index].multiplier == Multiplier.double && lastThrows[index].score == 25) {
                      displayValue = 'DB';
                    } else {
                      String prefix = '';
                      if (lastThrows[index].multiplier == Multiplier.double) {
                        prefix = 'D';
                      } else if (lastThrows[index].multiplier == Multiplier.triple) {
                        prefix = 'T';
                      }
                      displayValue = '$prefix${lastThrows[index].score}';
                    }
                    return Expanded(
                      child: Container(
                        color: Colors.black,
                        margin: const EdgeInsets.all(2),
                        child: Center(
                          child: Text(
                            displayValue,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Expanded(
                      child: Container(
                        color: Colors.black,
                        margin: const EdgeInsets.all(2),
                        child: const Center(
                          child: Text(
                            '',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text(
              lastThrows.isNotEmpty ? lastThrows.map((e) => e.calculateScore()).reduce((a, b) => a + b).toString() : '0',
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget currentStatistics(List<PlayerTurn> playerTurns) {
    int lastTurnSum = 0;
    double avgScore = 0;
    int totalDarts = 0;

    if (playerTurns.length > 1) {
      lastTurnSum = playerTurns[playerTurns.length - 2].turnSum;
    }

    if (playerTurns.isNotEmpty) {
      int turnsToConsider = playerTurns.length;

      if (playerTurns.last.player == widget.playerList[currentPlayerIndex] && playerTurns.last.throws.length < 3) {
        turnsToConsider -= 1;
      }


      if (turnsToConsider > 0) {
        avgScore = playerTurns.sublist(0, turnsToConsider).fold(0, (sum, t) => sum + t.turnSum) / turnsToConsider;
        totalDarts = playerTurns.sublist(0, turnsToConsider).fold(0, (sum, t) => sum + t.throws.length);
      }
    }

    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Zuletzt:"),
                Text(
                  " $lastTurnSum",
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Avg:"),
                Text(
                  " ${avgScore.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Darts:"),
                Text(
                  " $totalDarts",
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget playerCard(Player playerInCard) {
    bool isCurrentPlayer = widget.playerList.indexOf(playerInCard) == currentPlayerIndex;
    Color? defaultColor = Colors.grey[900];

    List<PlayerTurn> playerTurns = turnHistory.where((turn) => turn.player == playerInCard).toList();

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        color: defaultColor,
        height: 125,
        child: Row(
          children: [
            Container(
                color: isCurrentPlayer ? Colors.green : defaultColor,
                width: 10
            ),
            currentScore(playerInCard),
            currentThrowScores(playerTurns),
            currentStatistics(playerTurns),
          ],
        ),
      ),
    );
  }
}