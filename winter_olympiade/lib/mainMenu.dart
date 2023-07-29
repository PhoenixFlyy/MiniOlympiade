import 'package:flutter/material.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => MainMenuState();
}

class MainMenuState extends State<MainMenu> {

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Column(children: [
        Row(children: [
          ElevatedButton(
            onPressed: null,
            child: Text("Timer starten"),
          ),
        ]),
        Text("Dartrechner öffnen"),
        Text("Schachuhr öffnen"),
        Text("Regeln"),
      ]),
    );
  }
}
