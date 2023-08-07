import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'TeamSelection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkIfTeamSelected(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Zeige einen Ladeindikator, während die Prüfung läuft
        } else if (snapshot.hasError) {
          return Center(
              child: Text(
                  'Error')); // Zeige eine Fehlermeldung, wenn ein Fehler auftritt
        } else {
          final bool teamSelected = snapshot.data ?? false;

          return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Mini Olympiade',
              theme: ThemeData.dark(
                useMaterial3: true,
              ),
              home: TeamSelection());
        }
      },
    );
  }

  Future<bool> _checkIfTeamSelected() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('selectedTeam');
  }
}
