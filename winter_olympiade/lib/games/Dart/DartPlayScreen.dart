import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olympiade/games/Dart/DartAnalyticsScreen.dart';
import 'package:olympiade/games/Dart/DartStartScreen.dart';
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
  Duration flipDuration = const Duration(milliseconds: 250);

  AvgScoreResult getAvgScore(List<PlayerTurn> playerTurns) {
    if (playerTurns.isEmpty) return AvgScoreResult(0.0, 0);

    int totalScore = 0;
    int totalThrows = 0;

    for (var turn in playerTurns) {
      if (turn.overthrown) {
        if (turn != playerTurns.last) {
          totalThrows += 3;
        } else {
          totalThrows += turn.throws.length;
          totalScore +=
              turn.throws.fold(0, (sum, t) => sum + t.calculateScore());
        }
      } else {
        totalScore += turn.turnSum;
        totalThrows += turn.throws.length;
      }
    }

    double avgScore = totalThrows > 0 ? totalScore / totalThrows : 0.0;
    return AvgScoreResult(avgScore, totalThrows);
  }

  void nextPlayer() {
    setState(() {
      currentPlayerIndex = (currentPlayerIndex + 1) % widget.playerList.length;
      turnHistory.add(PlayerTurn(
          player: widget.playerList[currentPlayerIndex], throws: []));
    });
  }

  int calculatePlayerScore(Player player) {
    int score = widget.gameType;

    for (var turn in turnHistory.where((t) => t.player == player && !t.overthrown)) {
      score -= turn.turnSum;
    }

    return score >= 0 ? score : 0;
  }

  void onFinish() {
    HapticFeedback.heavyImpact();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const DartStartScreen(),
      ),
    );
  }

  void onOverthrown() {
    setState(() {
      turnHistory.last = PlayerTurn(
        player: turnHistory.last.player,
        throws: turnHistory.last.throws,
        overthrown: true,
      );
      nextPlayer();
    });
  }

  void onScoreSelected(int score, Multiplier multiplier) {
    int currentPlayerScore = calculatePlayerScore(
        widget.playerList[currentPlayerIndex]);
    int throwPoints = score * (multiplier.index + 1);
    setState(() {
      if (turnHistory.isEmpty ||
          turnHistory.last.player != widget.playerList[currentPlayerIndex]) {
        turnHistory.add(PlayerTurn(
            player: widget.playerList[currentPlayerIndex],
            throws: [Throw(score: score, multiplier: multiplier)]));
      } else {
        turnHistory.last.throws
            .add(Throw(score: score, multiplier: multiplier));
      }


      if (currentPlayerScore - throwPoints == 0) {
        if (widget.gameEndRule == GameEndRule.doubleOut) {
          if (multiplier == Multiplier.double) {
            return onFinish();
          } else {
            return onOverthrown();
          }
        } else {
          return onFinish();
        }
      }
      if (currentPlayerScore - throwPoints < 0) {
        return onOverthrown();
      }

      if (turnHistory.last.throws.length == 3) {
        nextPlayer();
      }
    });
  }

  void removeThrow() {
    setState(() {
      if (turnHistory.isNotEmpty &&
          (turnHistory.length != 1 || turnHistory[0].throws.isNotEmpty)) {
        if (turnHistory.last.throws.isNotEmpty) {
          turnHistory.last.throws.removeLast();
          turnHistory.last.overthrown = false;
        } else {
          turnHistory.removeLast();
          currentPlayerIndex =
              (currentPlayerIndex - 1 + widget.playerList.length) %
                  widget.playerList.length;
          turnHistory.last.throws.removeLast();
          turnHistory.last.overthrown = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final bool shouldPop = await _showConfirmationDialog(context) ?? false;
        if (context.mounted && shouldPop) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('Dart'),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.undo, size: 32),
                      onPressed: (turnHistory.isEmpty ||
                          (turnHistory.length == 1 &&
                              turnHistory[0].throws.isEmpty))
                          ? null
                          : () {
                        HapticFeedback.lightImpact();
                        removeThrow();
                          },
                    ),
                    IconButton(
                      icon: const Icon(Icons.analytics),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DartAnalyticsScreen(
                                  turnHistory: turnHistory,
                                  playerList: widget.playerList,
                                ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.playerList
                      .map((player) => playerCard(player))
                      .toList(),
                ),
              ),
            ),
            DartsKeyboard(onScoreSelected: onScoreSelected),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Spiel beenden"),
          content: const Text("Möchtest du dieses Spiel wirklich beenden?"),
          actions: <Widget>[
            TextButton(
              child: const Text('Nein', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Ja', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  Widget currentScore(Player playerInCard) {
    return Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedFlipCounter(
            duration: flipDuration,
            value: calculatePlayerScore(playerInCard),
            textStyle: const TextStyle(fontSize: 40, color: Colors.white),
            mainAxisAlignment: MainAxisAlignment.center,
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
    List<Throw> lastThrows =
    playerTurns.isNotEmpty ? playerTurns.last.throws : [];

    bool currentlyOverthrown = playerTurns.isNotEmpty &&
        playerTurns.last.overthrown;

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
                    if (lastThrows[index].multiplier == Multiplier.single &&
                        lastThrows[index].score == 25) {
                      displayValue = 'SB';
                    } else if (lastThrows[index].multiplier ==
                        Multiplier.double &&
                        lastThrows[index].score == 25) {
                      displayValue = 'DB';
                    } else if (lastThrows[index].multiplier != Multiplier.single &&
                        lastThrows[index].score == 0) {
                      displayValue = lastThrows[index].score.toString();
                    } else {
                      String prefix = '';
                      if (lastThrows[index].multiplier == Multiplier.double) {
                        prefix = 'D';
                      } else if (lastThrows[index].multiplier ==
                          Multiplier.triple) {
                        prefix = 'T';
                      }
                      displayValue = '$prefix${lastThrows[index].score}';
                    }
                    return Expanded(
                      child: Container(
                        color: currentlyOverthrown ? Colors.red : Colors.black,
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
                        color: currentlyOverthrown ? Colors.red : Colors.black,
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
              lastThrows.isNotEmpty
                  ? lastThrows
                  .map((e) => e.calculateScore())
                  .reduce((a, b) => a + b)
                  .toString()
                  : '0',
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget currentStatistics(List<PlayerTurn> playerTurns) {
    AvgScoreResult currentScores = getAvgScore(playerTurns);
    int lastTurnSum = 0;
    if (playerTurns.isNotEmpty &&
        (playerTurns.last.throws.length == 3)) {
      lastTurnSum = playerTurns.last.turnSum;
    } else if (playerTurns.isNotEmpty && playerTurns.last.overthrown) {
      lastTurnSum = 0;
    } else if (playerTurns.length > 1 &&
        (playerTurns.last.throws.length < 3)) {
      lastTurnSum = playerTurns[playerTurns.length - 2].turnSum;
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
                AnimatedFlipCounter(
                  duration: flipDuration,
                  value: lastTurnSum,
                  textStyle: const TextStyle(color: Colors.white, fontSize: 16),
                  mainAxisAlignment: MainAxisAlignment.end,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Avg:"),
                AnimatedFlipCounter(
                  duration: flipDuration,
                  value: currentScores.avgScore,
                  fractionDigits: 2,
                  textStyle: const TextStyle(color: Colors.white, fontSize: 16),
                  mainAxisAlignment: MainAxisAlignment.end,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Darts:"),
                AnimatedFlipCounter(
                  duration: flipDuration,
                  value: currentScores.totalThrows,
                  textStyle: const TextStyle(color: Colors.white, fontSize: 16),
                  mainAxisAlignment: MainAxisAlignment.end,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget playerCard(Player playerInCard) {
    bool isCurrentPlayer =
        widget.playerList.indexOf(playerInCard) == currentPlayerIndex;
    Color? defaultColor = Colors.grey[900];

    List<PlayerTurn> playerTurns =
    turnHistory.where((turn) => turn.player == playerInCard).toList();

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        color: defaultColor,
        height: 125,
        child: Row(
          children: [
            Container(
                color: isCurrentPlayer ? Colors.green : defaultColor,
                width: 10),
            currentScore(playerInCard),
            currentThrowScores(playerTurns),
            currentStatistics(playerTurns),
          ],
        ),
      ),
    );
  }
}
