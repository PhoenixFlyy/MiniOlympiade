import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:olympiade/DartCalculator.dart';
import 'package:olympiade/MainMenu.dart';
import 'package:olympiade/Rules.dart';
import 'package:olympiade/SchedulePage.dart';
import 'package:olympiade/TeamSelection.dart';
import 'package:olympiade/UploadPointsScreen.dart';
import 'package:olympiade/utils/MatchData.dart';
import 'package:olympiade/utils/Soundboard.dart';

class MainMenuNavigationDrawer extends StatelessWidget {
  final int currentRound;
  final int selectedRound;
  final int teamNumber;
  final DateTime eventStartTime;
  final DateTime eventEndTime;
  const MainMenuNavigationDrawer(
      {super.key,
      required this.currentRound,
      required this.selectedRound,
      required this.teamNumber,
      required this.eventStartTime,
      required this.eventEndTime});

  @override
  Widget build(BuildContext context) => Drawer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              buildHeader(context),
              buildMenuItems(context),
            ],
          ),
        ),
      );

  Widget buildHeader(BuildContext context) => Material(
        child: InkWell(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 52,
                  backgroundImage: AssetImage("assets/pokalganz.png"),
                ),
                const SizedBox(height: 8),
                const Text("Olympiade 2023", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(DateFormat(' dd.MM. HH:mm').format(eventStartTime),
                        style: const TextStyle(fontSize: 16)),
                    const Text(" bis ", style: TextStyle(fontSize: 16)),
                    Text(DateFormat('HH:mm').format(eventEndTime),
                        style: const TextStyle(fontSize: 16)),
                    Text(' Uhr', style: const TextStyle(fontSize: 16)),

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
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MainMenu()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_outlined),
            title: const Text('Ergebnisse eintragen'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => UploadResults(
                      currentRound: currentRound, teamNumber: teamNumber)));
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
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MainMenu()));
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
                      currentRowForColor: currentRound)));
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
