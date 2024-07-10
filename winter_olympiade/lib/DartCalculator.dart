import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class GameState1 {
  List<List<dynamic>> history = []; // Speichert die Historie der Würfe.
}

class _DartsRechnerState extends State<DartsRechner>
    with WidgetsBindingObserver {
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
  List<List<dynamic>> history = [];

  var gameState1 = GameState1();

  List<dynamic> lastState = []; //unnötig?

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadGameState();
    playerOneNumber = startNumber;
    playerTwoNumber = startNumber;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _saveGameState();
    }
  }

  void addCurrentStateToHistory() {
    var currentState = [
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
    ];
    gameState1.history.add(currentState);
  }

  void undoLastEntry() {
    if (gameState1.history.isNotEmpty) {
      var lastState = gameState1.history.removeLast();

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

  void _startNewGame() {
    setState(() {
      // Setzen Sie den Zustand zurück
      startNumber = 301;
      playerOneNumber = startNumber;
      playerTwoNumber = startNumber;
      playerOneTurn = true;
      turnCounter = 0;
      playerOneTurnValues.clear();
      playerTwoTurnValues.clear();
      playerOneScoreHistory.clear();
      playerTwoScoreHistory.clear();
      doubleNextScore = false;
      tripleNextScore = false;
      playerOneOverthrown = false;
      playerTwoOverthrown = false;
      temporaryPlayerOneScore = 0;
      temporaryPlayerTwoScore = 0;
      startingScore = 0;
      temporaryPlayerOneTurnValues.clear();
      temporaryPlayerTwoTurnValues.clear();
      gameState1.history.clear();
      history.clear();
    });
  }

  _saveGameState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Alle Zustandsdaten in einer Map
    Map<String, dynamic> gameState = {
      'startNumber': startNumber,
      'playerOneNumber': playerOneNumber,
      'playerTwoNumber': playerTwoNumber,
      // ... Sie können hier auch andere Zustandsdaten hinzufügen
    };

    // Konvertieren Sie die Map in einen JSON-String
    String gameStateString = jsonEncode(gameState);

    // Speichern Sie den JSON-String
    await prefs.setString('gameState', gameStateString);

    String lastStateJson = jsonEncode(lastState); //unnötig?
    await prefs.setString('lastState', lastStateJson); //unnötig?

    // Einfache Integers und Booleans
    await prefs.setInt('startNumber', startNumber);
    await prefs.setBool('playerOneTurn', playerOneTurn);
    await prefs.setInt('turnCounter', turnCounter);
    await prefs.setBool('doubleNextScore', doubleNextScore);
    await prefs.setBool('tripleNextScore', tripleNextScore);
    await prefs.setBool('playerOneOverthrown', playerOneOverthrown);
    await prefs.setBool('playerTwoOverthrown', playerTwoOverthrown);
    await prefs.setInt('temporaryPlayerOneScore', temporaryPlayerOneScore);
    await prefs.setInt('temporaryPlayerTwoScore', temporaryPlayerTwoScore);
    await prefs.setInt('startingScore', startingScore);

    // Listen als Strings speichern
    await prefs.setString(
        'playerOneTurnValues', jsonEncode(playerOneTurnValues));
    await prefs.setString(
        'playerTwoTurnValues', jsonEncode(playerTwoTurnValues));
    await prefs.setString(
        'playerOneScoreHistory', jsonEncode(playerOneScoreHistory));
    await prefs.setString(
        'playerTwoScoreHistory', jsonEncode(playerTwoScoreHistory));
    await prefs.setString('temporaryPlayerOneTurnValues',
        jsonEncode(temporaryPlayerOneTurnValues));
    await prefs.setString('temporaryPlayerTwoTurnValues',
        jsonEncode(temporaryPlayerTwoTurnValues));

    String historyJson = jsonEncode(gameState1.history);
    await prefs.setString('gameStateHistory', historyJson);
  }

  _loadGameState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? lastStateString = prefs.getString('lastState'); //unnötig?
    if (lastStateString != null) {
      //unnötig?
      lastState = jsonDecode(lastStateString); //unnötig?
    } //unnötig?

    String? gameStateString = prefs.getString('gameState');
    if (gameStateString != null) {
      Map<String, dynamic> gameState = jsonDecode(gameStateString);

      setState(() {
        startNumber = prefs.getInt('startNumber') ?? 301;
        playerOneTurn = prefs.getBool('playerOneTurn') ?? true;
        turnCounter = prefs.getInt('turnCounter') ?? 0;
        doubleNextScore = prefs.getBool('doubleNextScore') ?? false;
        tripleNextScore = prefs.getBool('tripleNextScore') ?? false;
        playerOneOverthrown = prefs.getBool('playerOneOverthrown') ?? false;
        playerTwoOverthrown = prefs.getBool('playerTwoOverthrown') ?? false;
        temporaryPlayerOneScore = prefs.getInt('temporaryPlayerOneScore') ?? 0;
        temporaryPlayerTwoScore = prefs.getInt('temporaryPlayerTwoScore') ?? 0;
        startingScore = prefs.getInt('startingScore') ?? 0;
        playerOneNumber = gameState['playerOneNumber'];
        playerTwoNumber = gameState['playerTwoNumber'];

        // Listen laden
        playerOneTurnValues =
            jsonDecode(prefs.getString('playerOneTurnValues') ?? '[]')
                .cast<int>();
        playerTwoTurnValues =
            jsonDecode(prefs.getString('playerTwoTurnValues') ?? '[]')
                .cast<int>();
        playerOneScoreHistory =
            jsonDecode(prefs.getString('playerOneScoreHistory') ?? '[]')
                .cast<int>();
        playerTwoScoreHistory =
            jsonDecode(prefs.getString('playerTwoScoreHistory') ?? '[]')
                .cast<int>();
        temporaryPlayerOneTurnValues =
            jsonDecode(prefs.getString('temporaryPlayerOneTurnValues') ?? '[]')
                .cast<int>();
        temporaryPlayerTwoTurnValues =
            jsonDecode(prefs.getString('temporaryPlayerTwoTurnValues') ?? '[]')
                .cast<int>();

        String? historyString = prefs.getString('gameStateHistory');
        if (historyString != null) {
          List<dynamic> loadedHistory = jsonDecode(historyString);
          setState(() {
            gameState1.history = loadedHistory
                .map((dynamicList) => List.from(dynamicList))
                .toList();
          });
        }
      });
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Neues Spiel starten'),
              content: Text('Möchten Sie wirklich ein neues Spiel starten?'),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      child: Text('Ja'),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                    TextButton(
                      child: Text('Abbrechen'),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    SizedBox(width: 20),
                  ],
                ),
              ],
            );
          },
        ) ??
        false; // Der `?? false` stellt sicher, dass der Rückgabewert nie null ist.
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _saveGameState();
        return true; // true erlaubt dem Nutzer, den Bildschirm zu verlassen
      },
      child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text('Darts Rechner'),
            actions: [
              // Settings Icon
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
              // Reload Icon
              IconButton(
                icon: Icon(Icons.replay),
                onPressed: () async {
                  bool? confirm = await _showConfirmationDialog(context);
                  if (confirm == true) {
                    _startNewGame();
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
                        if (num == 25) {
                          tripleNextScore = false;
                          turnCounter -= 1;
                          return;
                        } else {
                          num *= 3;
                          tripleNextScore = false;
                        }
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
                              playerTwoNumber =
                                  newScore; // Setze den neuen Score
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
          )),
    );
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
            child: Padding(
              padding: EdgeInsets.all(buttonPadding),
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  color: Colors.grey[600],
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      widget.onNumberSelected(number);
                    },
                    overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.black.withOpacity(0.5); // Farbe beim Drücken
                      }
                      return Colors.transparent; // Transparent wenn nicht gedrückt.
                    }),
                    child: Center(
                      child: Text('$number', style: const TextStyle(fontSize: 18)),
                    ),
                  ),
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
        child: Padding(
          padding: EdgeInsets.all(buttonPadding),
          child: Material(
            color: Colors.transparent,
            child: Ink(
              color: Colors.grey[600],
              child: InkWell(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  widget.onNumberSelected(number);
                },
                overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.black.withOpacity(0.5); // Farbe beim Drücken
                  }
                  return Colors.transparent; // Transparent wenn nicht gedrückt.
                }),
                child: Center(
                  child: Text('$number', style: const TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ),
        ),

      );
    }).toList();

    // add the last button with the value 25
    children.add(
      Expanded(
        child: Padding(
          padding: EdgeInsets.all(buttonPadding),
          child: Material(
            color: Colors.transparent,
            child: Ink(
              color: Colors.grey[600],
              child: InkWell(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  widget.onNumberSelected(25);
                },
                overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.black.withOpacity(0.5); // Farbe beim Drücken
                  }
                  return Colors.transparent; // Transparent wenn nicht gedrückt.
                }),
                child: Center(
                  child: const Text('25', style: TextStyle(fontSize: 18)),
                ),
              ),
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
          buttonBuilder(const Text('0', style: TextStyle(fontSize: 18)), 0, Colors.grey[600]!),
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
      child: Padding(
        padding: EdgeInsets.all(buttonPadding),
        child: Material(
          color: Colors.transparent,
          child: Ink(
            color: color,
            child: InkWell(
              onTap: () {
                HapticFeedback.heavyImpact();
                if (isDisabled) {
                  return;
                }

                if (onUndo != null) {
                  onUndo();
                } else {
                  widget.onNumberSelected(returnValue);
                }
              },
              overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.black.withOpacity(0.5); // Farbe beim Drücken
                }
                return Colors.transparent; // Transparent wenn nicht gedrückt.
              }),
              splashColor: Colors.transparent,
              child: Center(
                child: contentWidget,
              ),
            ),
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
  int? selectedStartingScore =
      301; // Standard-Anfangsscore; wird aber nicht wirksam. Der Standard-Anfangsscore wird oben angegeben.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Einstellungen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
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
              title: const Text('201'),
              value: 201,
              groupValue: selectedStartingScore,
              onChanged: (value) {
                setState(() {
                  selectedStartingScore = value;
                });
              },
            ),
            RadioListTile<int>(
              title: const Text('301'),
              value: 301,
              groupValue: selectedStartingScore,
              onChanged: (value) {
                setState(() {
                  selectedStartingScore = value;
                });
              },
            ),
            RadioListTile<int>(
              title: const Text('501'),
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
