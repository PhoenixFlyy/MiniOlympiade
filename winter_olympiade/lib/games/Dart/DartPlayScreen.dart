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
    setState(() =>
    currentPlayerIndex = (currentPlayerIndex + 1) % widget.playerList.length);
  }

  void recordTurn(List<Throw> throws) {
    final currentPlayer = widget.playerList[currentPlayerIndex];
    final playerTurn = PlayerTurn(player: currentPlayer, throws: throws);

    setState(() {
      turnHistory.add(playerTurn);
    });
  }

  int calculatePlayerScore(Player player) {
    int score = widget.gameType;

    for (var turn in turnHistory.where((t) => t.player == player)) {
      score -= turn.turnSum;
    }

    return score >= 0 ? score : 0;
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
          const DartsKeyboard(),
        ],
      ),
    );
  }

  Widget currentScore(Player playerInCard) {
    return Expanded(
      flex: 3,
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
                  if (playerTurns.isNotEmpty && index < playerTurns.length) {
                    return Expanded(
                      child: Container(
                        color: Colors.black,
                        margin: const EdgeInsets.all(2),
                        child: Center(
                          child: Text(
                            playerTurns[index].turnSum.toString(),
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
              "${playerTurns.isNotEmpty ? playerTurns.map((e) => e.turnSum).reduce((a, b) => a + b) : 0}",
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget currentStatistics(List<PlayerTurn> playerTurns) {
    int lastThrow = 0;
    if (playerTurns.isNotEmpty) {
      PlayerTurn lastTurn = playerTurns.last;
      if (lastTurn.throws.isNotEmpty) {
        lastThrow = lastTurn.throws.last.calculateScore();
      }
    }

    double avgScore = playerTurns.isNotEmpty
        ? playerTurns.fold(0, (sum, t) => sum + t.turnSum) / playerTurns.length
        : 0;

    int totalDarts = playerTurns.fold(0, (sum, t) => sum + t.throws.length);

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
                  " $lastThrow",
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