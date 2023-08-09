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

class GameState {
  List<List<dynamic>> history =
      []; // Speichert die Historie der Würfe. Jede Liste stellt eine Runde von Würfen dar.
}

class _DartsRechnerState extends State<DartsRechner> {
  int startNumber = 501; // Standard-Anfangsscore
  //late int startNumber; // Anfangsscore nciht benötigt...???

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

  var gameState = GameState();

  @override
  void initState() {
    super.initState();
    playerOneNumber = startNumber;
    playerTwoNumber = startNumber;
  }

  //_DartsRechnerState(int initialStartingScore) {
    //startNumber = initialStartingScore;
    //playerOneNumber = startNumber;
    //playerTwoNumber = startNumber;
  //}

  void addCurrentStateToHistory() {
    gameState.history.add([
      playerOneNumber,
      playerTwoNumber,
      List.from(playerOneTurnValues),
      List.from(playerTwoTurnValues),
      List.from(playerOneScoreHistory),
      List.from(playerTwoScoreHistory),
      doubleNextScore,
      tripleNextScore,
      playerOneOverthrown,
      playerTwoOverthrown,
      temporaryPlayerOneScore,
      temporaryPlayerTwoScore,
      List.from(temporaryPlayerOneTurnValues),
      List.from(temporaryPlayerTwoTurnValues),
      turnCounter,
      playerOneTurn,
    ]);
  }

  void undoLastEntry() {
    if (gameState.history.isNotEmpty) {
      var lastState = gameState.history.removeLast();

      setState(() {
        playerOneNumber = lastState[0];
        playerTwoNumber = lastState[1];
        playerOneTurnValues = List.from(lastState[2]);
        playerTwoTurnValues = List.from(lastState[3]);
        playerOneScoreHistory = List.from(lastState[4]);
        playerTwoScoreHistory = List.from(lastState[5]);
        doubleNextScore = lastState[6];
        tripleNextScore = lastState[7];
        playerOneOverthrown = lastState[8];
        playerTwoOverthrown = lastState[9];
        temporaryPlayerOneScore = lastState[10];
        temporaryPlayerTwoScore = lastState[11];
        temporaryPlayerOneTurnValues = List.from(lastState[12]);
        temporaryPlayerTwoTurnValues = List.from(lastState[13]);
        turnCounter = lastState[14];
        playerOneTurn = lastState[15];
      });
    }
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
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );

                if (result != null) {
                  setState(() {
                    startNumber = result;
                    playerOneNumber = startNumber;
                    playerTwoNumber = startNumber;
                  });
                }
              },
            ),
          ],
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
                      addCurrentStateToHistory(); // Zustand speichern
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

                    if (num == -3) {
                      undoLastEntry();
                      return;
                    }

                    // Berechne den neuen Score nach dem Wurf, aber setze ihn noch nicht
                    int newScore = playerOneTurn
                        ? playerOneNumber - num
                        : playerTwoNumber - num;

                    if (num >= 0) {
                      if (newScore < 0) {
                        // Überwurf
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
                      } else {
                        //kein Überwurf
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
                undoLastEntry: undoLastEntry,
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
  final VoidCallback undoLastEntry;

  DartsRechnerTastatur(
      {required this.onNumberSelected, required this.undoLastEntry});

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
          buttonBuilder(
              const Icon(Icons.arrow_back),
              -3,
              Colors.red[900]!,
              false,
              widget.undoLastEntry // Zugriff auf die Methode über 'widget'
              ),
        ],
      ),
    );
  }

  Widget buttonBuilder(Widget contentWidget, int returnValue, Color color,
      [bool isDisabled = false, VoidCallback? onUndo]) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (isDisabled) {
            return;
          }

          if (onUndo != null) {
            onUndo();
          } else {
            widget.onNumberSelected(returnValue);
          }
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


class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int? selectedStartingScore = 501; // Standard-Anfangsscore; wird aber nicht wirksam. Der Standard-Anfangsscore wird oben angegeben.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Einstellungen'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, selectedStartingScore);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            RadioListTile<int>(
              title: Text('201'),
              value: 201,
              groupValue: selectedStartingScore,
              onChanged: (value) {
                setState(() {
                  selectedStartingScore = value;
                });
              },
            ),
            RadioListTile<int>(
              title: Text('301'),
              value: 301,
              groupValue: selectedStartingScore,
              onChanged: (value) {
                setState(() {
                  selectedStartingScore = value;
                });
              },
            ),
            RadioListTile<int>(
              title: Text('501'),
              value: 501,
              groupValue: selectedStartingScore,
              onChanged: (value) {
                setState(() {
                  selectedStartingScore = value;
                });
              },
            ),
            // ... Weitere RadioListTile für andere Anfangsscores
          ],
        ),
      ),
    );
  }
}


