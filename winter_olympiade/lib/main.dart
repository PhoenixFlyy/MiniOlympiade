import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winter_olympiade/MainMenu.dart';

import 'TeamSelection.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkIfTeamSelected(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Zeige einen Ladeindikator, während die Prüfung läuft
        } else if (snapshot.hasError) {
          return Center(child: Text('Error')); // Zeige eine Fehlermeldung, wenn ein Fehler auftritt
        } else {
          final bool teamSelected = snapshot.data ?? false;

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Mini Olympiade',
            theme: ThemeData.dark(
              useMaterial3: true,
            ),
            home: teamSelected ? mainMenu() : TeamSelection(),
          );
        }
      },
    );
  }

  Future<bool> _checkIfTeamSelected() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('selectedTeam');
  }
}
