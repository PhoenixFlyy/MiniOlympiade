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
              // Hier können Sie den Code einfügen, um den Timer zu starten.
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
                // Hier können Sie den Code einfügen, um den Dartsrechner zu öffnen.
              },
              child: Text('Dartsrechner öffnen'),
            ),
            ElevatedButton(
              onPressed: () {
                // Hier können Sie den Code einfügen, um die Stoppuhr zu öffnen.
              },
              child: Text('Stoppuhr öffnen'),
            ),
            ElevatedButton(
              onPressed: () {
                // Hier können Sie den Code einfügen, um die Regeln anzuzeigen.
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
