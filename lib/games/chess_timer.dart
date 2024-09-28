import 'dart:async';
import 'dart:math';

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../infos/achievements/achievement_provider.dart';
import '../utils/play_sounds.dart';

class ChessTimer extends StatefulWidget {
  const ChessTimer({super.key, required this.maxTime});

  final int maxTime;

  @override
  State<ChessTimer> createState() => _ChessTimerState();
}

class _ChessTimerState extends State<ChessTimer> {
  Timer? timer;
  bool playerOneTurn = false;
  late double playerOneTime;
  late double playerTwoTime;

  int playerOneTurns = 0;
  int playerTwoTurns = 0;

  final audioService = AudioService();

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    resetTimers();
  }

  @override
  void dispose() {
    timer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  void resetTimers() {
    playerOneTime = widget.maxTime.toDouble();
    playerTwoTime = widget.maxTime.toDouble();
    playerOneTurns = 0;
    playerTwoTurns = 0;
  }

  void startTimer() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      setState(() {
        if (playerOneTurn) {
          if (playerOneTime > 0) {
            playerOneTime -= 0.1;
          } else {
            playerOneTime = 0.0;
            timer.cancel();
            audioService.playAlarmSound();
            context.read<AchievementProvider>().completeAchievementByTitle('Hochstapler');
          }
        } else {
          if (playerTwoTime > 0) {
            playerTwoTime -= 0.1;
          } else {
            playerTwoTime = 0.0;
            timer.cancel();
            audioService.playAlarmSound();
            context.read<AchievementProvider>().completeAchievementByTitle('Hochstapler');
          }
        }
      });
    });
  }

  void togglePlayerTurn() {
    setState(() {
      if (playerOneTurn) {
        playerOneTurns++;
      } else {
        playerTwoTurns++;
      }
      playerOneTurn = !playerOneTurn;
    });
  }

  Widget buildPlayerTimer({
    required bool isPlayerOne,
    required bool isTurn,
  }) {
    double currentTime = isPlayerOne ? playerOneTime : playerTwoTime;

    return Expanded(
      child: GestureDetector(
        onTap: isTurn
            ? () {
          togglePlayerTurn();
          startTimer();
        }
            : null,
        child: Container(
          color: isTurn ? Colors.red : Colors.grey[700],
          child: Center(
            child: Transform.rotate(
              angle: isPlayerOne ? pi : 0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: SizedBox(
                      width: 250,
                      height: 250,
                      child: CircularProgressIndicator(
                        value: currentTime / widget.maxTime,
                        strokeWidth: 15,
                        color: Colors.grey[900],
                        strokeCap: StrokeCap.square,
                        backgroundColor: isTurn ? Colors.red : Colors.grey[700],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedFlipCounter(
                        value: (currentTime ~/ 60),
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        ":",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AnimatedFlipCounter(
                        value: (currentTime % 60).floor(),
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        ":",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ((currentTime - currentTime.floor()) * 10)
                            .floor()
                            .toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Text(
                      'Züge: ${isPlayerOne ? playerOneTurns : playerTwoTurns}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text("Schachuhr",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            )),
      ),
      body: Column(
        children: [
          buildPlayerTimer(
            isPlayerOne: true,
            isTurn: playerOneTurn,
          ),

          Container(
            height: 50,
            color: Colors.grey[900],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    (timer != null && timer!.isActive) ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    timer?.cancel();
                    setState(() {
                      timer = null;
                    });
                  },
                ),
                const SizedBox(width: 50),
                IconButton(
                  icon: const Icon(Icons.restart_alt, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      resetTimers();
                      timer?.cancel();
                    });
                  },
                ),
              ],
            ),
          ),

          buildPlayerTimer(
            isPlayerOne: false,
            isTurn: !playerOneTurn,
          ),
        ],
      ),
    );
  }
}