import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SchachUhr extends StatefulWidget {
  const SchachUhr({Key? key, required this.maxtime}) : super(key: key);
  final int maxtime;

  @override
  State<SchachUhr> createState() => _SchachUhrState();
}

class _SchachUhrState extends State<SchachUhr> {
  bool isPlayer1Turn = true;
  bool isPlayer1Active = true;
  bool isPlayer2Active = false;
  bool isTimerRunning = false;
  int player1Time = 0;
  int player2Time = 0;
  late Timer timer;
  Color player1Color = Colors.green;
  Color player2Color = Colors.grey; // Startet mit Grau

  _SchachUhrState() {
    player1Color = isPlayer1Active ? Colors.green : Colors.grey;
  }

  @override
  void initState() {
    super.initState();
    player1Time = widget.maxtime;
    player2Time = widget.maxtime;
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void switchTurns() {
    setState(() {
      isPlayer1Turn = !isPlayer1Turn;
      isPlayer1Active = !isPlayer1Active;
      isPlayer2Active = !isPlayer2Active;

      player1Color = isPlayer1Active ? Colors.green : Colors.grey;
      player2Color = isPlayer2Active ? Colors.green : Colors.grey;

      if (!isTimerRunning) {
        startTimer();
      }
    });
  }

  void startTimer() {
    isTimerRunning = true;
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        if (isPlayer1Active) {
          player1Time--;
        } else if (isPlayer2Active) {
          player2Time--;
        }
      });

      if (player1Time <= 0 || player2Time <= 0) {
        timer.cancel();
        handleTimeout();
      }
    });
  }

  void handleTimeout() {
    SystemSound.play(SystemSoundType.alert);
    String loser = isPlayer1Active ? "Spieler 1" : "Spieler 2";

    setState(() {
      isTimerRunning = false;
      if (isPlayer1Active) {
        player1Color = Colors.red;
      } else {
        player2Color = Colors.red;
      }
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Zeit abgelaufen"),
        content: Text("$loser's Zeit ist abgelaufen!"),
      ),
    );
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: const Text("Schachuhr", style: TextStyle(fontSize: 20)),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (isPlayer1Turn && isPlayer1Active) {
                  HapticFeedback.heavyImpact();
                  switchTurns();
                }
              },
              child: Container(
                color: player1Color,
                alignment: Alignment.center,
                child: Text(
                  formatTime(player1Time),
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isPlayer1Turn && isPlayer2Active) {
                  HapticFeedback.heavyImpact();
                  switchTurns();
                }
              },
              child: Container(
                color: player2Color,
                alignment: Alignment.center,
                child: Text(
                  formatTime(player2Time),
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
