import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../game/assets.dart';
import '../game/flappy_wue_game.dart';

class GameOverScreen extends StatefulWidget {
  final FlappyWueGame game;
  static const String id = 'gameOver';

  const GameOverScreen({super.key, required this.game});

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  List<Map<String, dynamic>> topPlayers = [];

  @override
  void initState() {
    super.initState();
    fetchTopScores();
    uploadPlayerScore();
  }

  Future<void> fetchTopScores() async {
    try {
      final DatabaseReference ref = FirebaseDatabase.instance.ref('flappyBirds');
      final DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        List<Map<String, dynamic>> playerScores = [];

        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          playerScores.add({
            'name': key,
            'score': value['score'] ?? 0,
          });
        });

        playerScores.sort((a, b) => b['score'].compareTo(a['score']));
        List<Map<String, dynamic>> topScores = playerScores.take(10).toList();

        setState(() {
          topPlayers = topScores;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching top scores: $e');
      }
    }
  }

  Future<void> uploadPlayerScore() async {
    final prefs = await SharedPreferences.getInstance();
    String? playerName = prefs.getString('teamName');

    if (playerName != null) {
      final DatabaseReference playerRef = FirebaseDatabase.instance.ref('flappyBirds/$playerName');
      final DataSnapshot snapshot = await playerRef.get();

      int newScore = widget.game.bird.score;

      if (snapshot.exists) {
        int currentScore = snapshot.child('score').value as int;

        if (newScore > currentScore) {
          await playerRef.update({'score': newScore});
          await fetchTopScores();
        }
      } else {
        await playerRef.set({'score': newScore});
        await fetchTopScores();
      }
    }
  }

  Widget _topPlayerList() {
    return Column(
      children: List.generate(topPlayers.length, (i) {
        var player = topPlayers[i];
        String leadingEmoji;
        double emojiSize = 24;
        double textSize = 24;

        if (i == 0) {
          leadingEmoji = '🥇';
          emojiSize = 40;
          textSize = 30;
        } else if (i == 1) {
          leadingEmoji = '🥈';
          emojiSize = 35;
          textSize = 28;
        } else if (i == 2) {
          leadingEmoji = '🥉';
          emojiSize = 30;
          textSize = 26;
        } else {
          leadingEmoji = '${i + 1}.';
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                leadingEmoji,
                style: TextStyle(fontSize: emojiSize),
              ),
              const SizedBox(width: 8),
              Text(
                '${player['name']}: ${player['score']}',
                style: TextStyle(
                  fontSize: textSize,
                  color: Colors.white,
                  fontFamily: Assets.gameFont,
                  fontWeight: i == 0 ? FontWeight.bold : null
                ),
              ),
            ],
          ),
        );
      }),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black38,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: ${widget.game.bird.score}',
              style: const TextStyle(
                fontSize: 60,
                color: Colors.white,
                fontFamily: Assets.gameFont,
                fontWeight: FontWeight.bold
              ),
            ),
            Image.asset(Assets.gameOver),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: onRestart,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text(
                  'Restart',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                )),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () => onExit(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: const Text(
                  'Exit',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                )),
            const SizedBox(height: 40),
            const Text(
              'Top 10 Scores',
              style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontFamily: Assets.gameFont,
                  fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 10),
            _topPlayerList(),
          ],
        ),
      ),
    );
  }

  void onRestart() {
    widget.game.bird.reset();
    widget.game.overlays.remove('gameOver');
    widget.game.resumeEngine();
  }

  void onExit(BuildContext context) {
    widget.game.overlays.remove('gameOver');
    widget.game.pauseEngine();
    Navigator.pop(context);
  }
}
