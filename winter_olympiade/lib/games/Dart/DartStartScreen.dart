import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/ImageConverter.dart';
import 'DartConstants.dart';
import 'DartPlayScreen.dart';

class DartStartScreen extends StatefulWidget {
  const DartStartScreen({super.key});

  @override
  State<DartStartScreen> createState() => _DartStartScreenState();
}

class _DartStartScreenState extends State<DartStartScreen> {
  int _selectedGameType = DartConstants.gameTypes[2];
  GameEndRule _selectedGameEndRule = GameEndRule.doubleOut;

  final List<Player> _players = [];
  final List<Player> _availablePlayers = [];

  @override
  void initState() {
    super.initState();
    _loadGameSettings();
    _loadAvailablePlayers();
  }

  Future<void> _loadGameSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedGameType = prefs.getInt('selectedGameType') ?? DartConstants.gameTypes[2];
      _selectedGameEndRule = GameEndRule.values[prefs.getInt('selectedGameEndRule') ?? GameEndRule.doubleOut.index];
    });
  }

  Future<void> _saveGameSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedGameType', _selectedGameType);
    await prefs.setInt('selectedGameEndRule', _selectedGameEndRule.index);
  }

  void _loadAvailablePlayers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? playerData = prefs.getStringList('players');
    if (playerData != null) {
      setState(() => _availablePlayers.addAll(
        playerData.map((playerJson) => Player.fromJson(jsonDecode(playerJson))),
      ));
    }
  }

  void _savePlayer(Player player) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? playerData = prefs.getStringList('players') ?? [];
    playerData.add(jsonEncode(player.toJson()));
    await prefs.setStringList('players', playerData);
  }

  void _removePlayerFromAvailable(int index) async {
    bool confirmed = await _showConfirmationDialog(context, "Spieler löschen", "Möchtest du diesen Spieler wirklich löschen?");
    if (confirmed) {
      setState(() => _availablePlayers.removeAt(index));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? playerData = prefs.getStringList('players');
      if (playerData != null) {
        playerData.removeAt(index);
        await prefs.setStringList('players', playerData);
      }
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context, String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Abbrechen', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Löschen', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  void _removePlayer(int index) =>
      setState(() => _players.removeAt(index));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('X01-Spiel einrichten'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            gameRulesSetup(),
            const SizedBox(height: 20),
            playerSetupList(),
            const SizedBox(height: 20),
            availablePlayersList(),
            const SizedBox(height: 40),
            startSetup(),
          ],
        ),
      ),
    );
  }

  Widget gameRulesSetup() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            value: _selectedGameType,
            decoration: const InputDecoration(labelText: 'X01 Auswahl'),
            items: DartConstants.gameTypes.map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
            onChanged: (newValue) =>
                setState(() {
                  _selectedGameType = newValue!;
                  _saveGameSettings();
                }),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: DropdownButtonFormField<GameEndRule>(
            value: _selectedGameEndRule,
            decoration: const InputDecoration(labelText: 'Regel'),
            items: GameEndRule.values.map((GameEndRule rule) {
              return DropdownMenuItem<GameEndRule>(
                value: rule,
                child: Text(DartConstants.gameEndRuleToString(rule)),
              );
            }).toList(),
            onChanged: (newValue) =>
                setState(() {
                  _selectedGameEndRule = newValue!;
                  _saveGameSettings();
                }),
          ),
        ),
      ],
    );
  }

  Widget playerSetupList() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              "Ausgewählte Spieler",
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _players.length,
              itemBuilder: (context, index) {
                final player = _players[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: player.image,
                      ),
                      Text(
                        player.name,
                        style: const TextStyle(fontSize: 20),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () => _removePlayer(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget availablePlayersList() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              "Verfügbare Spieler",
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _availablePlayers.length,
              itemBuilder: (context, index) {
                final player = _availablePlayers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: player.image,
                      ),
                      Text(
                        player.name,
                        style: const TextStyle(fontSize: 20),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            onPressed: () => setState(() => _players.add(player)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removePlayerFromAvailable(index),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget startSetup() {
    bool canStartGame = _players.length >= 2;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _addNewPlayer,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Spieler erstellen', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: ElevatedButton(
            onPressed: canStartGame ? () => _startGame() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canStartGame ? Colors.green : Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Spiel beginnen!'),
          ),
        ),
      ],
    );
  }

  Future<void> _addNewPlayer() async {
    TextEditingController nameController = TextEditingController();
    FocusNode nameFocusNode = FocusNode();

    File dartsImageFile = await getImageFileFromAssets('darts.png');
    FileImage playerImage = FileImage(dartsImageFile);

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            FocusScope.of(context).requestFocus(nameFocusNode);
          }
        });

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text('Erstelle neuen Spieler'),
              content: SingleChildScrollView(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(
                            source: ImageSource.camera);

                        if (pickedFile != null) {
                          setStateDialog(() {
                            playerImage = FileImage(File(pickedFile.path));
                          });
                        }
                      },
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey,
                            backgroundImage: playerImage,
                          ),
                          const Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.blue,
                              child: Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        focusNode: nameFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: const TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Abbrechen', style: TextStyle(color: Colors.white)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Spieler hinzufügen', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      final newPlayer = Player(
                        name: nameController.text,
                        image: playerImage,
                      );
                      setState(() {
                        _availablePlayers.add(newPlayer);
                        _savePlayer(newPlayer);
                      });
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bitte einen Namen eingeben!')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _startGame() {
    if (_players.map((player) => player.name).toList().any((name) => name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name for every player')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DartPlayScreen(
          gameEndRule: _selectedGameEndRule,
          gameType: _selectedGameType,
          playerList: _players,
        ),
      ),
    );
  }
}