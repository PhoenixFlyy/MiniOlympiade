import 'package:flutter/material.dart';

import 'DataModels.dart';

class MoelkkyGameScreen extends StatefulWidget {
  const MoelkkyGameScreen({super.key});

  @override
  State<MoelkkyGameScreen> createState() => _MoelkkyGameScreenState();
}

class _MoelkkyGameScreenState extends State<MoelkkyGameScreen> {
  final List<Player> _players = [];
  final _playerNameController = TextEditingController();
  late MoelkkyGame _game;

  @override
  void initState() {
    super.initState();
    _game = MoelkkyGame(players: _players);
  }

  void _addPlayer() {
    if (_playerNameController.text.isNotEmpty) {
      setState(() {
        _players.add(Player(name: _playerNameController.text));
        _playerNameController.clear();
      });
    }
  }

  void _recordScore(int score) {
    setState(() {
      _game.calculateTurnScore(Turn(knockedPins: [score], turnScore: score));
      _game.updatePlayerScore(_game.players[_game.currentPlayerIndex], score);
      _game.checkWinCondition();
      _game.nextTurn();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mölkky Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _playerNameController,
              decoration: InputDecoration(labelText: 'Enter player name'),
            ),
            ElevatedButton(
              onPressed: _addPlayer,
              child: Text('Add Player'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _players.length,
                itemBuilder: (context, index) {
                  final player = _players[index];
                  return ListTile(
                    title: Text(player.name),
                    subtitle: Text('Score: ${player.scores.last}'),
                  );
                },
              ),
            ),
            Text('Current Player: ${_players.isNotEmpty ? _game.players[_game.currentPlayerIndex].name : 'None'}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(12, (index) {
                return ElevatedButton(
                  onPressed: () => _recordScore(index + 1),
                  child: Text('${index + 1}'),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}