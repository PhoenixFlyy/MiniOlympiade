import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olympiade/infos/achievements/achievement_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'MainMenu.dart';
import 'setup/TeamSelection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AwesomeNotifications().initialize("assets/icon/play_store_512.png", [
    NotificationChannel(
      channelGroupKey: "achievement_channel_group",
      channelKey: "achievement_channel",
      channelName: "Achievement",
      channelDescription: "Achievement Channel",
    )
  ], channelGroups: [
    NotificationChannelGroup(
        channelGroupKey: "achievement_channel_group",
        channelGroupName: "Achievement Group")
  ]);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkIfTeamSelected(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        } else {
          final bool teamSelected = snapshot.data ?? false;

          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => AchievementProvider(),
              ),
            ],
            child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Olympiade',
                theme: ThemeData.dark(
                  useMaterial3: true,
                ),
                home: teamSelected ? const MainMenu() : const TeamSelection()),
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
