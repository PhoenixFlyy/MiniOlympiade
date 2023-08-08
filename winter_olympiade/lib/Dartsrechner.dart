import 'package:flutter/material.dart';

class DartsRechner extends StatefulWidget {
  const DartsRechner({Key? key}) : super(key: key);

  @override
  State<DartsRechner> createState() => _DartsRechnerState();
}

class Turn {
  final bool wasPlayerOneTurn;
  final int turnValue;

  Turn(this.wasPlayerOneTurn, this.turnValue);
}

class _DartsRechnerState extends State<DartsRechner> {
  int startNumber = 301;
  bool playerOneTurn = true;
  late int playerOneNumber;
  late int playerTwoNumber;
  int turnCounter = 0;
  List<int> playerOneTurnValues = [];
  List<int> playerTwoTurnValues = [];
  List<int> playerOneScoreHistory = [];
  List<int> playerTwoScoreHistory = [];
  bool doubleNextScore = false;
  bool tripleNextScore = false;
  bool playerOneOverthrown = false;
  bool playerTwoOverthrown = false;
  int temporaryPlayerOneScore = 0;
  int temporaryPlayerTwoScore = 0;
  int startingScore = 0;
  List<int> temporaryPlayerOneTurnValues = [];
  List<int> temporaryPlayerTwoTurnValues = [];

  _DartsRechnerState() {
    playerOneNumber = startNumber;
    playerTwoNumber = startNumber;
  }

  // Function to save the scores temporarily before every throw
  void saveTempScores() {
    temporaryPlayerOneScore = playerOneNumber;
    temporaryPlayerTwoScore = playerTwoNumber;
    temporaryPlayerOneTurnValues = List.from(playerOneTurnValues);
    temporaryPlayerTwoTurnValues = List.from(playerTwoTurnValues);
  }

  // Function to restore the scores if a player overthrows
  void restoreScores() {
    playerOneNumber = temporaryPlayerOneScore;
    playerTwoNumber = temporaryPlayerTwoScore;
    playerOneTurnValues = List.from(temporaryPlayerOneTurnValues);
    playerTwoTurnValues = List.from(temporaryPlayerTwoTurnValues);
  }

