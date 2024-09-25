import 'dart:convert';

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olympiade/games/Dart/dart_analytics_screen.dart';
import 'package:olympiade/games/Dart/dart_finish_combinations.dart';
import 'package:olympiade/games/Dart/darts_keyboard.dart';
import 'package:olympiade/infos/achievements/achievement_provider.dart';
import 'package:olympiade/utils/confirmation_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'dart_constants.dart';

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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    loadGameState();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _scrollController.dispose();
    super.dispose();
  }

  void saveGameState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> turnHistoryJson = turnHistory.map((turn) {
      return jsonEncode({
        'player': turn.player.toJson(),
        'throws': turn.throws.map((t) {
          return {'score': t.score, 'multiplier': t.multiplier.index};
        }).toList(),
        'overthrown': turn.overthrown,
      });
    }).toList();

    await prefs.setStringList('turnHistory', turnHistoryJson);
    await prefs.setInt('currentPlayerIndex', currentPlayerIndex);
  }

  void loadGameState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? turnHistoryJson = prefs.getStringList('turnHistory');
    if (turnHistoryJson != null) {
      List<PlayerTurn> loadedTurnHistory = turnHistoryJson.map((turnString) {
        Map<String, dynamic> turnMap = jsonDecode(turnString);

        return PlayerTurn(
          player: Player.fromJson(turnMap['player']),
          throws: (turnMap['throws'] as List).map((throwMap) {
            return Throw(
              score: throwMap['score'],
              multiplier: Multiplier.values[throwMap['multiplier']],
            );
          }).toList(),
          overthrown: turnMap['overthrown'],
        );
      }).toList();

      setState(() {
        turnHistory = loadedTurnHistory;
        currentPlayerIndex = prefs.getInt('currentPlayerIndex') ?? 0;
      });
    }
  }

  AvgScoreResult getAvgScore(List<PlayerTurn> playerTurns) {
    if (playerTurns.isEmpty) return AvgScoreResult(0.0, 0);

    int totalScore = 0;
    int totalTurns = playerTurns.length;

    for (var turn in playerTurns) {
      totalScore += turn.turnSum;
    }

    double avgScore = totalTurns > 0 ? totalScore / totalTurns : 0.0;
    return AvgScoreResult(avgScore, totalTurns);
  }

  void nextPlayer() {
    setState(() {
      currentPlayerIndex = (currentPlayerIndex + 1) % widget.playerList.length;
      turnHistory.add(PlayerTurn(
          player: widget.playerList[currentPlayerIndex], throws: []));
      saveGameState();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        currentPlayerIndex * 130.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  int calculatePlayerScore(Player player) {
    int score = widget.gameType;

    for (var turn in turnHistory
        .where((t) => t.player.name == player.name && !t.overthrown)) {
      score -= turn.turnSum;
    }

    return score >= 0 ? score : 0;
  }

  Future<void> onFinish() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('turnHistory');
    await prefs.remove('currentPlayerIndex');

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DartAnalyticsScreen(
          turnHistory: turnHistory,
          playerList: widget.playerList,
          isFinished: true,
        ),
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

  Future<void> onScoreSelected(int score, Multiplier multiplier) async {
    int currentPlayerScore =
        calculatePlayerScore(widget.playerList[currentPlayerIndex]);
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

      saveGameState();
    });

    if (score == 20 && multiplier == Multiplier.triple) {
      context
          .read<AchievementProvider>()
          .completeAchievementByTitle('Mehr geht nicht!');
    }

    if (score == 1 && multiplier == Multiplier.triple) {
      context
          .read<AchievementProvider>()
          .completeAchievementByTitle('Umgekehrte Psychologie');
    }

    if (score == 25 &&
        (multiplier == Multiplier.single || multiplier == Multiplier.double)) {
      context
          .read<AchievementProvider>()
          .completeAchievementByTitle('Bullseye!');
    }

    if (currentPlayerScore - throwPoints == 0) {
      if (widget.gameEndRule == GameEndRule.doubleOut) {
        if (multiplier == Multiplier.double) {
          await onFinish();
        } else {
          onOverthrown();
        }
      } else {
        await onFinish();
      }
    } else if (currentPlayerScore - throwPoints < 0) {
      onOverthrown();
    } else if (currentPlayerScore - throwPoints == 1 && widget.gameEndRule == GameEndRule.doubleOut) {
      onOverthrown();
    } else if (turnHistory.last.throws.length == 3) {
      nextPlayer();
    }
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
        saveGameState();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final bool shouldPop = await ConfirmationDialog.show(
            context: context,
            title: "Spiel beenden",
            content: "Möchtest du dieses Spiel wirklich beenden?");
        if (shouldPop) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('turnHistory');
          await prefs.remove('currentPlayerIndex');
          if (context.mounted) Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
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
                            builder: (context) => DartAnalyticsScreen(
                              turnHistory: turnHistory,
                              playerList: widget.playerList,
                              isFinished: false,
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
                controller: _scrollController,
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
    bool currentlyOverthrown =
        playerTurns.isNotEmpty && playerTurns.last.overthrown;
    int currentPlayerScore =
        calculatePlayerScore(widget.playerList[currentPlayerIndex]);

    List<String>? finishCombination =
        getFinishingCombination(currentPlayerScore, 3 - lastThrows.length);

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
                    } else if (lastThrows[index].multiplier !=
                            Multiplier.single &&
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
                    String displayValue = '';
                    int finishIndex = index - lastThrows.length;
                    if (finishCombination != null &&
                        finishCombination.length <= (3 - lastThrows.length) &&
                        finishIndex < finishCombination.length) {
                      displayValue = finishCombination[finishIndex];
                    }
                    return Expanded(
                      child: Container(
                        color: currentlyOverthrown ? Colors.red : Colors.black,
                        margin: const EdgeInsets.all(2),
                        child: Center(
                          child: Text(
                            displayValue,
                            style: TextStyle(color: Colors.grey[700]),
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
    if (playerTurns.isNotEmpty && (playerTurns.last.throws.length == 3)) {
      lastTurnSum = playerTurns.last.turnSum;
    } else if (playerTurns.isNotEmpty && playerTurns.last.overthrown) {
      lastTurnSum = 0;
    } else if (playerTurns.length > 1 && (playerTurns.last.throws.length < 3)) {
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

    List<PlayerTurn> playerTurns = turnHistory
        .where((turn) => turn.player.name == playerInCard.name)
        .toList();

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
