import 'package:flutter/material.dart';

import 'DartConstants.dart';

class DartAnalyticsScreen extends StatelessWidget {
  final List<PlayerTurn> turnHistory;
  final List<Player> playerList;

  const DartAnalyticsScreen({
    super.key,
    required this.turnHistory,
    required this.playerList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live-Statistiken'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${turnHistory.length} Aufnahmen',
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    '${turnHistory.fold(0, (sum, turn) => sum + turn.throws.length)} geworfene Darts',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: playerList.length,
                itemBuilder: (context, index) {
                  return playerAnalyticsCard(playerList[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget playerAnalyticsCard(Player player) {
    List<PlayerTurn> playerTurns =
        turnHistory.where((turn) => turn.player == player).toList();

    int totalThrows =
        playerTurns.fold(0, (sum, turn) => sum + turn.throws.length);
    double avgScore = totalThrows > 0
        ? playerTurns.fold(0, (sum, turn) => sum + turn.turnSum) / totalThrows
        : 0.0;

    int first9ThrowsSum = playerTurns
        .expand((turn) => turn.throws)
        .take(9)
        .fold(0, (sum, throwItem) => sum + throwItem.calculateScore());
    double first9AvgScore =
    playerTurns.expand((turn) => turn.throws).take(9).isNotEmpty
        ? first9ThrowsSum /
        playerTurns.expand((turn) => turn.throws).take(9).length
        : 0.0;

    int maxTurnSum = playerTurns.isNotEmpty
        ? playerTurns
            .map((turn) => turn.turnSum)
            .reduce((a, b) => a > b ? a : b)
        : 0;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: player.image,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    player.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Durchschnittliche Punkte:',
                      style: TextStyle(fontSize: 16)),
                  Text(avgScore.toStringAsFixed(2),
                      style: TextStyle(
                          fontSize: 16,
                          color: avgScore > 40 ? Colors.amber : Colors.white,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Durchschnitt in den ersten 9 Würfen:',
                      style: TextStyle(fontSize: 16)),
                  Text(first9AvgScore.toStringAsFixed(2),
                      style: TextStyle(
                          fontSize: 16,
                          color:
                          first9AvgScore > 40 ? Colors.amber : Colors.white,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Maximale Punkte in einer Runde:',
                      style: TextStyle(fontSize: 16)),
                  Text('$maxTurnSum',
                      style: TextStyle(
                          fontSize: 16,
                          color: maxTurnSum >= 100 ? Colors.amber : Colors.white,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Gesamtzahl der Würfe:',
                      style: TextStyle(fontSize: 16)),
                  Text('$totalThrows',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