  void endTurn() {
    if (playerOneTurn) {
      playerTwoTurnValues.clear();
      playerTwoOverthrown = false;
    } else {
      playerOneTurnValues.clear();
      playerOneOverthrown = false;
    }
    playerOneTurn = !playerOneTurn;
    turnCounter = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Darts Rechner'),
        ),
        body: Column(
          children: [
            Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      playerCard(
                          "Player One",
                          playerOneNumber,
                          playerOneTurn,
                          playerOneTurnValues,
                          playerOneScoreHistory,
                          playerOneOverthrown),
                      playerCard(
                          "Player Two",
                          playerTwoNumber,
                          !playerOneTurn,
                          playerTwoTurnValues,
                          playerTwoScoreHistory,
                          playerTwoOverthrown),
                    ],
                  ),
                )),
            Expanded(
              flex: 2,
              child: DartsRechnerTastatur(
                onNumberSelected: (num) {
                  setState(() {
                    if (num >= 0) {
                      turnCounter += 1;
                    }
                    if (turnCounter % 3 == 1) {
                      // Wenn es der erste Wurf im Zug ist
                      if (playerOneTurn) {
                        startingScore = playerOneNumber;
                      } else {
                        startingScore = playerTwoNumber;
                      }
                    }

                    if (num == -1) {
                      doubleNextScore = true;
                      tripleNextScore = false;
                    } else if (num == -2) {
                      tripleNextScore = true;
                      doubleNextScore = false;
                    } else if (doubleNextScore) {
                      num *= 2;
                      doubleNextScore = false;
                    } else if (tripleNextScore) {
                      num *= 3;
                      tripleNextScore = false;
                    }

                    // Berechne den neuen Score nach dem Wurf, aber setze ihn noch nicht
                    int newScore = playerOneTurn
                        ? playerOneNumber - num
                        : playerTwoNumber - num;

                    if (num >= 0) {
                      if (newScore < 0) { // Überwurf
                        if (playerOneTurn) {
                          playerOneNumber =
                              startingScore; // Punkte zurücksetzen
                          playerOneTurnValues.add(num);
                          playerOneScoreHistory.add(num);
                          playerOneOverthrown = true;
                          endTurn();
                        } else {
                          playerTwoNumber =
                              startingScore; // Punkte zurücksetzen
                          playerTwoTurnValues.add(num);
                          playerTwoScoreHistory.add(num);
                          playerTwoOverthrown = true;
                          endTurn();
                        }

                      } else { //kein Überwurf
                        if (playerOneTurn) {
                          playerOneNumber = newScore; // Setze den neuen Score
                          playerOneTurnValues.add(num);
                          playerOneScoreHistory.add(num);
                          playerOneOverthrown = false;
                          if (playerOneNumber == 0) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Spielende'),
                                  content: const Text('Player One wins'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        } else {
                          if (playerTwoNumber - num < 0) {
                            playerTwoNumber =
                                startingScore; // Punkte zurücksetzen
                            playerTwoOverthrown = true;
                            endTurn();
                          } else {
                            playerTwoNumber = newScore; // Setze den neuen Score
                            playerTwoTurnValues.add(num);
                            playerTwoScoreHistory.add(num);
                            playerTwoOverthrown = false;
                            if (playerTwoNumber == 0) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Spielende'),
                                    content: const Text('Player Two wins'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        }
                      }

                      if (turnCounter == 3) {
                        endTurn();
                      }
                    }
                  });
                },
              ),
            ),
          ],
        ));
  }

  Widget playerCard(String playerName, int playerScore, bool isTurn,
      List<int> turnValues, List<int> scoreHistory, bool isOverthrown) {
    Color turnBoxColor = isOverthrown ? Colors.red : Colors.black;
    var turnSum =
        turnValues.isNotEmpty ? turnValues.reduce((a, b) => a + b) : 0;
    var average = calculateAverage(scoreHistory).toStringAsFixed(1);
    var totalEntries = scoreHistory.length;

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        color: Colors.grey[900],
        height: 125,
        child: Row(
          children: [
            Container(
                color: isTurn ? Colors.green : Colors.grey[900], width: 10),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$playerScore",
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    playerName,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 35,
                    child: Row(
                      children: List.generate(
                        3,
                        (index) => Expanded(
                          child: Container(
                            color: turnBoxColor,
                            margin: const EdgeInsets.all(2),
                            child: Center(
                              child: Text(
                                index < turnValues.length
                                    ? turnValues[index].toString()
                                    : '',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      "$turnSum",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bolt, color: Colors.white),
                        Text(
                          " $totalEntries",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.assessment, color: Colors.white),
                      Text(
                        " $average",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double calculateAverage(List<int> scores) {
    if (scores.isEmpty) {
      return 0;
    } else {
      return scores.reduce((a, b) => a + b) / scores.length;
    }
  }
}

class DartsRechnerTastatur extends StatefulWidget {
  final ValueChanged<int> onNumberSelected;

  DartsRechnerTastatur({required this.onNumberSelected});

  @override
  _DartsRechnerTastaturState createState() => _DartsRechnerTastaturState();
}

class _DartsRechnerTastaturState extends State<DartsRechnerTastatur> {
  var buttonPadding = 1.5;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        rowBuilder(1, 7),
        rowBuilder(8, 14),
        specialRowBuilder(),
        specialButtonsRowBuilder(), // new row with special buttons
      ],
    );
  }

  Widget rowBuilder(int start, int end) {
    return Expanded(
      child: Row(
        children: List<int>.generate(end - start + 1, (index) => start + index)
            .map((number) {
          return Expanded(
            child: InkWell(
              onTap: () {
                widget.onNumberSelected(number);
              },
              child: Padding(
                padding: EdgeInsets.all(buttonPadding),
                child: Container(
                  color: Colors.grey[600],
                  alignment: Alignment.center,
                  child: Text('$number', style: const TextStyle(fontSize: 18)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget specialRowBuilder() {
    List<Widget> children =
        List<int>.generate(20 - 15 + 1, (index) => 15 + index).map((number) {
      return Expanded(
        child: InkWell(
          onTap: () {
            widget.onNumberSelected(number);
          },
          child: Padding(
            padding: EdgeInsets.all(buttonPadding),
            child: Container(
              color: Colors.grey[600],
              alignment: Alignment.center,
              child: Text('$number', style: const TextStyle(fontSize: 18)),
            ),
          ),
        ),
      );
    }).toList();

    // add the last button with the value 25
    children.add(
      Expanded(
        child: InkWell(
          onTap: () {
            widget.onNumberSelected(25);
          },
          child: Padding(
            padding: EdgeInsets.all(buttonPadding),
            child: Container(
              color: Colors.grey[600],
              alignment: Alignment.center,
              child: const Text('25', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ),
    );

    return Expanded(
      child: Row(
        children: children,
      ),
    );
  }

  Widget specialButtonsRowBuilder() {
    return Expanded(
      child: Row(
        children: [
          buttonBuilder(const Text('0'), 0, Colors.grey[600]!),
          buttonBuilder(const Text('DOUBLE'), -1, Colors.orange),
          buttonBuilder(const Text('TRIPLE'), -2, Colors.orange[700]!),
          buttonBuilder(const Icon(Icons.arrow_back), -3, Colors.red[900]!),
        ],
      ),
    );
  }

  Widget buttonBuilder(Widget contentWidget, int returnValue, Color color,
      [bool isDisabled = false]) {
    return Expanded(
      child: InkWell(
        onTap: isDisabled
            ? null
            : () {
                widget.onNumberSelected(returnValue);
              },
        child: Padding(
          padding: EdgeInsets.all(buttonPadding),
          child: Container(
            color: color,
            alignment: Alignment.center,
            child: contentWidget,
          ),
        ),
      ),
    );
  }
}
