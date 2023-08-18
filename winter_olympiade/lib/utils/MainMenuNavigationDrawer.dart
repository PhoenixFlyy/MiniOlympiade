import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:olympiade/ChessClock.dart';
import 'package:olympiade/DartCalculator.dart';
import 'package:olympiade/Rules.dart';
import 'package:olympiade/SchedulePage.dart';
import 'package:olympiade/TeamSelection.dart';
import 'package:olympiade/UploadPointsScreen.dart';
import 'package:olympiade/utils/MatchData.dart';
import 'package:olympiade/utils/Soundboard.dart';

class MainMenuNavigationDrawer extends StatefulWidget {
  final int currentRound;
  final int selectedRound;
  final int teamNumber;
  final int maxChessTime;
  final DateTime eventStartTime;
  final DateTime eventEndTime;

  const MainMenuNavigationDrawer(
      {Key? key,
      required this.currentRound,
      required this.selectedRound,
      required this.teamNumber,
      required this.maxChessTime,
      required this.eventStartTime,
      required this.eventEndTime})
      : super(key: key);

  @override
  State<MainMenuNavigationDrawer> createState() =>
      _MainMenuNavigationDrawerState();
}

class _MainMenuNavigationDrawerState extends State<MainMenuNavigationDrawer> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Drawer(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  buildHeader(context),
                  buildMenuItems(context),
                ],
              ),
              Center(
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  shouldLoop: false,
                  blastDirection: pi / 2,
                  emissionFrequency: 0.6,
                  numberOfParticles: 15,
                ),
              ),
            ],
          ),
        ),
      );

  Widget buildHeader(BuildContext context) => Material(
        child: InkWell(
          onTap: () => _confettiController.play(),
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            child: Column(
              children: [
                Container(
                  width: 124,
                  height: 124,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    shape: BoxShape.circle,
                  ),
                  child: Align(
                    alignment: const Alignment(0, -0.9),
                    child: Image.asset(
                      "assets/pokalganz.png",
                      fit: BoxFit.scaleDown,
                      width: 105,
                      height: 105,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text("Olympiade 2023", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        DateFormat(' dd.MM. HH:mm')
                            .format(widget.eventStartTime),
                        style: const TextStyle(fontSize: 16)),
                    const Text(" bis ca. ", style: TextStyle(fontSize: 16)),
                    Text(DateFormat('HH:mm').format(widget.eventEndTime),
                        style: const TextStyle(fontSize: 16)),
                    const Text(' Uhr', style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      );

  Widget buildMenuItems(BuildContext context) => Wrap(
        runSpacing: 16,
        children: [
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_outlined),
            title: const Text('Ergebnisse eintragen'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => UploadResults(
                      currentRound: widget.currentRound,
                      teamNumber: widget.teamNumber)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.bolt_outlined),
            title: const Text('Dartsrechner'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const DartsRechner()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.access_time_outlined),
            title: const Text('Schachuhr'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      SchachUhr(maxtime: widget.maxChessTime)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.rule_outlined),
            title: const Text('Regeln'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => RulesScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.next_plan_outlined),
            title: const Text('Laufplan'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SchedulePage(
                      pairings: pairings,
                      disciplines: disciplines,
                      currentRowForColor: widget.currentRound)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.music_note_outlined),
            title: const Text('Soundboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SoundBoard()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.change_circle_outlined),
            title: const Text('Team Auswahl'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const TeamSelection()));
            },
          ),
        ],
      );
}
