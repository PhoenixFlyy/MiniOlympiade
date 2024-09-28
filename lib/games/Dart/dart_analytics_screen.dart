import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart_constants.dart';
import 'darts_start_screen.dart';

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
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (isFinished) {
              HapticFeedback.heavyImpact();
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
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
    List<PlayerTurn> playerTurns = turnHistory.where((turn) => turn.player == player).toList();

    double avgScore = playerTurns.isNotEmpty
        ? playerTurns.fold(0, (sum, turn) => sum + turn.turnSum) / playerTurns.length
        : 0.0;

    double first3AvgScore = playerTurns.length >= 3
        ? playerTurns.take(3).fold(0, (sum, turn) => sum + turn.turnSum) / 3
        : 0.0;

    double first5AvgScore = playerTurns.length >= 5
        ? playerTurns.take(5).fold(0, (sum, turn) => sum + turn.turnSum) / 5
        : 0.0;

    int maxTurnSum = playerTurns.isNotEmpty
        ? playerTurns.map((turn) => turn.turnSum).reduce((a, b) => a > b ? a : b)
        : 0;

    int totalOverthrows = playerTurns.where((turn) => turn.overthrown).length;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
              _buildStatRow('Durchschnittliche Punkte pro Runde:', avgScore, 40),
              _buildStatRow('Durchschnitt der ersten 3 Runden:', first3AvgScore, 40),
              _buildStatRow('Durchschnitt der ersten 5 Runden:', first5AvgScore, 40),
              _buildStatRow('Maximale Punkte in einer Runde:', maxTurnSum, 100),
              _buildStatRow('Gesamtzahl der Würfe:', playerTurns.fold(0, (sum, turn) => sum + turn.throws.length), 1000),
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