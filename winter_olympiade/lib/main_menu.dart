import 'package:flutter/material.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int currentRound = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Menu'),
        actions: [
          IconButton(
            icon: Icon(Icons.timer),
            onPressed: () {
              // Hier k�nnen Sie den Code einf�gen, um den Timer zu starten.
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Runde: $currentRound',
                style: TextStyle(fontSize: 20),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Hier k�nnen Sie den Code einf�gen, um den Dartsrechner zu �ffnen.
              },
              child: Text('Dartsrechner �ffnen'),
            ),
            ElevatedButton(
              onPressed: () {
                // Hier k�nnen Sie den Code einf�gen, um die Stoppuhr zu �ffnen.
              },
              child: Text('Stoppuhr �ffnen'),
            ),
            ElevatedButton(
              onPressed: () {
                // Hier k�nnen Sie den Code einf�gen, um die Regeln anzuzeigen.
              },
              child: Text('Regeln'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MainMenu(),
  ));
}
