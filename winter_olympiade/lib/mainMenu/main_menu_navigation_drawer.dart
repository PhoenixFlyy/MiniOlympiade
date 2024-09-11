import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:olympiade/infos/rules.dart';
import 'package:olympiade/infos/schedule_page.dart';
import 'package:olympiade/infos/soundboard.dart';
import 'package:olympiade/infos/achievements/achievement_provider.dart';
import 'package:olympiade/setup/team_selection.dart';
import 'package:olympiade/setup/upload_points_screen.dart';
import 'package:olympiade/utils/match_data.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../games/chess_timer.dart';
import '../games/Dart/darts_start_screen.dart';
import '../infos/achievements/achievement_screen.dart';
import '../wuecade/screens/main_menu_screen.dart';

class MainMenuNavigationDrawer extends StatefulWidget {
  final int currentRound;
  final int selectedRound;
  final int teamNumber;
  final int maxChessTime;
  final DateTime eventStartTime;
  final DateTime eventEndTime;

  const MainMenuNavigationDrawer(
      {super.key,
      required this.currentRound,
      required this.selectedRound,
      required this.teamNumber,
      required this.maxChessTime,
      required this.eventStartTime,
      required this.eventEndTime});

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
          onTap: () {
            _confettiController.play();
            context.read<AchievementProvider>().incrementConfettiTriggerCount();
            context.read<AchievementProvider>().completeAchievementByTitle('Lass es regnen');
          },
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.asset(
                      "assets/NewLogo.png",
                      fit: BoxFit.scaleDown,
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text("Olympiade ${DateTime.now().year}",
                    style: const TextStyle(fontSize: 22, color: Colors.amber)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        DateFormat(' dd.MM. HH:mm')
                            .format(widget.eventStartTime),
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white)),
                    const Text(" bis ca. ",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                    Text(DateFormat('HH:mm').format(widget.eventEndTime),
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white)),
                    const Text(' Uhr',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
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
            leading: const Icon(Icons.upload_outlined, color: Colors.white),
            title: const Text('Ergebnisse nachtragen',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => UploadResults(
                      currentRound: widget.currentRound,
                      teamNumber: widget.teamNumber)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.bolt_outlined, color: Colors.white),
            title: const Text('Dartsrechner',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const DartStartScreen()));
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.access_time_outlined, color: Colors.white),
            title:
                const Text('Schachuhr', style: TextStyle(color: Colors.white)),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      ChessTimer(maxTime: widget.maxChessTime)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.rule_outlined, color: Colors.white),
            title: const Text('Regeln', style: TextStyle(color: Colors.white)),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const RulesScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.next_plan_outlined, color: Colors.white),
            title:
                const Text('Laufplan', style: TextStyle(color: Colors.white)),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SchedulePage(
                      pairings: pairings,
                      disciplines: disciplines,
                      currentRowForColor: widget.currentRound)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events, color: Colors.white),
            title:
            const Text('Achievements', style: TextStyle(color: Colors.white)),
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AchievementScreen(),
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.music_note_outlined, color: Colors.white),
            title:
            const Text('Soundboard', style: TextStyle(color: Colors.white)),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SoundBoard()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.gamepad, color: Colors.white),
            title:
            const Text('Wuecade Games', style: TextStyle(color: Colors.white)),
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FlappyMain(),
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.coffee, color: Colors.white),
            title: const Text('Spendiere einen Kaffee!',
                style: TextStyle(color: Colors.white)),
            onTap: () async {
              HapticFeedback.lightImpact();
              context
                  .read<AchievementProvider>()
                  .completeAchievementByTitle('Barista');
              Navigator.pop(context);

              final url = Uri.parse(
                  'https://www.paypal.com/paypalme/FScheuerpflug');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Fehler'),
                    content: const Text(
                        'Der PayPal-Link konnte nicht geöffnet werden.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.change_circle_outlined, color: Colors.white),
            title: const Text('Team Auswahl',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const TeamSelection()));
            },
          ),
        ],
      );
}
