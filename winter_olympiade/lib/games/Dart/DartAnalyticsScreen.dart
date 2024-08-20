import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'DartConstants.dart';
import 'DartStartScreen.dart';

class DartAnalyticsScreen extends StatelessWidget {
  final List<PlayerTurn> turnHistory;
  final List<Player> playerList;
  final bool isFinished;

  const DartAnalyticsScreen({
    super.key,
    required this.turnHistory,
    required this.playerList,
    required this.isFinished,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (isFinished) {
              HapticFeedback.heavyImpact();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const DartStartScreen(),
                ),
              );
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
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

    int first18ThrowsSum = playerTurns
        .expand((turn) => turn.throws)
        .take(18)
        .fold(0, (sum, throwItem) => sum + throwItem.calculateScore());
    double first18AvgScore =
    playerTurns.expand((turn) => turn.throws).take(18).isNotEmpty
        ? first18ThrowsSum /
        playerTurns.expand((turn) => turn.throws).take(18).length
        : 0.0;

    int maxTurnSum = playerTurns.isNotEmpty
        ? playerTurns
        .map((turn) => turn.turnSum)
        .reduce((a, b) => a > b ? a : b)
        : 0;

    int totalOverthrows = playerTurns.where((turn) => turn.overthrown).length;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Make content scrollable
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
              _buildStatRow('Durchschnittliche Punkte:', avgScore, 40),
              _buildStatRow('Durchschnitt erste 9 Würfe:', first9AvgScore, 40),
              _buildStatRow('Durchschnitt erste 18 Würfe:', first18AvgScore, 40),
              _buildStatRow('Maximale Punkte in einer Runde:', maxTurnSum, 100),
              _buildStatRow('Gesamtzahl der Würfe:', totalThrows, 1000),
              _buildStatRow('Anzahl Überworfen:', totalOverthrows, 1000),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String title, num value, num threshold) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(
            value is double
                ? value.toStringAsFixed(2)
                : value.toString(),
            style: TextStyle(
              fontSize: 16,
              color: value > threshold ? Colors.amber : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}