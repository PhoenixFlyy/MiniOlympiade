import 'package:flutter/material.dart';
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
  int currentPlayerTurn = 0;
  List<DartThrow> dartThrowHistory = [];

  void nextPlayer() {
    setState(() => currentPlayerTurn = (currentPlayerTurn + 1) % widget.playerList.length);
  }

  void recordThrow(int score, Multiplier multiplier) {
    final currentPlayer = widget.playerList[currentPlayerTurn];
    final dartThrow = DartThrow(player: currentPlayer, score: score, multiplier: multiplier);

    setState(() {
      dartThrowHistory.add(dartThrow);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dart Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Game Type: ${widget.gameType}', style: const TextStyle(fontSize: 18)),
            Text('Game End Rule: ${widget.gameEndRule == GameEndRule.doubleOut ? 'Double Out' : 'Single Out'}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text('Players:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...widget.playerList.map((player) => Text(player.name, style: const TextStyle(fontSize: 18))),
          ],
        ),
      ),
    );
  }
}
